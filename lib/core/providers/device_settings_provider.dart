import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final deviceSettingsProvider =
    NotifierProvider.family<_DeviceSettingsNotifier, DeviceSettings, String>(
        _DeviceSettingsNotifier.new);

class _DeviceSettingsNotifier extends FamilyNotifier<DeviceSettings, String> {
  final IsarService _isarService = IsarService();

  @override
  DeviceSettings build(String arg) {
    final setting = _isarService.read<DeviceSettings?>((isar) {
      return isar.deviceSettings.where().deviceIdEqualTo(arg).findFirst();
    });

    if (setting == null) {
      return DeviceSettings.empty(deviceId: arg);
    }

    debugPrint('SETTING: ${setting.toJson()}');

    return setting;
  }

  void updateSetting(
    DeviceSettings Function(DeviceSettings settings) update, {
    bool sendCommands = false,
  }) {
    final settings = update(state);
    updateSettings(settings, sendCommands: sendCommands);
  }

  void updateSettings(DeviceSettings settings, {bool sendCommands = true}) {
    if (sendCommands) {
      // check which settings are changed and send the command to the device
      if (settings.alarmEnabled != state.alarmEnabled) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(settings.alarmCmd);
      } else if (settings.vibrationEnabled != state.vibrationEnabled) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(settings.vibrationCmd);
      } else if (settings.powerMode != state.powerMode) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(settings.powerModeCmd);
      } else if (settings.continuosScreenEnabled !=
          state.continuosScreenEnabled) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(settings.continuousScreenCmd);
      } else if (settings.autoSyncTime != state.autoSyncTime) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(settings.autoSyncTimeCmd);
      } else if (settings.autoCalibration != state.autoCalibration) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(settings.autoCalibrationCmd);
      } else if (settings.dndEnabled != state.dndEnabled ||
          settings.dndStartTime != state.dndStartTime ||
          settings.dndEndTime != state.dndEndTime) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(settings.dndCmd);
      } else if (settings.recalibrationTarget != state.recalibrationTarget) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(DeviceCmdUtils.setRecalibrationTarget(
                settings.recalibrationTarget));
      } else if (settings.uiMode != state.uiMode ||
          settings.graphMaxValue != state.graphMaxValue ||
          settings.graphMinValue != state.graphMinValue) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(DeviceCmdUtils.setGraphMode(settings.uiMode.index,
                settings.graphMaxValue, settings.graphMinValue));
      } else if (settings.screenOnAlarm != state.screenOnAlarm) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(
                DeviceCmdUtils.setScreenOnAlarm(settings.screenOnAlarm));
      } else if (settings.alarmOnCo2Fall != state.alarmOnCo2Fall) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(
                DeviceCmdUtils.setAlarmOnCo2Fall(settings.alarmOnCo2Fall));
      }
    }

    _isarService.write((isar) {
      isar.deviceSettings.put(settings);
    });

    state = settings;
  }

  void removeSettings() {
    _isarService.write((isar) {
      isar.deviceSettings.delete(arg);
    });
  }

  void updateDevice(BleDevice device) {
    _isarService.write((isar) {
      _isarService.bleDevices.put(device);
    });
  }
}
