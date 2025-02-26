import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
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
      }

      if (settings.vibrationEnabled != state.vibrationEnabled) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(settings.vibrationCmd);
      }

      if (settings.powerMode != state.powerMode) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(settings.powerModeCmd);
      }

      if (settings.continuosScreenEnabled != state.continuosScreenEnabled) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(settings.continuousScreenCmd);
      }

      if (settings.autoSyncTime != state.autoSyncTime) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(settings.autoSyncTimeCmd);
      }

      if (settings.autoCalibration != state.autoCalibration) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(settings.autoCalibrationCmd);
      }

      if (settings.dndEnabled != state.dndEnabled ||
          settings.dndStartTime != state.dndStartTime ||
          settings.dndEndTime != state.dndEndTime) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(settings.dndCmd);
      }

      if (settings.recalibrationTarget != state.recalibrationTarget) {
        ref
            .read(bleDeviceCommunicationProvider(settings.deviceId).notifier)
            .sendCommand(DeviceCmdUtils.setRecalibrationTarget(
                settings.recalibrationTarget));
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
