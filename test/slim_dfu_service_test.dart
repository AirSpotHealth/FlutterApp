import 'dart:async';
import 'dart:typed_data';
import 'package:airspothealth/features/device_settings/service/slim_dfu_service.dart';
import 'package:airspothealth/features/device_settings/service/slim_firmware_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mcumgr_flutter/mcumgr_flutter.dart';
import 'package:mcumgr_flutter/models/firmware_upgrade_mode.dart';
import 'slim_test_helpers.dart';

class FakeFactory extends UpdateManagerFactory {
  FakeFactory(this.manager);
  final FakeManager manager;
  @override
  Future<FirmwareUpdateManager> getUpdateManager(String deviceId) async =>
      manager;
}

class FakeManager implements FirmwareUpdateManager {
  final states = StreamController<FirmwareUpgradeState>.broadcast();
  final progress = StreamController<ProgressUpdate>.broadcast();
  List<ImageSlot> before = [];
  List<ImageSlot> after = [];
  String outcome = 'success';
  int uploads = 0;
  final List<Object> verificationResults = [];
  int verificationReads = 0;
  bool killed = false;
  bool cancelled = false;
  FirmwareUpgradeConfiguration? configuration;
  @override
  Stream<FirmwareUpgradeState> setup() => states.stream;
  @override
  Stream<ProgressUpdate> get progressStream => progress.stream;
  @override
  Future<List<ImageSlot>?> readImageList() async {
    if (uploads == 0) return before;
    verificationReads++;
    if (verificationResults.isNotEmpty) {
      final next = verificationResults.removeAt(0);
      if (next is List<ImageSlot>) return next;
      throw next;
    }
    return after;
  }

  @override
  Future<void> update(List<Image> images,
      {FirmwareUpgradeConfiguration configuration =
          const FirmwareUpgradeConfiguration()}) async {
    uploads++;
    this.configuration = configuration;
    switch (outcome) {
      case 'reconnect-error':
        states.add(FirmwareUpgradeState.reset);
        states.addError(StateError('reconnect timed out'));
      case 'direct-reconnect-error':
        states.add(FirmwareUpgradeState.reset);
        await Future<void>.delayed(Duration.zero);
        throw StateError('native update call failed after reset');
      case 'direct-error':
        throw StateError('native upload rejected');
      case 'error':
        states.addError(StateError('low battery: write rejected'));
      case 'closed':
        await states.close();
      case 'timeout':
        break;
      default:
        states.add(FirmwareUpgradeState.success);
    }
  }

  @override
  Future<void> cancel() async {
    cancelled = true;
  }

