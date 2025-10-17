import 'dart:convert';
import 'dart:io';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/live_activity_model.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:isar/isar.dart';

/// Service responsible for managing home screen widgets
/// Handles widget data persistence and updates independently from Live Activities
class WidgetService {
  /// Singleton instance
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  /// In-memory cache of widget data for all devices
  /// This is ONLY for widgets - persisted via HomeWidget plugin
  final Map<String, LiveActivityModel> _widgetData = {};

  // MARK: - Public API

  /// Update widget with current device data
  /// This persists data via HomeWidget and triggers widget refresh
  Future<void> updateWidgetData({
    required String deviceId,
    required LiveActivityModel data,
  }) async {
    try {
      debugPrint('📱 Widget: Updating data for device: $deviceId');

      // Store in memory cache
      _widgetData[deviceId] = data;

      // Persist to shared storage for widgets
      await _persistWidgetData();

      // Trigger platform-specific widget updates
      await _triggerWidgetRefresh();

      debugPrint('✅ Widget: Updated successfully for device: $deviceId');
    } catch (e) {
      debugPrint('❌ Widget: Error updating widget data: $e');
    }
  }

  /// Update the refreshing state for a specific device widget
  /// This immediately shows/hides the refresh animation on the widget
  Future<void> setRefreshingState({
    required String deviceId,
    required bool isRefreshing,
  }) async {
    try {
      // Get existing widget data for this device
      if (!_widgetData.containsKey(deviceId)) {
        debugPrint(
            '📱 Widget: No data found for device $deviceId, cannot update refreshing state');
        return;
      }

      final currentData = _widgetData[deviceId]!;

      // Update only the refreshing state
      final updatedData = currentData.copyWith(isRefreshing: isRefreshing);
      _widgetData[deviceId] = updatedData;

      debugPrint(
          '📱 Widget: Setting refreshing state to $isRefreshing for device: $deviceId');

      // Persist to shared storage
      await _persistWidgetData();

      // Trigger widget refresh to show the animation
      await _triggerWidgetRefresh();

      debugPrint('✅ Widget: Refreshing state updated successfully');
    } catch (e) {
      debugPrint('❌ Widget: Error updating refreshing state: $e');
    }
  }

  /// Remove widget data for a specific device
  /// This immediately updates all widgets to reflect the device removal
  Future<void> removeWidgetData(String deviceId) async {
    try {
      debugPrint('📱 Widget: Removing data for device: $deviceId');

      // Remove from cache
      _widgetData.remove(deviceId);

      // Persist changes (updates widget_devices_data and widget_device_list)
      await _persistWidgetData();

      // Trigger immediate widget refresh on all platforms
      // This ensures widgets configured for this device show "No Device Connected"
      await _triggerWidgetRefresh();

      debugPrint(
          '✅ Widget: Data removed and widgets refreshed for device: $deviceId');
    } catch (e) {
      debugPrint('❌ Widget: Error removing widget data: $e');
    }
  }

  /// Clear all widget data
  Future<void> clearAllWidgetData() async {
    try {
      debugPrint('📱 Widget: Clearing all widget data');

      _widgetData.clear();
      await _persistWidgetData();
      await _triggerWidgetRefresh();

      debugPrint('✅ Widget: All data cleared');
    } catch (e) {
      debugPrint('❌ Widget: Error clearing widget data: $e');
    }
  }

  /// Get widget data for a specific device (for debugging)
  LiveActivityModel? getWidgetData(String deviceId) {
    return _widgetData[deviceId];
  }

  /// Get all widget data (for debugging)
  Map<String, LiveActivityModel> getAllWidgetData() {
    return Map.unmodifiable(_widgetData);
  }

