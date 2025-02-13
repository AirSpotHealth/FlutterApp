import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
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

  void startRecalibration(int calibTarget) {
    state = AsyncInProgress(-1, message: 'Starting recalibration...');
    ref
        .read(bleDeviceCommunicationProvider(arg).notifier)
        .sendCommand(DeviceCmdUtils.startRecalibration(calibTarget));
  }

  void setRecalibrationTime(int? time) {
    if (time == null) {
      state = AsyncNone();
    } else {
      state = AsyncInProgress(time.toDouble());
    }
  }

  void setRecalibrationDone(int frc) {
    state = AsyncSuccess(frc);
  }
}
