import 'dart:math';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

const _standardPressure = 1013.25; // Standard sea level pressure in hPa

double calculatePressureFromAltitude(double altitude) {
  if (altitude == 0) return _standardPressure;
  return _standardPressure * pow(1 - altitude / 44330, 5.255);
}

double calculateAltitudeFromPressure(double pressure) {
  if (pressure == _standardPressure) return 0;
  return (1 - pow(pressure / _standardPressure, 1 / 5.255)) * 44330;
}

double calculateScalingFromPressure(double pressure) {
  return 1013.0 / pressure;
}

double calculatePressureFromScaling(double scaling) {
  return 1013.0 / scaling;
}

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

    // Recalculate if one of the altitude/pressure/scaling values changed
    if (settings.altitude != state.altitude) {
      final newPressure = calculatePressureFromAltitude(settings.altitude);
      final newScaling = calculateScalingFromPressure(newPressure);
      newSettings = newSettings.copyWith(
        pressure: newPressure,
        scaling: newScaling,
      );
    } else if (settings.pressure != state.pressure) {
      final newAltitude = calculateAltitudeFromPressure(settings.pressure);
      final newScaling = calculateScalingFromPressure(settings.pressure);
      newSettings = newSettings.copyWith(
        altitude: newAltitude,
        scaling: newScaling,
      );
    } else if (settings.scaling != state.scaling) {
      final newPressure = calculatePressureFromScaling(settings.scaling);
      final newAltitude = calculateAltitudeFromPressure(newPressure);
      newSettings = newSettings.copyWith(
        pressure: newPressure,
        altitude: newAltitude,
      );
    }

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
      } else if (newSettings.altitude != state.altitude ||
          newSettings.pressure != state.pressure ||
          newSettings.scaling != state.scaling) {
        ref
            .read(bleDeviceCommunicationProvider(newSettings.deviceId).notifier)
            .sendCommand(DeviceCmdUtils.setAltitudePressureScaling(
                newSettings.altitude.toInt(),
                newSettings.pressure.toInt(),
                newSettings.scaling.toInt()));
        debugPrint(
            'Altitude/Pressure/Scaling changed. Sending command to device.');
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
