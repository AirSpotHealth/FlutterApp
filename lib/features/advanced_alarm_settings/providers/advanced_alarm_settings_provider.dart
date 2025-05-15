import 'dart:async';

import 'package:airspothealth/core/models/device_settings.dart'; // For AlarmLevel and defaultAlarmLevels
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Screen Illumination Setting Provider ---
final screenIlluminationSettingsProvider = NotifierProvider.family
    .autoDispose<ScreenIlluminationSettingNotifier, bool, String>(
  ScreenIlluminationSettingNotifier.new,
);

class ScreenIlluminationSettingNotifier
    extends AutoDisposeFamilyNotifier<bool, String> {
  bool? _initialValue;
  static const bool defaultValue = true; // Default for screen illumination

  @override
  bool build(String deviceId) {
    final currentValue =
        ref.watch(deviceSettingsProvider(deviceId)).screenOnAlarm;
    _initialValue ??= currentValue;
    return currentValue;
  }

  bool get hasUnsavedChanges => state != _initialValue;

  void setEnabled(bool enabled) {
    if (state == enabled)
      return; // Don't do anything if state is already the same
    state = enabled;
    saveSetting(); // Immediately attempt to save
  }

  Future<void> saveSetting() async {
    if (!hasUnsavedChanges) return;
    final deviceId = arg;
    try {
      debugPrint('Saving screenOnAlarm: $state for device $deviceId');
      ref.read(deviceSettingsProvider(deviceId).notifier).updateSetting(
          (settings) => settings.copyWith(screenOnAlarm: state),
          sendCommands: true);
      _initialValue = state;
      // Trigger rebuild for listeners of hasUnsavedChanges
      state = state;
    } catch (e, stackTrace) {
      debugPrint('Error saving screenOnAlarm for $deviceId: $e\n$stackTrace');
      rethrow; // Rethrow to allow UI to handle error
    }
  }

  Future<void> resetToDefault() async {
    state = defaultValue;
    await saveSetting(); // Save the default value
    _initialValue = defaultValue; // Ensure initial value is also reset
    // Trigger rebuild
    state = defaultValue;
    debugPrint('Screen illumination reset to default: $state');
  }
}

// --- Alarm on CO2 Fall Setting Provider ---
final alarmOnCo2FallSettingProvider = NotifierProvider.family
    .autoDispose<AlarmOnCo2FallSettingNotifier, bool, String>(
  AlarmOnCo2FallSettingNotifier.new,
);

