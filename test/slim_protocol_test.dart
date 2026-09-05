import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/models/device_capabilities.dart';
import 'package:airspothealth/core/services/ble_data_service.dart';
import 'package:airspothealth/core/services/ble_device_communicator.dart';
import 'package:airspothealth/features/device_settings/providers/device_variant_provider.dart';
import 'package:airspothealth/features/device_settings/service/slim_update_verification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'slim_test_helpers.dart';

void main() {
  ResponseCommandParser parser(DeviceModel model) =>
      ResponseCommandParser(BleDevice(
          deviceId: 'test',
          name: 'AirSpot-test',
          address: 'test',
          platform: 'test',
          firmwareVersion:
              model == DeviceModel.airspotSlim ? '0.14.6' : '3.0.0',
          deviceModelValue: model.index));
  final slim = parser(DeviceModel.airspotSlim);
  test('extended live reading and legacy battery response', () {
    final reading = slim
        .parseCo2Value(frame(1, [0, 0, 0, 1, 3, 32, 0xff, 0x9c, 0x13, 0x88]));
    expect(reading.value, 800);
    expect(reading.temperature, -1);
    expect(reading.humidity, 50);
    final battery = slim.parseBatteryLevel(frame(0x20, [85, 1], length: 1));
    expect(battery.level, 85);
    expect(battery.isCharging, true);
  });
  test('Slim history uses little endian, Screen retains existing decoding', () {
    final page = frame(0x0c, [0, 0, 0, 1, 0x20, 3, 0, 0, 0, 1], length: 8);
    expect(slim.parseGetCo2History(page).single.value, 800);
    expect(
        parser(DeviceModel.airspotScreen).parseGetCo2History(page).single.value,
        8195);
    expect(slim.parseGetCo2History(frame(0x0c, [1, 2], length: 1)), 258);
  });
  test('Slim calibration correction and sensor identity', () {
    expect(
        slim.parseAscData(frame(0x25, [0, 42, 1], length: 1)).correction, -42);
    expect(
        parser(DeviceModel.airspotScreen)
            .parseAscData(frame(0x25, [0, 3, 0, 42, 0]))
            .count,
        3);
    final details = slim.parseSensorDetails(frame(
        0x30, [0, 0, 0, 0, 3, 0xf5, 0, 1, 0x90, 83, 76, 73, 77, 48, 49, 2]));
    expect(details.sensorVariant, 'STCC4');
    expect(DeviceVariant.fromValue(2), DeviceVariant.stcc4);
    expect(slim.parseCalibrateSensors(frame(0x0d, [0, 42, 1], length: 1)), -42);
    expect(slim.parseRecalibrationTime(frame(0x0f, [0, 60], length: 1)), 60);
  });
  test('post-update success requires valid fresh version and live frames', () {
    final check = SlimUpdateVerification('0.14.6');
    check.accept(frame(0x13, '0.14.5'.codeUnits));
    check.accept(frame(1, [0, 0, 0, 1, 3, 32, 0, 0, 0, 0]));
    expect(check.complete, false);
    check.accept(frame(0x13, '0.14.6'.codeUnits)..last = 0);
    expect(check.complete, false);
    check.accept(frame(0x13, '0.14.6'.codeUnits));
    expect(check.complete, true);
    check.accept(frame(1, [0, 0, 0, 0, 255, 255, 0, 0, 0, 0]));
    expect(check.complete, false);
  });
  test('suspended communicator rejects app commands and restores ownership',
      () async {
    final communicator = BleDeviceCommunicator(deviceId: 'test');
    await communicator.suspend();
    expect(await communicator.initialize(), false);
    expect(await communicator.sendCommand([1]), false);
    communicator.resume();
    expect(communicator.isSuspended, false);
    communicator.dispose();
  });
  test('DFU routing preserves Slim identity and trusts discovered SMP', () {
    expect(DeviceModel.forDfu(DeviceModel.airspotSlim, hasSmpService: false),
        DeviceModel.airspotSlim);
    expect(DeviceModel.forDfu(DeviceModel.airspotScreen, hasSmpService: true),
        DeviceModel.airspotSlim);
    expect(
        DeviceModel.forDfu(null, hasSmpService: true), DeviceModel.airspotSlim);
    expect(DeviceModel.forDfu(DeviceModel.airspotScreen, hasSmpService: false),
        DeviceModel.airspotScreen);
    expect(DeviceModel.forDfu(null, hasSmpService: false),
        DeviceModel.airspotScreen);
  });
  test('Slim local OTA enabled while Screen capabilities stay intact', () {
    expect(
        DeviceCapabilities.fromModel(DeviceModel.airspotSlim)
            .supportsDeviceUpdate(),
        true);
    expect(
        DeviceCapabilities.fromModel(DeviceModel.airspotScreen)
            .supportsDeviceUpdate(),
        true);
    expect(DeviceCapabilities.fromModel(DeviceModel.airspotSlim).hasScreen(),
        false);
  });
}
