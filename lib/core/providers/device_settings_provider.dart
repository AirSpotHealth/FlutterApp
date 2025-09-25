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
    DeviceSettings newSettings = settings;

    if (sendCommands) {
      // check which settings are changed and send the command to the device
      if (newSettings.alarmEnabled != state.alarmEnabled) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(newSettings.alarmCmd);
      } else if (newSettings.vibrationEnabled != state.vibrationEnabled) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(newSettings.vibrationCmd);
      } else if (newSettings.powerMode != state.powerMode) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(newSettings.powerModeCmd);
      } else if (newSettings.continuosScreenEnabled !=
          state.continuosScreenEnabled) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(newSettings.continuousScreenCmd);
      } else if (newSettings.autoSyncTime != state.autoSyncTime) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(newSettings.autoSyncTimeCmd);
      } else if (newSettings.autoCalibration != state.autoCalibration) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(newSettings.autoCalibrationCmd);
      } else if (newSettings.dndEnabled != state.dndEnabled ||
          newSettings.dndStartTime != state.dndStartTime ||
          newSettings.dndEndTime != state.dndEndTime) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(newSettings.dndCmd);
      } else if (newSettings.recalibrationTarget != state.recalibrationTarget) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(DeviceCmdUtils.setRecalibrationTarget(
                newSettings.recalibrationTarget));
      } else if (newSettings.uiMode != state.uiMode ||
          newSettings.graphMaxValue != state.graphMaxValue ||
          newSettings.graphMinValue != state.graphMinValue) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(DeviceCmdUtils.setGraphMode(newSettings.uiMode.index,
                newSettings.graphMaxValue, newSettings.graphMinValue));
      } else if (newSettings.screenOnAlarm != state.screenOnAlarm) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(
                DeviceCmdUtils.setScreenOnAlarm(newSettings.screenOnAlarm));
      } else if (newSettings.alarmOnCo2Fall != state.alarmOnCo2Fall) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(
                DeviceCmdUtils.setAlarmOnCo2Fall(newSettings.alarmOnCo2Fall));
      } else if (newSettings.scaling != state.scaling) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(DeviceCmdUtils.setScaleFactor(newSettings.scaling));
        debugPrint('Scaling changed. Sending command to device.');
      } else if (newSettings.flightMode != state.flightMode) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(DeviceCmdUtils.setFlightMode(newSettings.flightMode));
      }
    }

    _isarService.write((isar) {
      isar.deviceSettings.put(newSettings);
    });

    state = newSettings;
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
