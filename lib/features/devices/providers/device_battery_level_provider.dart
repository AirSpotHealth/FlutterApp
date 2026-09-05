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

  /// True when the device has entered low-battery lockout: it is shutting down
  /// BLE/sensors and will only resume after charging back up. The app should
  /// show a "low battery — charging required" state, not a disconnect error.
  final bool lowBatteryLockout;

  const BatteryState(this.level, this.isCharging,
      {this.lowBatteryLockout = false});

  BatteryState copyWith(
      {int? level, bool? isCharging, bool? lowBatteryLockout}) {
    return BatteryState(
      level ?? this.level,
      isCharging ?? this.isCharging,
      lowBatteryLockout: lowBatteryLockout ?? this.lowBatteryLockout,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BatteryState &&
        other.level == level &&
        other.isCharging == isCharging &&
        other.lowBatteryLockout == lowBatteryLockout;
  }

  @override
  int get hashCode =>
      level.hashCode ^ isCharging.hashCode ^ lowBatteryLockout.hashCode;

  @override
  String toString() =>
      'BatteryState(level: $level, isCharging: $isCharging, '
      'lowBatteryLockout: $lowBatteryLockout)';
}