  /// Refresh the device list in widget storage
  /// This updates the device list with current aliases without triggering a full widget refresh
  /// Useful when device aliases are updated
  Future<void> refreshDeviceList() async {
    try {
      debugPrint('📱 Widget: Refreshing device list');

      // Get ALL saved devices from database for device list
      final allSavedDevices =
          IsarService().read<List<Map<String, String>>>((isar) {
        final devices = isar.bleDevices.where().findAll();
        return devices
            .map((device) => {
                  'deviceId': device.deviceId,
                  'deviceName': device.alias ?? device.name, // Prefer alias
                })
            .toList();
      });

      // Update only the device list in shared storage
      await HomeWidget.saveWidgetData<String>(
          'widget_device_list', jsonEncode(allSavedDevices));

      debugPrint(
          '✅ Widget: Device list refreshed with ${allSavedDevices.length} device(s)');
    } catch (e) {
      debugPrint('❌ Widget: Error refreshing device list: $e');
    }
  }

  // MARK: - Private Implementation

  /// Persist all widget data to shared storage
  Future<void> _persistWidgetData() async {
    try {
      // Get ALL saved devices from database for device list
      final allSavedDevices =
          IsarService().read<List<Map<String, String>>>((isar) {
        final devices = isar.bleDevices.where().findAll();
        return devices
            .map((device) => {
                  'deviceId': device.deviceId,
                  'deviceName': device.alias ?? device.name, // Prefer alias
                })
            .toList();
      });

      // Build map of devices with data
      final Map<String, dynamic> allDevicesData = {};
      for (final entry in _widgetData.entries) {
        allDevicesData[entry.key] = entry.value.toJson();
      }

      final jsonString = jsonEncode(allDevicesData);

      debugPrint(
          '🏠 Widget: Persisting data for ${_widgetData.length} device(s)');
      debugPrint(
          '🏠 Widget: Device list contains ${allSavedDevices.length} saved device(s)');

      // Store multi-device data (primary data source for widgets)
      await HomeWidget.saveWidgetData<String>(
          'widget_devices_data', jsonString);

      // Store device list with aliases for configuration
      await HomeWidget.saveWidgetData<String>(
          'widget_device_list', jsonEncode(allSavedDevices));

      // Also store the most recent device's data for backward compatibility
      // (for widgets that haven't been configured yet)
      if (_widgetData.isNotEmpty) {
        final latestData = _widgetData.values.last.toJson();
        await HomeWidget.saveWidgetData<String>(
            'widget_data_json', jsonEncode(latestData));
      }

      debugPrint('✅ Widget: Data persisted successfully');
    } catch (e) {
      debugPrint('❌ Widget: Error persisting data: $e');
      rethrow;
    }
  }

  /// Trigger platform-specific widget refresh
  Future<void> _triggerWidgetRefresh() async {
    try {
      if (Platform.isIOS) {
        // iOS has a single widget type
        await HomeWidget.updateWidget(iOSName: Constants.iOSWidgetName);
        debugPrint('✅ Widget: iOS widget refresh triggered');
      } else if (Platform.isAndroid) {
        // Android has multiple widget sizes - update all
        await Future.wait([
          HomeWidget.updateWidget(androidName: Constants.androidWidgetCo2Small),
          HomeWidget.updateWidget(
              androidName: Constants.androidWidgetCo2Medium),
          HomeWidget.updateWidget(androidName: Constants.androidWidgetCo2Large),
        ]);
        debugPrint('✅ Widget: Android widgets refresh triggered');
      }
    } catch (e) {
      debugPrint('❌ Widget: Error triggering refresh: $e');
      rethrow;
    }
  }

  // MARK: - Debugging

  /// Print current widget state for debugging
  void debugPrintState() {
    debugPrint('==========================================');
    debugPrint('📱 WIDGET SERVICE STATE');
    debugPrint('==========================================');
    debugPrint('Total devices with data: ${_widgetData.length}');
    for (final entry in _widgetData.entries) {
      debugPrint('  Device: ${entry.key}');
      debugPrint('    Name: ${entry.value.deviceName}');
      debugPrint('    CO2: ${entry.value.co2Value}');
      debugPrint('    Connected: ${entry.value.isConnected}');
    }
    debugPrint('==========================================');
  }
}
