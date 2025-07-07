import 'dart:async';
import 'dart:convert';

import 'package:airspothealth/core/services/ble_communicator_service.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
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
  final List<int> co2History;
  final int greenUpperLimit;
  final int yellowUpperLimit;
  final int graphMaxValue;
  final int graphMinValue;

  WidgetUpdateData({
    required this.deviceId,
    required this.co2Value,
    required this.deviceName,
    required this.powerMode,
    required this.batteryLevel,
    required this.isCharging,
    required this.alarmEnabled,
    required this.vibrationEnabled,
    required this.co2History,
    required this.greenUpperLimit,
    required this.yellowUpperLimit,
    required this.graphMaxValue,
    required this.graphMinValue,
  });

  /// Convert to JSON map for efficient storage
  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'co2_value': co2Value,
        'device_name': deviceName,
        'power_mode': powerMode,
        'battery_level': batteryLevel,
        'is_charging': isCharging,
        'alarm_enabled': alarmEnabled,
        'vibration_enabled': vibrationEnabled,
        'co2_history': co2History,
        'green_upper_limit': greenUpperLimit,
        'yellow_upper_limit': yellowUpperLimit,
        'graph_max_value': graphMaxValue,
        'graph_min_value': graphMinValue,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      };

  /// Create default/empty widget data
  static Map<String, dynamic> getDefaultData() => {
        'device_id': '',
        'co2_value': '----',
        'device_name': 'No Device',
        'power_mode': 'Now',
        'battery_level': '0',
        'is_charging': false,
        'alarm_enabled': false,
        'vibration_enabled': false,
        'co2_history': <int>[],
        'green_upper_limit': 800,
        'yellow_upper_limit': 1000,
        'graph_max_value': 1600,
        'graph_min_value': 0,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      };
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
      BleCommunicatorService.instance
          .communicator(deviceId)
          .sendCommand(DeviceCmdUtils.getCO2());

      debugPrint('Refresh command sent to device: $deviceId');
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

  static const String _widgetDataKey = 'widget_data_json';

  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(Constants.appGroupId);
    HomeWidget.registerInteractivityCallback(_backgroundCallback);
  }

  /// Top-level function to update the home widget with actual values.
  /// This is designed to be called from anywhere, including background isolates.
  Future<void> updateHomeWidget({WidgetUpdateData? data}) async {
    try {
      Map<String, dynamic> widgetData;

      if (data == null) {
        // No data provided - use default state
        widgetData = WidgetUpdateData.getDefaultData();
        debugPrint('Home widget updated with default/empty data');
      } else {
        // Convert provided data to JSON map
        widgetData = data.toJson();
        debugPrint('Home widget updated with live data:');
        debugPrint('Device: ${data.deviceName} (${data.deviceId})');
        debugPrint('CO2: ${data.co2Value} ppm');
        debugPrint('Power Mode: ${data.powerMode}');
        debugPrint('Battery: ${data.batteryLevel}%');
        debugPrint('History: ${data.co2History.length} values');
        debugPrint(
            'Thresholds: Green≤${data.greenUpperLimit}, Yellow≤${data.yellowUpperLimit}');
        debugPrint('Graph Range: ${data.graphMinValue}-${data.graphMaxValue}');
      }

      // Save all data as single JSON string - much more efficient!
      await HomeWidget.saveWidgetData(_widgetDataKey, jsonEncode(widgetData));

      // Also save legacy CO2 value for backward compatibility
      await HomeWidget.saveWidgetData(
          Constants.homeWidgetKey, widgetData['co2_value']);

      // Trigger widget update
      await HomeWidget.updateWidget(
        iOSName: Constants.iOSWidgetName,
        androidName: Constants.androidWidgetName,
      );

      debugPrint(
          'Widget data saved as single JSON payload (${jsonEncode(widgetData).length} chars)');
    } catch (e, stackTrace) {
      debugPrint('Error updating home widget: $e\n$stackTrace');
    }
  }
}
