import 'dart:async';

import 'package:airspothealth/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

/// Data class for widget update parameters
class WidgetUpdateData {
  final String deviceId;
  final String co2Value;
  final String deviceName;
  final String powerMode;
  final String batteryLevel;
  final bool isCharging;
  final bool alarmEnabled;
  final bool vibrationEnabled;

  WidgetUpdateData({
    required this.deviceId,
    required this.co2Value,
    required this.deviceName,
    required this.powerMode,
    required this.batteryLevel,
    required this.isCharging,
    required this.alarmEnabled,
    required this.vibrationEnabled,
  });
}

@pragma("vm:entry-point")
Future<void> _backgroundCallback(Uri? uri) async {
  debugPrint('Widget callback triggered: $uri');

  if (uri?.host == 'refresh') {
    // Handle refresh action
    debugPrint('Widget refresh action triggered');

    // Extract device ID from query parameters
    String? deviceId = uri?.queryParameters['deviceId'];
    debugPrint('Device ID from widget refresh: $deviceId');

    if (deviceId != null && deviceId.isNotEmpty) {
      // TODO: Send refresh command to the specific device
      // You can implement the actual refresh logic here
      // For example: BleDeviceCommunicationProvider.sendRefreshCommand(deviceId);
      debugPrint('Sending refresh command to device: $deviceId');
    } else {
      debugPrint('No device ID provided for refresh action');
    }
  }
}

class HomeWidgetService {
  // singleton
  static final HomeWidgetService _instance = HomeWidgetService._internal();
  factory HomeWidgetService() => _instance;
  HomeWidgetService._internal();

  static HomeWidgetService get instance => _instance;

  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(Constants.appGroupId);

    HomeWidget.registerInteractivityCallback(_backgroundCallback);
  }

  /// Top-level function to update the home widget with actual values.
  /// This is designed to be called from anywhere, including background isolates.
  Future<void> updateHomeWidget({WidgetUpdateData? data}) async {
    try {
      if (data == null) {
        // No data provided - show default state
        await HomeWidget.saveWidgetData(Constants.homeWidgetKey, '----');
        await HomeWidget.saveWidgetData('device_id', '');
        await HomeWidget.saveWidgetData('device_name', 'No Device');
        await HomeWidget.saveWidgetData('power_mode', 'Now');
        await HomeWidget.saveWidgetData('battery_level', '0');
        await HomeWidget.saveWidgetData('is_charging', 'false');
        await HomeWidget.saveWidgetData('alarm_enabled', 'false');
        await HomeWidget.saveWidgetData('vibration_enabled', 'false');
      } else {
        // Save all widget data from provided values
        await HomeWidget.saveWidgetData(Constants.homeWidgetKey, data.co2Value);
        await HomeWidget.saveWidgetData('device_id', data.deviceId);
        await HomeWidget.saveWidgetData('device_name', data.deviceName);
        await HomeWidget.saveWidgetData('power_mode', data.powerMode);
        await HomeWidget.saveWidgetData('battery_level', data.batteryLevel);
        await HomeWidget.saveWidgetData(
            'is_charging', data.isCharging.toString());
        await HomeWidget.saveWidgetData(
            'alarm_enabled', data.alarmEnabled.toString());
        await HomeWidget.saveWidgetData(
            'vibration_enabled', data.vibrationEnabled.toString());

        debugPrint('Home widget updated successfully with values:');
        debugPrint('Device ID: ${data.deviceId}');
        debugPrint('CO2 Value: ${data.co2Value}');
        debugPrint('Device Name: ${data.deviceName}');
        debugPrint('Power Mode: ${data.powerMode}');
        debugPrint('Battery Level: ${data.batteryLevel}');
        debugPrint('Is Charging: ${data.isCharging}');
        debugPrint('Alarm Enabled: ${data.alarmEnabled}');
        debugPrint('Vibration Enabled: ${data.vibrationEnabled}');
      }

      await HomeWidget.saveWidgetData(
          'last_updated', DateTime.now().millisecondsSinceEpoch.toString());

      // Trigger widget update
      await HomeWidget.updateWidget(
        iOSName: Constants.iOSWidgetName,
        androidName: Constants.androidWidgetName,
      );
    } catch (e, stackTrace) {
      debugPrint('Error updating home widget: $e\n$stackTrace');
    }
  }
}
