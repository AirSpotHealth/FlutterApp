import 'package:flutter_riverpod/flutter_riverpod.dart';

final recalibrationTimeProvider = NotifierProvider.family
    .autoDispose<_RecalibrationTimeNotifier, int?, String>(
        _RecalibrationTimeNotifier.new);

class _RecalibrationTimeNotifier
    extends AutoDisposeFamilyNotifier<int?, String> {
  @override
  int? build(String arg) {
    return null;
  }

  void setRecalibrationTime(int? time) {
    state = time;
  }

  void setRecalibrationDone() {
    state = null;
  }
}
