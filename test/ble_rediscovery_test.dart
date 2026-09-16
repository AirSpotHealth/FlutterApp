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
    final results = <List<String>>[];
    StreamSubscription<List<BluetoothDevice>>? subscription;
    try {
      database.write((isar) => isar.bleDevices.putAll([
            for (final id in ['slim', 'screen'])
              BleDevice(deviceId: id, name: id, address: id, platform: 'ios'),
          ]));
      subscription = BLEService.instance.scanResults().listen((devices) =>
          results.add(devices.map((d) => d.remoteId.str).toList()));
      await FlutterBluePlus.startScan();
      platform.advertise();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(results.last, isEmpty);

      database.write((isar) => isar.bleDevices.delete('slim'));
      platform.advertise();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(results.last, ['slim']);
    } finally {
      await FlutterBluePlus.stopScan();
      await subscription?.cancel();
      await platform.responses.close();
      database.close();
      directory.deleteSync(recursive: true);
    }
  });
}
