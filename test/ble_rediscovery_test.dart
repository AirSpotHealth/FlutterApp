import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/features/device_settings/providers/device_forget_status_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:io';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/services/ble_service.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// Platform test double for the app's Bluetooth dependency.
// ignore: depend_on_referenced_packages
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_plus/isar_plus.dart';

final class ScanPlatform extends FlutterBluePlusPlatform {
  final connectionChanges =
      StreamController<BmConnectionStateResponse>.broadcast();
  @override
  Stream<BmConnectionStateResponse> get onConnectionStateChanged =>
      connectionChanges.stream;
  int disconnectCalls = 0;
  @override
  Future<bool> disconnect(BmDisconnectRequest request) async {
    disconnectCalls++;
    connectionChanges.add(BmConnectionStateResponse(
        remoteId: request.remoteId,
        connectionState: BmConnectionStateEnum.disconnected,
        disconnectReasonCode: null,
        disconnectReasonString: null));
    throw StateError('Bluetooth is off; disconnected device cannot respond');
  }

  final responses = StreamController<BmScanResponse>.broadcast();
  @override
  Stream<BmScanResponse> get onScanResponse => responses.stream;
  @override
  Future<bool> startScan(BmScanSettings settings) async => true;
  @override
  Future<bool> stopScan(BmStopScanRequest request) async => true;

  void advertise() => responses.add(BmScanResponse.fromMap({
        'advertisements': [
          {'remote_id': 'slim', 'adv_name': 'AirSpot-123456', 'rssi': -50},
          {'remote_id': 'screen', 'adv_name': 'AirSpot-654321', 'rssi': -60},
        ],
      }));
}

class FailingWriteService implements IsarService {
  FailingWriteService(this.delegate);
  final IsarService delegate;
  Object? failure;
  @override
  void write(void Function(Isar) fn) {
    if (failure != null) throw failure!;
    delegate.write(fn);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Forget Device makes Slim discoverable on the same scan subscription',
      () async {
    final directory = Directory.systemTemp.createTempSync('ble-rediscovery-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => directory.path);
    await Isar.initialize(Platform.environment['ISAR_LIBRARY_PATH']);
    final database = IsarService();
    await database.initialize();
    final platform = ScanPlatform();
    FlutterBluePlusPlatform.instance = platform;
    final writes = FailingWriteService(database);
    final container = ProviderContainer(
        overrides: [isarServiceProvider.overrideWithValue(writes)]);
    final results = <List<String>>[];
    StreamSubscription<List<BluetoothDevice>>? subscription;
    try {
      database.write((isar) => isar.bleDevices.putAll([
            for (final id in ['slim', 'screen'])
              BleDevice(
                  deviceId: id,
                  name: id,
                  address: id,
                  platform: 'ios',
                  deviceModelValue: id == 'slim'
                      ? DeviceModel.airspotSlim.index
                      : DeviceModel.airspotScreen.index),
          ]));
      subscription = BLEService.instance.scanResults().listen((devices) =>
          results.add(devices.map((d) => d.remoteId.str).toList()));
      await FlutterBluePlus.startScan();
      platform.advertise();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(results.last, isEmpty);

      // Reproduce the old prerequisite: native disconnect throws while the
      // radio is unavailable, so awaiting it previously prevented deletion.
      await expectLater(
          container
              .read(bleDeviceConnectionProvider('slim').notifier)
              .disconnect(),
          throwsA(isA<StateError>()));
      expect(platform.disconnectCalls, 1);
      platform.disconnectCalls = 0;

      // Exercise the actual UI notifier, not direct database deletion. An
      // already disconnected device must never depend on native disconnect.
      final detail = container.listen(bleDeviceProvider('slim'), (_, __) {},
          onError: (_, __) {});
      final history = container.listen(
          deviceHistoryDataRequestProvider('slim'), (_, __) {},
          onError: (_, __) {});
      final forgetState =
          container.listen(deviceForgetStatusProvider('slim'), (_, __) {});
      await container.read(deviceForgetStatusProvider('slim').future);
      // A genuine local write failure must retain the device and original cause.
      final failure = StateError('test database write failure');
      writes.failure = failure;
      expect(
          await container
              .read(deviceForgetStatusProvider('slim').notifier)
              .forget(),
          false);
      expect(container.read(deviceForgetStatusProvider('slim')).error,
          same(failure));
      database.read((isar) => expect(isar.bleDevices.get('slim'), isNotNull));
      writes.failure = null;
      expect(
          await container
              .read(deviceForgetStatusProvider('slim').notifier)
              .forget(),
          true);
      expect(container.read(deviceForgetStatusProvider('slim')).value, true);
      expect(platform.disconnectCalls, 0);
      database.read((isar) => expect(isar.bleDevices.get('slim'), isNull));
      expect(container.read(bleSavedDevicesProvider).map((d) => d.deviceId),
          ['screen']);
      forgetState.close();
      detail.close();
      history.close();
      platform.advertise();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(results.last, ['slim']);
      // A read-only caller (or dismissed sheet) does not dispose an in-flight removal.
      final removal = container
          .read(deviceForgetStatusProvider('screen').notifier)
          .forget();
      await Future<void>.delayed(Duration.zero);
      expect(await removal, true);
      database.read((isar) => expect(isar.bleDevices.get('screen'), isNull));
      expect(platform.disconnectCalls, 0);
    } finally {
      container.dispose();
      await FlutterBluePlus.stopScan();
      await subscription?.cancel();
      await platform.responses.close();
      await platform.connectionChanges.close();
      database.close();
      directory.deleteSync(recursive: true);
    }
  });
}
