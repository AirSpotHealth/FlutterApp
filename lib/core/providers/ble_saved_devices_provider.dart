import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/live_activity_service.dart';
import 'package:airspothealth/core/services/widget_service.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

final bleSavedDevicesProvider =
    NotifierProvider<_BleSavedDevicesNotifier, List<BleDevice>>(
        _BleSavedDevicesNotifier.new);

class _BleSavedDevicesNotifier extends Notifier<List<BleDevice>> {
  final IsarService _isarService = IsarService();

  @override
  List<BleDevice> build() {
    final List<BleDevice> connectedDevices = [];

    _isarService.read((isar) {
      connectedDevices.addAll(isar.bleDevices.where().findAll());
    });

    return connectedDevices;
  }

  void addDevice(BleDevice device) {
    // check if device already exists
    final existingDevice = state.firstWhereOrNull((d) => d.deviceId == device.deviceId);
    if (existingDevice != null) {
      // If device exists but doesn't have a model set, update it
      if (existingDevice.deviceModel == null && device.deviceModel != null) {
        final updatedDevice = existingDevice.copyWith(deviceModel: device.deviceModel);
        ref.read(isarServiceProvider).write((isar) {
          isar.bleDevices.put(updatedDevice);
        });
        state = state.map((d) => d.deviceId == device.deviceId ? updatedDevice : d).toList();
      }
      return;
    }

    // Detect device model if not already set
    final deviceWithModel = device.deviceModel == null
        ? device.copyWith(deviceModel: DeviceModel.fromDeviceName(device.name))
        : device;

    ref.read(isarServiceProvider).write((isar) {
      isar.bleDevices.put(deviceWithModel);
    });

    state = [...state, deviceWithModel];
  }

  void removeDeviceById(String deviceId) {
    // check if device exists
    if (!state.any((d) => d.deviceId == deviceId)) {
      return;
    }

    ref.read(isarServiceProvider).write((isar) {
      isar.bleDevices.delete(deviceId);
      isar.deviceSettings.where().deviceIdEqualTo(deviceId).deleteAll();
      isar.deviceDatas.where().deviceIdEqualTo(deviceId).deleteAll();
    });

    state = state.where((d) => d.deviceId != deviceId).toList();

    // Clean up both widget data AND live activity for removed device
    _cleanupForRemovedDevice(deviceId);
  }

  /// Clean up widget data and live activity when device is removed/forgotten
  void _cleanupForRemovedDevice(String deviceId) {
    try {
      debugPrint('🧹 Starting cleanup for removed device: $deviceId');

      // 1. Remove Live Activity/notification if it exists
      LiveActivityService().removeDeviceLiveActivity(deviceId);
      debugPrint('✅ Live Activity removed for device: $deviceId');

      // 2. Clear all callbacks for this device
      LiveActivityService().clearAllDeviceCallbacks(deviceId);
      debugPrint('✅ Live Activity callbacks cleared for device: $deviceId');

      // 3. Clear stored Live Activity data
      LiveActivityService().clearDeviceData(deviceId);
      debugPrint('✅ Live Activity data cleared for device: $deviceId');

      // 4. Remove widget data (this also updates widget device list)
      WidgetService().removeWidgetData(deviceId);
      debugPrint('✅ Widget data removed for device: $deviceId');

      debugPrint('✅ Complete cleanup finished for removed device: $deviceId');
    } catch (e) {
      debugPrint('❌ Error during cleanup for device $deviceId: $e');
    }
  }

  void updateDeviceAlias(String deviceId, String alias) {
    // check if device exists
    if (!state.any((d) => d.deviceId == deviceId)) {
      return;
    }

    final device =
        state.firstWhere((d) => d.deviceId == deviceId).copyWith(alias: alias);

    ref
        .read(bleDeviceCommunicationProvider(deviceId).notifier)
        .sendCommand(DeviceCmdUtils.setAlias(alias));

    ref.read(isarServiceProvider).write((isar) {
      isar.bleDevices.put(device);
    });

    state =
        state.map((d) => d.deviceId == device.deviceId ? device : d).toList();

    ref.invalidate(bleDeviceProvider(deviceId));

    // Update widget with new alias - this updates the device list
    _updateWidgetWithNewAlias(deviceId, alias);
  }

  /// Update widget data when alias changes
  void _updateWidgetWithNewAlias(String deviceId, String alias) {
    try {
      // Get current widget data for this device
      final currentData = WidgetService().getWidgetData(deviceId);
      if (currentData != null) {
        // Update with new alias
        WidgetService().updateWidgetData(
          deviceId: deviceId,
          data: currentData.copyWith(deviceName: alias),
        );
        debugPrint('✅ Updated widget with new alias for device: $deviceId');
      } else {
        // No existing widget data, but still refresh the device list
        WidgetService().refreshDeviceList();
        debugPrint(
            '✅ Refreshed device list with new alias for device: $deviceId');
      }

      // Also update Live Activity with new alias if it's active
      _updateLiveActivityWithNewAlias(deviceId, alias);
    } catch (e) {
      debugPrint('❌ Error updating widget with new alias: $e');
    }
  }

  /// Update Live Activity with new alias when it changes
  void _updateLiveActivityWithNewAlias(String deviceId, String alias) {
    try {
      debugPrint(
          '🔄 Updating Live Activity alias for device: $deviceId, new alias: $alias');

      // Check if Live Activity is active for this device
      if (LiveActivityService().isDeviceActive(deviceId)) {
        debugPrint('✅ Live Activity is active for device: $deviceId');

        // Get the current Live Activity data
        final currentData = LiveActivityService().getLastDeviceData(deviceId);
        if (currentData != null) {
          debugPrint(
              '📊 Current Live Activity data - deviceName: ${currentData.deviceName}, new alias: $alias');

          // Update with new alias
          final updatedData = currentData.copyWith(deviceName: alias);

          debugPrint(
              '🔄 Updating Live Activity with new deviceName: ${updatedData.deviceName}');

          // Update the Live Activity immediately with new alias
          LiveActivityService().updateLiveActivity(
            deviceId: deviceId,
            data: updatedData,
          );
          debugPrint(
              '✅ Updated Live Activity with new alias for device: $deviceId');
        } else {
          debugPrint(
              '⚠️ Live Activity is active but no data found for device: $deviceId');
        }
      } else {
        debugPrint(
            'ℹ️ Live Activity not active for device: $deviceId, skipping alias update');
      }
    } catch (e) {
      debugPrint('❌ Error updating Live Activity with new alias: $e');
    }
  }

  void reloadDevices() {
    state = build();
  }

  void resetDeviceFetchTime(String deviceId) {
    final device = state.firstWhereOrNull((d) => d.deviceId == deviceId);

    if (device == null) {
      return;
    }

    ref.read(isarServiceProvider).write((isar) {
      isar.bleDevices.put(device.copyWith(
        lastFetchedStartDate: null,
        lastFetchedEndDate: null,
      ));
    });

    state =
        state.map((d) => d.deviceId == device.deviceId ? device : d).toList();
  }

  BleDevice? getDeviceById(String deviceId) =>
      state.firstWhereOrNull((d) => d.deviceId == deviceId);
}
