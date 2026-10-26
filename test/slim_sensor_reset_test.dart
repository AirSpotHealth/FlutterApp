import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_settings/models/native_asc_state.dart';
import 'package:airspothealth/features/device_settings/providers/device_reset_sensor_provider.dart';
import 'package:airspothealth/features/device_settings/providers/native_asc_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'native_asc_test.dart' show ControlledNativeAsc, response;
import 'slim_test_helpers.dart' show frame;

void main() {
  for (final model in [null, DeviceModel.unknown.index]) {
    test('unidentified model $model cannot fall back to a legacy reset',
        () async {
      final sent = <List<int>>[];
      final container = ProviderContainer(overrides: [
        bleDeviceProvider('unknown').overrideWithValue(BleDevice(
            deviceId: 'unknown',
            name: 'AirSpot',
            address: 'test',
            platform: 'test',
            firmwareVersion: '0.19.0',
            deviceModelValue: model)),
        sensorResetCommandSenderProvider('unknown')
            .overrideWithValue((command) async {
          sent.add(command);
          return true;
        }),
      ]);
      addTearDown(container.dispose);
      await container
          .read(deviceSensorResetProvider('unknown').notifier)
          .resetSensor();
      expect(sent, isEmpty);
      expect(
          container.read(deviceSensorResetProvider('unknown')).isFailure, true);
    });
  }
  for (final mode in [0, 1, 2]) {
    test('ordinary restart never erases calibration in ASC mode $mode',
        () async {
      final sent = <List<int>>[];
      final container = ProviderContainer(overrides: [
        bleDeviceProvider('slim').overrideWithValue(BleDevice(
            deviceId: 'slim',
            name: 'Slim',
            address: 'test',
            platform: 'test',
            firmwareVersion: '0.19.0',
            deviceModelValue: DeviceModel.airspotSlim.index)),
        nativeAscProvider.overrideWith(() => ControlledNativeAsc(
            AsyncData(NativeAscState.fromFrame(response(mode))))),
        sensorResetCommandSenderProvider('slim')
            .overrideWithValue((command) async {
          sent.add(command);
          return true;
        }),
      ]);
      addTearDown(container.dispose);
      await container
          .read(deviceSensorResetProvider('slim').notifier)
          .resetSensor();
      expect(sent.single, DeviceCmdUtils.resetSensor());
      expect(sent.single, isNot(DeviceCmdUtils.resetNativeCalibration()));
    });
  }
  for (final outcome in ['success', 'error', 'send-failed']) {
    test('explicit erase dispatches dedicated command and handles $outcome',
        () async {
      final sent = <List<int>>[];
      final container = ProviderContainer(overrides: [
        bleDeviceProvider('slim').overrideWithValue(BleDevice(
            deviceId: 'slim',
            name: 'Slim',
            address: 'test',
            platform: 'test',
            firmwareVersion: '0.19.0',
            deviceModelValue: DeviceModel.airspotSlim.index)),
        nativeAscProvider.overrideWith(() => ControlledNativeAsc(
            AsyncData(NativeAscState.fromFrame(response(2))))),
        sensorResetCommandSenderProvider('slim')
            .overrideWithValue((command) async {
          sent.add(command);
          return outcome != 'send-failed';
        }),
      ]);
      addTearDown(container.dispose);
      final provider = deviceSensorResetProvider('slim');
      final notifier = container.read(provider.notifier);
      await notifier.resetSensor(eraseCalibration: true);
      expect(sent.single, DeviceCmdUtils.resetNativeCalibration());
      if (outcome == 'send-failed') {
        expect(container.read(provider).isFailure, true);
        return;
      }
      expect(container.read(provider).isInProgress, true);
      await notifier.resetSensor(eraseCalibration: true);
      expect(sent.length, 1);
      notifier.setSensorResetDone(1); // Wrong command cannot acknowledge erase.
      notifier.receiveNativeReset(frame(0x3a, [0, 0])..last ^= 1);
      notifier.receiveNativeReset(
          frame(0x3a, List.filled(9, 0))); // Diagnostic, not ACK.
      expect(container.read(provider).isInProgress, true);
      notifier.receiveNativeReset(
          frame(0x3a, outcome == 'success' ? [0, 0] : [255, 251]));
      expect(container.read(provider).isSuccess, outcome == 'success');
      expect(container.read(provider).isFailure, outcome == 'error');
      expect(sent.last, DeviceCmdUtils.getInitialData());
    });
  }
}
