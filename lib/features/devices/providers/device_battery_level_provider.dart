import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceBatteryLevelProvider =
    NotifierProvider.family<_DeviceBatteryLevelNotifier, BatteryState, String>(
        _DeviceBatteryLevelNotifier.new);

class _DeviceBatteryLevelNotifier extends FamilyNotifier<BatteryState, String> {
  String get deviceId => arg;

  @override
  BatteryState build(arg) {
    return BatteryState(null, false);
  }

  void updateBatteryLevel(BatteryState batteryLevel) {
    state = batteryLevel;
  }
}

class BatteryState {
  final int? level;
  final bool isCharging;

  const BatteryState(this.level, this.isCharging);

  BatteryState copyWith({int? level, bool? isCharging}) {
    return BatteryState(level ?? this.level, isCharging ?? this.isCharging);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BatteryState &&
        other.level == level &&
        other.isCharging == isCharging;
  }

  @override
  int get hashCode => level.hashCode ^ isCharging.hashCode;

  @override
  String toString() => 'BatteryState(level: $level, isCharging: $isCharging)';
}