  @override
  Future<void> kill() async {
    killed = true;
    await states.close();
    await progress.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final firmware = SlimFirmwareImage.parse(signedImage());
  ImageSlot slot({bool confirmed = true, Uint8List? hash}) => ImageSlot(
      image: 0,
      slot: 0,
      hash: hash ?? firmware.hash,
      bootable: true,
      pending: false,
      confirmed: confirmed,
      active: true,
      permanent: confirmed,
      version: firmware.version);
  Future<bool> run(FakeManager manager) => SlimDfuService.upload(
      deviceId: 'test',
      firmware: firmware,
      onProgress: (_) {},
      onStatus: (_) {},
      factory: FakeFactory(manager),
      timeout: const Duration(milliseconds: 50),
      confirmationTimeout: Duration.zero,
      pollInterval: Duration.zero);
  test('success requires active confirmed target and preserves settings',
      () async {
    final manager = FakeManager()..after = [slot()];
    expect(await run(manager), false);
    expect(manager.configuration!.eraseAppSettings, false);
    expect(manager.configuration!.firmwareUpgradeMode,
        FirmwareUpgradeMode.testOnly);
    expect(manager.configuration!.estimatedSwapTime, Duration.zero);
    expect(manager.killed, true);
    expect(manager.cancelled, false);
  });
  test('reboot reconnect failure can recover only with confirmed target',
      () async {
    final manager = FakeManager()
      ..outcome = 'reconnect-error'
      ..after = [slot()];
    expect(await run(manager), false);
    expect(manager.uploads, 1);
    expect(manager.cancelled, false);
  });
  test('reboot reconnect failure without confirmation still fails', () async {
    final manager = FakeManager()..outcome = 'reconnect-error';
    await expectLater(run(manager), throwsA(isA<SlimDfuException>()));
    expect(manager.cancelled, true);
  });
  test('polls through disconnection and unconfirmed startup, then ends early',
      () async {
    final manager = FakeManager()
      ..verificationResults.addAll([
        StateError('disconnected'),
        [slot(confirmed: false)],
        [slot()],
      ]);
    expect(
        await SlimDfuService.upload(
          deviceId: 'test',
          firmware: firmware,
          onProgress: (_) {},
          onStatus: (_) {},
          factory: FakeFactory(manager),
          confirmationTimeout: const Duration(seconds: 150),
          pollInterval: Duration.zero,
        ).timeout(const Duration(seconds: 1)),
        false);
    expect(manager.verificationReads, 3);
    expect(manager.uploads, 1);
  });
  test('direct native error after reset still verifies confirmed image',
      () async {
    final manager = FakeManager()
      ..outcome = 'direct-reconnect-error'
      ..after = [slot()];
    expect(await run(manager), false);
    expect(manager.killed, true);
  });
  test('observed trial then previous image is classified as rollback',
      () async {
    final old = ImageSlot(
        image: 0,
        slot: 0,
        hash: Uint8List.fromList([1, 2, 3]),
        bootable: true,
        pending: false,
        confirmed: true,
        active: true,
        permanent: true,
        version: '0.1.0');
    final manager = FakeManager()
      ..before = [old]
      ..after = [old]
      ..verificationResults.addAll([
        [slot(confirmed: false)],
        [old]
      ]);
    await expectLater(
        SlimDfuService.upload(
            deviceId: 'test',
            firmware: firmware,
            onProgress: (_) {},
            onStatus: (_) {},
            factory: FakeFactory(manager),
            confirmationTimeout: const Duration(milliseconds: 5),
            pollInterval: Duration.zero),
        throwsA(isA<SlimDfuException>()
            .having((e) => e.failure, 'failure', SlimDfuFailure.rolledBack)));
  });
  test('previous image without observed trial does not claim rollback',
      () async {
    final old = slot(hash: Uint8List.fromList([1, 2, 3]));
    final manager = FakeManager()
      ..before = [old]
      ..after = [old];
    await expectLater(
        run(manager),
        throwsA(isA<SlimDfuException>().having(
            (e) => e.failure, 'failure', SlimDfuFailure.previousImageActive)));
  });
  test('unconfirmed target has a distinct outcome', () async {
    final manager = FakeManager()..after = [slot(confirmed: false)];
    await expectLater(
        run(manager),
        throwsA(isA<SlimDfuException>()
            .having((e) => e.failure, 'failure', SlimDfuFailure.unconfirmed)));
  });
  test('already-current image skips upload but still releases manager',
      () async {
    final manager = FakeManager()..before = [slot()];
    expect(await run(manager), true);
    expect(manager.uploads, 0);
    expect(manager.killed, true);
  });
  test('upload completion without confirmed target is failure', () async {
    final manager = FakeManager()..after = [slot(confirmed: false)];
    await expectLater(run(manager), throwsA(isA<SlimDfuException>()));
    expect(manager.cancelled, true);
    expect(manager.killed, true);
  });
  for (final outcome in ['error', 'direct-error', 'closed', 'timeout']) {
    test('$outcome ends with cleanup and no blind retry', () async {
      final manager = FakeManager()..outcome = outcome;
      await expectLater(run(manager), throwsA(anything));
      expect(manager.uploads, 1);
      expect(manager.cancelled, true);
      expect(manager.killed, true);
    });
  }
}
