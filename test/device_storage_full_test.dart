import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/history_coverage.dart';
import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/device_removal_service.dart';
import 'package:airspothealth/features/device_settings/providers/device_forget_status_provider.dart';

class ObservedDatabase implements IsarService {
  ObservedDatabase(this.database);
  final IsarService database;
  int batches = 0;
  int? failAfterBatches;
  @override
  void write(void Function(Isar) fn) {
    if (batches == failAfterBatches) throw StateError('interrupted removal');
    final before = database.read(
        (isar) => isar.deviceDatas.where().deviceIdEqualTo('remove').count());
    database.write(fn);
    final after = database.read(
        (isar) => isar.deviceDatas.where().deviceIdEqualTo('remove').count());
    expect(before - after, lessThanOrEqualTo(DeviceRemovalService.batchSize));
    if (before > after) batches++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'reopens a full database and forgets only the selected device in bounded batches',
      () async {
    final directory =
        Directory.systemTemp.createTempSync('full-device-storage-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => directory.path);
    await Isar.initialize(Platform.environment['ISAR_LIBRARY_PATH']);
    // A small real Isar map reaches the same native DatabaseFullError quickly.
    final old = Isar.open(
        schemas: IsarService.schemas,
        directory: directory.path,
        maxSizeMiB: 2,
        inspector: false);
    final retained =
        DeviceData(deviceId: 'keep', dateTime: DateTime.utc(2026), value: 700);
    old.write((isar) {
      for (final id in ['keep', 'remove']) {
        isar.bleDevices.put(
            BleDevice(deviceId: id, name: id, address: id, platform: 'ios'));
        isar.notificationPreferences.put(NotificationPreferences(deviceId: id));
        isar.historyCoverages
            .put(HistoryCoverage(deviceId: id, startSecond: 1, endSecond: 100));
      }
      isar.deviceDatas.put(retained);
    });
    var full = false;
    for (var batch = 0; batch < 1000 && !full; batch++) {
      try {
        old.write((isar) => isar.deviceDatas.putAll(List.generate(
            128,
            (i) => DeviceData(
                deviceId: 'remove',
                dateTime: DateTime.fromMillisecondsSinceEpoch(
                    (batch * 128 + i) * 1000),
                value: 800))));
      } on DatabaseFullError {
        full = true;
      }
    }
    expect(full, isTrue);
    final count = old.read(
        (isar) => isar.deviceDatas.where().deviceIdEqualTo('remove').count());
    expect(count, greaterThan(256));
    old.close();
    final database = IsarService();
    try {
      await database.initialize();
      database.read((isar) => expect(
          isar.deviceDatas.where().deviceIdEqualTo('remove').count(), count));
      final observed = ObservedDatabase(database)..failAfterBatches = 2;
      await expectLater(
          DeviceRemovalService(observed).remove('remove'), throwsStateError);
      database.read((isar) {
        expect(isar.bleDevices.get('remove'), isNotNull);
        expect(isar.deviceDatas.where().deviceIdEqualTo('remove').count(),
            count - 2 * DeviceRemovalService.batchSize);
      });
      observed.failAfterBatches = null;
      await DeviceRemovalService(observed).remove('remove');
      expect(observed.batches, greaterThan(1));
      database.read((isar) {
        expect(isar.bleDevices.get('remove'), isNull);
        expect(isar.deviceDatas.where().deviceIdEqualTo('remove').count(), 0);
        expect(
            isar.historyCoverages.where().deviceIdEqualTo('remove').count(), 0);
        expect(isar.notificationPreferences.get('remove'), isNull);
        expect(isar.bleDevices.get('keep'), isNotNull);
        final kept = isar.deviceDatas.get(retained.id)!;
        expect(kept.value, retained.value);
        expect(kept.dateTime.isAtSameMomentAs(retained.dateTime), isTrue);
        expect(isar.notificationPreferences.get('keep'), isNotNull);
        expect(
            isar.historyCoverages.where().deviceIdEqualTo('keep').count(), 1);
      });
      await DeviceRemovalService(database).remove('remove'); // Safe retry.
    } finally {
      database.close();
      directory.deleteSync(recursive: true);
    }
  });
  test(
      'storage full message explains recovery without claiming phone disk is full',
      () {
    expect(forgetDeviceErrorMessage(DatabaseFullError()),
        contains('Close and reopen'));
    expect(forgetDeviceErrorMessage(StateError('private details')),
        isNot(contains('private details')));
  });
}
