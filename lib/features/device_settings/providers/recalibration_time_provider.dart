import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/features/device_settings/models/native_asc_state.dart';
import 'package:airspothealth/features/device_settings/providers/native_asc_provider.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recalibrationTimeProvider = NotifierProvider.family
    .autoDispose<_RecalibrationTimeNotifier, AsyncProgressValue, String>(
        _RecalibrationTimeNotifier.new);

class _RecalibrationTimeNotifier
    extends AutoDisposeFamilyNotifier<AsyncProgressValue, String> {
  @override
  AsyncProgressValue build(String arg) {
    return AsyncNone();
  }

  void startRecalibration() {
    final device = ref.read(bleDeviceProvider(arg));
    if (device.deviceModel == DeviceModel.airspotSlim &&
        !NativeAscState.canCalibrate(
            device.firmwareVersion,
            NativeAscState.supported(device.firmwareVersion)
                ? ref.read(nativeAscProvider(arg)).asData?.value
                : null)) {
      state = const AsyncFailure(
          'Confirm the sensor calibration setting before starting. Reconnect and retry if it cannot be verified.');
      return;
    }
    if (ref.read(bleDeviceConnectionProvider(arg)) !=
        BluetoothBondState.bonded) {
      state = const AsyncFailure('Connect to the device before calibrating');
      return;
    }
    state = AsyncInProgress(-1, message: 'Starting recalibration...');
    ref
        .read(bleDeviceCommunicationProvider(arg).notifier)
        .sendCommand(DeviceCmdUtils.startRecalibration());
  }

  void setRecalibrationTime(int? time) {
    if (time == null) {
      state = AsyncNone();
    } else if (time == 0) {
      state = AsyncInProgress(-1, message: 'Finalizing calibration...');
    } else {
      state = AsyncInProgress(time.toDouble());
    }
  }

  void setRecalibrationFailed(String message) {
    state = AsyncFailure(message);
  }

  void setRecalibrationDone(int frc) {
    state = AsyncSuccess(frc);
  }
}
