import 'dart:io';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/sensor_error_state.dart';
import 'package:airspothealth/core/services/cloud_device_identity.dart';
import 'package:airspothealth/core/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_plus/isar_plus.dart';
import 'history_coverage_test.dart' show initializeHistoryTestDatabase;

void main() {
  test('shared Slim identities are rejected before claiming or uploading', () {
    for (final identity in [
      '',
      '534C494D3031',
      '534c494d3031',
      'SLIM01',
      '000000000000',
      'FFFFFFFFFFFF',
    ]) {
      expect(() => requireUniqueCloudIdentity(identity), throwsStateError);
    }
    expect(() => requireUniqueCloudIdentity('9ABC12345678'), returnsNormally);
  });

  test('Slim faults identify the sensor without inventing recovery attempts',
      () {
    for (final code in [0x40, 0x41, 0x42, 0x43, 0x44, 0x45]) {
      final error = SensorErrorState(
          errorCode: code,
          recoveryAttempts: 3,
          isSlim: true,
          timestamp: DateTime(2026),
          deviceId: 'slim');
      expect(error.errorMessage, isNot(contains('Unknown')));
      expect(error.isRecoveryExhausted, false);
      expect(error.issueDescription, isNot(contains('3/3')));
    }
    final screen = SensorErrorState(
        errorCode: 1,
        recoveryAttempts: 3,
        timestamp: DateTime(2026),
        deviceId: 'screen');
    expect(screen.isRecoveryExhausted, true);
    expect(screen.errorMessage, 'Sensor Read Error');
  });

  group('cloud batch device isolation', () {
    late Directory directory;
    late Isar isar;
    setUpAll(initializeHistoryTestDatabase);
    setUp(() {
      directory = Directory.systemTemp.createTempSync('slim-cloud-');
      isar = Isar.open(
          schemas: [DeviceDataSchema],
          directory: directory.path,
          inspector: false);
    });
    tearDown(() {
      isar.close();
      directory.deleteSync(recursive: true);
    });
    test('uploading A never selects B, live samples, or already synced data',
        () {
      final now = DateTime(2026, 9, 16);
      final records = [
        DeviceData(deviceId: 'a', dateTime: now, value: 600),
        DeviceData(deviceId: 'b', dateTime: now, value: 900),
        DeviceData(
            deviceId: 'a',
            dateTime: now.subtract(const Duration(minutes: 1)),
            value: 700,
            isLiveCo2: true),
        DeviceData(
            deviceId: 'a',
            dateTime: now.subtract(const Duration(minutes: 2)),
            value: 800)
          ..synced = true,
      ];
      isar.write((isar) => isar.deviceDatas.putAll(records));
      final a =
          SyncService.pendingReadings(isar, sourceDeviceId: 'a', now: now);
      final b =
          SyncService.pendingReadings(isar, sourceDeviceId: 'b', now: now);
      expect(a.map((r) => r.value), [600]);
      expect(b.map((r) => r.value), [900]);
    });
  });
}
