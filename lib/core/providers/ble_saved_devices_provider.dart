import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/widget_service.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

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
    if (state.any((d) => d.deviceId == device.deviceId)) {
      return;
    }

    ref.read(isarServiceProvider).write((isar) {
      isar.bleDevices.put(device);
    });

    state = [...state, device];
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

    // Clean up widget data for removed device
    _cleanupWidgetDataForRemovedDevice(deviceId);
  }

  /// Clean up widget data when device is removed
  void _cleanupWidgetDataForRemovedDevice(String deviceId) {
    try {
      // Import WidgetService at the top of the file
      WidgetService().removeWidgetData(deviceId);
      debugPrint('✅ Cleaned up widget data for removed device: $deviceId');
    } catch (e) {
      debugPrint('❌ Error cleaning up widget data for device $deviceId: $e');
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
        // No existing data, but we should still update the device list
        // This is handled automatically by _persistWidgetData() reading from database
        debugPrint(
            '⚠️ No widget data found for $deviceId, device list will update on next data');
      }
    } catch (e) {
      debugPrint('❌ Error updating widget with new alias: $e');
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
