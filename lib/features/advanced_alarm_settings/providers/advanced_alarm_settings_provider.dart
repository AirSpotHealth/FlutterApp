import 'dart:async';

import 'package:airspothealth/core/models/device_settings.dart'; // For AlarmLevel and defaultAlarmLevels
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final advancedAlarmSettingsProvider = NotifierProvider.family.autoDispose<
    AdvancedAlarmSettingsNotifier, AdvancedAlarmSettingsState, String>(
  AdvancedAlarmSettingsNotifier.new,
);

class AdvancedAlarmSettingsNotifier
    extends AutoDisposeFamilyNotifier<AdvancedAlarmSettingsState, String> {
  @override
  AdvancedAlarmSettingsState build(String deviceId) {
    final deviceSettings = ref.watch(deviceSettingsProvider(deviceId));
    return AdvancedAlarmSettingsState(
      alarmLevels: deviceSettings.alarmLevels,
      screenOnAlarm: deviceSettings.screenOnAlarm,
      alarmOnCo2Fall: deviceSettings.alarmOnCo2Fall,
    );
  }

  void updateLocalAlarmLevel(int index,
      {int? co2Threshold, int? repeatCount, bool? enabled}) {
    final currentData = state;

    final currentLevel = currentData.alarmLevels[index];
    final updatedLevel = currentLevel.copyWith(
      co2Threshold: co2Threshold ?? currentLevel.co2Threshold,
      repeatCount: repeatCount ?? currentLevel.repeatCount,
      enabled: enabled ?? currentLevel.enabled,
    );

    final updatedList = List<AlarmLevel>.from(currentData.alarmLevels);
    updatedList[index] = updatedLevel;

    state = currentData.copyWith(alarmLevels: updatedList);
  }

  Future<void> saveSingleAlarmLevel(int index) async {
    final deviceId = arg;
    final alarmToSave = state.alarmLevels[index];

    final command = DeviceCmdUtils.setAdvancedAlarmLevels(index, alarmToSave);
    try {
      debugPrint(
          'Sending command to save alarm level $index for device $deviceId: ${command.map((b) => b.toRadixString(16)).join(' ')}');
      await ref
          .read(bleDeviceCommunicationProvider(deviceId).notifier)
          .sendCommand(command);

      ref
          .read(deviceSettingsProvider(deviceId).notifier)
          .updateSetting((settings) {
        return settings.copyWith(alarmLevels: state.alarmLevels);
      });
    } catch (e, stackTrace) {
      debugPrint(
          'Error sending saveSingleAlarmLevel command for $deviceId, index $index: $e\n$stackTrace');
    }
  }

  Future<void> resetToDefaults() async {
    final deviceId = arg;
    try {
      await ref
          .read(bleDeviceCommunicationProvider(deviceId).notifier)
          .sendCommand(DeviceCmdUtils.resetAdvancedAlarmsToDefault());
      debugPrint('Reset to defaults command sent for $deviceId');

      state = AdvancedAlarmSettingsState(
        alarmLevels: defaultAlarmLevels,
        screenOnAlarm: true,
        alarmOnCo2Fall: false,
      );

      ref
          .read(bleDeviceCommunicationProvider(deviceId).notifier)
          .sendCommand(DeviceCmdUtils.getInitialData());
    } catch (e, stackTrace) {
      debugPrint(
          'Error sending resetToDefaults command for $deviceId: $e\n$stackTrace');
    }
  }

  void setScreenOnAlarm(bool enabled) {
    final deviceId = arg;
    ref.read(deviceSettingsProvider(deviceId).notifier).updateSetting(
        (deviceSettings) => deviceSettings.copyWith(screenOnAlarm: enabled),
        sendCommands: true);
  }

  void setAlarmOnCo2Fall(bool enabled) {
    final deviceId = arg;
    ref.read(deviceSettingsProvider(deviceId).notifier).updateSetting(
        (deviceSettings) => deviceSettings.copyWith(alarmOnCo2Fall: enabled),
        sendCommands: true);
  }
}

class AdvancedAlarmSettingsState {
  final List<AlarmLevel> alarmLevels;
  final bool screenOnAlarm;
  final bool alarmOnCo2Fall;

  AdvancedAlarmSettingsState({
    required this.alarmLevels,
    required this.screenOnAlarm,
    required this.alarmOnCo2Fall,
  });

  AdvancedAlarmSettingsState copyWith({
    List<AlarmLevel>? alarmLevels,
    bool? screenOnAlarm,
    bool? alarmOnCo2Fall,
  }) {
    return AdvancedAlarmSettingsState(
      alarmLevels: alarmLevels ?? this.alarmLevels,
      screenOnAlarm: screenOnAlarm ?? this.screenOnAlarm,
      alarmOnCo2Fall: alarmOnCo2Fall ?? this.alarmOnCo2Fall,
    );
  }
}
