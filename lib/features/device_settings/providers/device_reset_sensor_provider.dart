import 'dart:async';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_settings/models/slim_sensor_reset.dart';
import 'package:airspothealth/features/device_settings/models/slim_settling_state.dart';
import 'package:airspothealth/features/device_settings/providers/slim_settling_provider.dart';
import 'package:airspothealth/features/device_settings/providers/native_asc_provider.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sensorResetCommandSenderProvider =
    Provider.family<Future<bool> Function(List<int>), String>((ref, deviceId) =>
        (command) => ref
            .read(bleDeviceCommunicationProvider(deviceId).notifier)
            .sendCommand(command));

final deviceSensorResetProvider = NotifierProvider.family<
    _DevicerSensorResetNotifier,
    AsyncProgressValue,
    String>(_DevicerSensorResetNotifier.new);

class _DevicerSensorResetNotifier
    extends FamilyNotifier<AsyncProgressValue, String> {
  Timer? _timeout;
  bool _nativeReset = false;
  bool _disposed = false;
  int _generation = 0;

  @override
  AsyncProgressValue build(String arg) {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _timeout?.cancel();
    });
    return AsyncNone();
  }

  Future<void> resetSensor({bool eraseCalibration = false}) async {
    if (state is AsyncInProgress) return;
    final device = ref.read(bleDeviceProvider(arg));
    _nativeReset = false;
    if (device.deviceModel != DeviceModel.airspotSlim &&
        device.deviceModel != DeviceModel.airspotScreen) {
      state = const AsyncFailure(
          'Wait for the device model to be identified before resetting.');
      return;
    }
    if (device.deviceModel == DeviceModel.airspotSlim) {
      if (!SlimSettlingState.supported(device.firmwareVersion)) {
        state = const AsyncFailure(
            'Update Slim firmware to 0.19.0 or later for separate restart and calibration erase actions.');
        return;
      }
      _nativeReset = eraseCalibration;
    }
    final generation = ++_generation;
    state = AsyncInProgress(0, message: 'Resetting sensor...');
    _timeout?.cancel();
    _timeout = Timer(const Duration(seconds: 30), () {
      if (!_disposed && generation == _generation && state is AsyncInProgress) {
        state = const AsyncFailure(
            'No reset confirmation received. Reconnect and check the sensor before retrying.');
      }
    });
    try {
      final sent = await ref.read(sensorResetCommandSenderProvider(arg))(
          _nativeReset
              ? DeviceCmdUtils.resetNativeCalibration()
              : DeviceCmdUtils.resetSensor());
      if (!sent &&
          !_disposed &&
          generation == _generation &&
          state is AsyncInProgress) {
        setSensorResetFailed(
            'Connect to the device and finish any firmware update before resetting.');
      }
    } catch (_) {
      if (!_disposed && generation == _generation && state is AsyncInProgress) {
        setSensorResetFailed(
            'Could not confirm the reset. Reconnect and check the sensor before retrying.');
      }
    }
  }

  void receiveNativeReset(List<int> frame) {
    if (!_nativeReset || state is! AsyncInProgress) return;
    final error = SlimSensorReset.acknowledgement(frame);
    if (error == null) return;
    _timeout?.cancel();
    state = error == 0
        ? AsyncSuccess(1)
        : AsyncFailure('Internal calibration reset failed (error $error).');
    ref.read(nativeAscProvider(arg).notifier).refresh();
    if (ref.exists(slimSettlingProvider(arg))) {
      ref.read(slimSettlingProvider(arg).notifier).refresh();
    }
    ref.read(sensorResetCommandSenderProvider(arg))(
        DeviceCmdUtils.getInitialData());
  }

  void setSensorResetDone(int value) {
    if (_nativeReset || state is! AsyncInProgress) return;
    _timeout?.cancel();
    final isSlim = ref
            .read(bleSavedDevicesProvider.notifier)
            .getDeviceById(arg)
            ?.deviceModel ==
        DeviceModel.airspotSlim;
    if (isSlim) {
      state = value == 1
          ? AsyncSuccess(value)
          : const AsyncFailure('Sensor reset failed. Reconnect and try again.');
      // Slim returns operation status, not the auto-calibration preference.
      ref.read(sensorResetCommandSenderProvider(arg))(
          DeviceCmdUtils.getInitialData());
      return;
    }
    state = AsyncSuccess(value);

    ref.read(deviceSettingsProvider(arg).notifier).updateSetting(
          (settings) => settings.copyWith(
            autoCalibration: value == 0 ? false : true,
          ),
        );
  }

  void setSensorResetFailed(String message) {
    _timeout?.cancel();
    state = AsyncFailure(message);
  }
}
