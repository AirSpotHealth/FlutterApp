import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceSensorResetProvider = NotifierProvider.family<
    _DevicerSensorResetNotifier,
    AsyncProgressValue,
    String>(_DevicerSensorResetNotifier.new);

class _DevicerSensorResetNotifier
    extends FamilyNotifier<AsyncProgressValue, String> {
  @override
  AsyncProgressValue build(String arg) {
    return AsyncNone();
  }

  void resetSensor() {
    if (state is AsyncInProgress) return;

    state = AsyncInProgress(0, message: 'Resetting sensor...');
    ref
        .read(bleDeviceCommunicationProvider(arg).notifier)
        .sendCommand(DeviceCmdUtils.resetSensor());
  }

  void setSensorResetDone() {
    state = AsyncSuccess(null);
  }

  void setSensorResetFailed(String message) {
    state = AsyncFailure(message);
  }
}