class AlarmOnCo2FallSettingNotifier
    extends AutoDisposeFamilyNotifier<bool, String> {
  bool? _initialValue;
  static const bool defaultValue = false; // Default for alarm on CO2 fall

  @override
  bool build(String deviceId) {
    final currentValue =
        ref.watch(deviceSettingsProvider(deviceId)).alarmOnCo2Fall;
    _initialValue ??= currentValue;
    return currentValue;
  }

  bool get hasUnsavedChanges => state != _initialValue;

  void setEnabled(bool enabled) {
    if (state == enabled) {
      return; // Don't do anything if state is already the same
    }
    state = enabled;
    saveSetting(); // Immediately attempt to save
  }

  Future<void> saveSetting() async {
    if (!hasUnsavedChanges) return;
    final deviceId = arg;
    try {
      debugPrint('Saving alarmOnCo2Fall: $state for device $deviceId');
      ref.read(deviceSettingsProvider(deviceId).notifier).updateSetting(
          (settings) => settings.copyWith(alarmOnCo2Fall: state),
          sendCommands: true);
      _initialValue = state;
      state = state;
    } catch (e, stackTrace) {
      debugPrint('Error saving alarmOnCo2Fall for $deviceId: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> resetToDefault() async {
    state = defaultValue;
    await saveSetting();
    _initialValue = defaultValue;
    state = defaultValue;
    debugPrint('Alarm on CO2 fall reset to default: $state');
  }
}

// --- Advanced Alarm Levels Setting Provider (Modified) ---
final advancedAlarmSettingsProvider = NotifierProvider.family.autoDispose<
    AdvancedAlarmSettingsNotifier, AdvancedAlarmSettingsState, String>(
  AdvancedAlarmSettingsNotifier.new,
);

class AdvancedAlarmSettingsNotifier
    extends AutoDisposeFamilyNotifier<AdvancedAlarmSettingsState, String> {
  AdvancedAlarmSettingsState? _initialSettings;

  @override
  AdvancedAlarmSettingsState build(String deviceId) {
    final deviceSettings = ref.watch(deviceSettingsProvider(deviceId));
    // Now only concerned with alarmLevels
    final currentState = AdvancedAlarmSettingsState(
      alarmLevels: List<AlarmLevel>.from(deviceSettings.alarmLevels
          .map((level) => level.copyWith())), // Deep copy
    );
    _initialSettings ??=
        currentState.copyWith(); // Store initial state only once
    return currentState;
  }

  bool get hasUnsavedChanges {
    if (_initialSettings == null) return false;
    // Only compare alarmLevels
    if (listEquals(state.alarmLevels, _initialSettings!.alarmLevels) == false) {
      return true;
    }
    return false;
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

  Future<void> saveAllAlarmLevels() async {
    if (!hasUnsavedChanges) {
      debugPrint('No unsaved alarm level changes to save.');
      return;
    }

    final deviceId = arg;
    bool alarmLevelsUpdated = false;

    // Save individual alarm levels if changed
    for (int i = 0; i < state.alarmLevels.length; i++) {
      if (state.alarmLevels[i] != _initialSettings!.alarmLevels[i]) {
        final alarmToSave = state.alarmLevels[i];
        final command = DeviceCmdUtils.setAdvancedAlarmLevels(i, alarmToSave);
        try {
          debugPrint(
              'Sending command to save alarm level $i for device $deviceId: ${command.map((b) => b.toRadixString(16)).join(' ')}');
          await ref
              .read(bleDeviceCommunicationProvider(deviceId).notifier)
              .sendCommand(command);
          alarmLevelsUpdated = true;
        } catch (e, stackTrace) {
          debugPrint(
              'Error sending save command for alarm level $i, device $deviceId: $e\n$stackTrace');
          // Optionally, rethrow or collect errors
        }
      }
    }

    if (alarmLevelsUpdated) {
      ref.read(deviceSettingsProvider(deviceId).notifier).updateSetting(
          (settings) => settings.copyWith(
              alarmLevels: List<AlarmLevel>.from(state.alarmLevels
                  .map((l) => l.copyWith())) // ensure fresh list
              ));
    }

    _initialSettings = state.copyWith(
        alarmLevels: List<AlarmLevel>.from(
            state.alarmLevels.map((level) => level.copyWith())) // Deep copy
        );
    state = state.copyWith(); // Trigger rebuild
    debugPrint('All alarm level changes saved. Initial settings updated.');
  }

  Future<void> resetAlarmLevelsToDefaults() async {
    final deviceId = arg;
    try {
      await ref
          .read(bleDeviceCommunicationProvider(deviceId).notifier)
          .sendCommand(DeviceCmdUtils.resetAdvancedAlarmsToDefault());
      debugPrint(
          'Reset advanced settings command sent for $deviceId (assumed to reset illumination and CO2 fall too)');

      // Update local state for alarmLevels
      final defaultAlarmLevelsOnlyState = AdvancedAlarmSettingsState(
        alarmLevels:
            defaultAlarmLevels.map((level) => level.copyWith()).toList(),
      );
      state = defaultAlarmLevelsOnlyState;
      _initialSettings = defaultAlarmLevelsOnlyState
          .copyWith(); // This already deep copies alarmLevels

      // Update the main deviceSettingsProvider for ALL relevant advanced settings
      ref
          .read(deviceSettingsProvider(deviceId).notifier)
          .updateSetting((settings) => settings.copyWith(
                alarmLevels: defaultAlarmLevels
                    .map((level) => level.copyWith())
                    .toList(),
                screenOnAlarm: ScreenIlluminationSettingNotifier.defaultValue,
                alarmOnCo2Fall: AlarmOnCo2FallSettingNotifier.defaultValue,
              ));

      // Invalidate the other notifiers so they rebuild and pick up new defaults from deviceSettingsProvider
      ref.invalidate(screenIlluminationSettingsProvider(deviceId));
      ref.invalidate(alarmOnCo2FallSettingProvider(deviceId));

      debugPrint(
          'Advanced settings (levels, illumination, CO2 fall) state reset to defaults for $deviceId after master command.');
    } catch (e, stackTrace) {
      debugPrint(
          'Error sending resetAlarmLevelsToDefaults command for $deviceId: $e\n$stackTrace');
    }
  }

  // setScreenOnAlarm and setAlarmOnCo2Fall methods are removed
}

// AdvancedAlarmSettingsState only contains alarmLevels now
class AdvancedAlarmSettingsState {
  final List<AlarmLevel> alarmLevels;

  AdvancedAlarmSettingsState({
    required this.alarmLevels,
  });

  AdvancedAlarmSettingsState copyWith({
    List<AlarmLevel>? alarmLevels,
  }) {
    return AdvancedAlarmSettingsState(
      alarmLevels:
          alarmLevels ?? this.alarmLevels.map((e) => e.copyWith()).toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdvancedAlarmSettingsState &&
        listEquals(other.alarmLevels, alarmLevels);
  }

  @override
  int get hashCode => alarmLevels.hashCode;
}
