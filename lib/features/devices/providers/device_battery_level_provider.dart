import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceBatteryLevelProvider =
    NotifierProvider.family<_DeviceBatteryLevelNotifier, int?, String>(
        _DeviceBatteryLevelNotifier.new);

class _DeviceBatteryLevelNotifier extends FamilyNotifier<int?, String> {
  String get deviceId => arg;

  @override
  int? build(arg) {
    return null;
  }

  void updateBatteryLevel(int? batteryLevel) {
    state = batteryLevel;
  }
}
