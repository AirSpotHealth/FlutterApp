import 'dart:io';
import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/features/devices/devices_page.dart';
import 'package:airspothealth/features/devices/widgets/ble_device_widget.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'ble_rediscovery_test.dart' show ScanPlatform;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  final database = IsarService();
  final platform = ScanPlatform();
  setUpAll(() async {
    directory = Directory.systemTemp.createTempSync('forget-card-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (_) async => directory.path);
    PackageInfo.setMockInitialValues(
        appName: 'AirSpot',
        packageName: 'test',
        version: '3.8.14',
        buildNumber: '162',
        buildSignature: '');
    await Isar.initialize(Platform.environment['ISAR_LIBRARY_PATH']);
    await database.initialize();
    FlutterBluePlusPlatform.instance = platform;
  });
  tearDownAll(() async {
    database.close();
    directory.deleteSync(recursive: true);
    await platform.responses.close();
    await platform.connectionChanges.close();
  });
  testWidgets('disconnected device is forgotten directly from its card',
      (tester) async {
    database.write((isar) => isar.bleDevices.put(BleDevice(
        deviceId: 'slim',
        name: 'AirSpot Test',
        address: 'slim',
        platform: 'ios',
        deviceModelValue: DeviceModel.airspotSlim.index)));
    await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: DevicesPage())));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.longPress(find.byType(BleDeviceWidget));
    await tester.pumpAndSettle();
    expect(find.text('Could not remove this device. Please try again.'),
        findsNothing);
    await tester.tap(find.widgetWithText(Button, 'Forget Device'));
    await tester.pumpAndSettle();
    expect(find.byType(BleDeviceWidget), findsNothing);
    expect(find.text('Forget Device'), findsNothing);
    database.read((isar) => expect(isar.bleDevices.get('slim'), isNull));
    expect(platform.disconnectCalls, 0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
