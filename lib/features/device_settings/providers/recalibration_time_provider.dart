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
