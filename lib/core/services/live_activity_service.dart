import 'dart:convert';
import 'dart:io';

import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/models/live_activity_model.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

class LiveActivityService {
  static const platform = MethodChannel('liveActivityChannel');

  // Singleton instance
  static final LiveActivityService _instance = LiveActivityService._internal();
  factory LiveActivityService() => _instance;
  LiveActivityService._internal() {
    _setupMethodCallHandler();
  }

  // Map of device callbacks for refresh requests
  final Map<String, VoidCallback> _deviceRefreshCallbacks = {};

  // Track which device currently has active Live Activity
  String? _activeDeviceId;

  // Store the last Live Activity data for each device
  final Map<String, LiveActivityModel> _lastLiveActivityData = {};

  // Set up method call handler to listen for refresh requests
  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onRefreshRequested':
          debugPrint('Live Activity refresh requested');
          _handleRefreshRequest();
          break;
        default:
          debugPrint('Unknown method call: ${call.method}');
      }
    });
  }

  void _handleRefreshRequest() {
    // If we know which device has active Live Activity, refresh that one
    if (_activeDeviceId != null &&
        _deviceRefreshCallbacks.containsKey(_activeDeviceId)) {
      debugPrint('Refreshing active Live Activity device: $_activeDeviceId');
      _deviceRefreshCallbacks[_activeDeviceId]?.call();

      updateLiveActivity(
          data: _lastLiveActivityData[_activeDeviceId]!.copyWith(
        isRefreshing: true,
      ));
    } else {
      // Fallback: refresh all registered devices
      debugPrint(
          'Refreshing all registered devices (${_deviceRefreshCallbacks.length} devices)');
      for (final callback in _deviceRefreshCallbacks.values) {
        callback.call();
      }
    }
  }

  // Set the callback for refresh requests for a specific device
  void setDeviceRefreshCallback(String deviceId, VoidCallback callback) {
    _deviceRefreshCallbacks[deviceId] = callback;
    debugPrint('Live Activity refresh callback set for device: $deviceId');
  }

  // Clear the refresh callback for a specific device
  void clearDeviceRefreshCallback(String deviceId) {
    _deviceRefreshCallbacks.remove(deviceId);
    if (_activeDeviceId == deviceId) {
      _activeDeviceId = null;
    }
    debugPrint('Live Activity refresh callback cleared for device: $deviceId');
  }

  // Clear stored Live Activity data for a specific device
  void clearDeviceData(String deviceId) {
    _lastLiveActivityData.remove(deviceId);
    debugPrint('Live Activity data cleared for device: $deviceId');
  }

  // Get the last known Live Activity data for a device (useful for debugging)
  LiveActivityModel? getLastDeviceData(String deviceId) {
    return _lastLiveActivityData[deviceId];
  }

  // Check if we have stored data for a device
  bool hasDataForDevice(String deviceId) {
    return _lastLiveActivityData.containsKey(deviceId);
  }

  // Legacy method for backward compatibility
  void setOnRefreshCallback(VoidCallback callback) {
    debugPrint(
        'Using legacy setOnRefreshCallback - consider using setDeviceRefreshCallback instead');
    // Use a default device ID for legacy support
    setDeviceRefreshCallback('default', callback);
  }

  // Legacy method for backward compatibility
  void clearOnRefreshCallback() {
    debugPrint(
        'Using legacy clearOnRefreshCallback - consider using clearDeviceRefreshCallback instead');
    clearDeviceRefreshCallback('default');
  }

  // Set the active device (called when updating Live Activity)
  void setActiveDevice(String deviceId) {
    _activeDeviceId = deviceId;
    debugPrint('Active Live Activity device set to: $deviceId');
  }

  // Get the currently active device
  String? getActiveDevice() {
    return _activeDeviceId;
  }

  Future<void> updateLiveActivity(
      {required LiveActivityModel data, String? deviceId}) async {
    try {
      // Track which device is updating the Live Activity
      if (deviceId != null) {
        setActiveDevice(deviceId);
      }
      _updateAndroidHomeWidget(data).ignore();

      await platform.invokeMethod(
        'updateLiveActivity',
        data.toJson(),
      );
      debugPrint(
          'Live Activity updated successfully${deviceId != null ? ' for device: $deviceId' : ''}');
    } on PlatformException catch (e) {
      debugPrint("Failed to update live activity: '${e.message}'.");
    }
  }

  Future<void> _updateAndroidHomeWidget(LiveActivityModel data) async {
    // Update Android Home Widget via home_widget plugin
    final widgetData = data.toJson();

    // Store data for widget
    await HomeWidget.saveWidgetData<String>(
        'widget_data_json', jsonEncode(widgetData));

    // Update the widget
    await HomeWidget.updateWidget(
      name: Constants.androidWidgetName,
      androidName: Constants.androidWidgetName,
    );
  }

  Future<void> endLiveActivity() async {
    try {
      if (Platform.isIOS) {
        // iOS: End Live Activity
        await platform.invokeMethod('endLiveActivity');
        debugPrint('iOS Live Activity ended successfully');
      } else if (Platform.isAndroid) {
        // Android: Stop Foreground Notification (Home Widget stays)
        await platform.invokeMethod('endLiveActivity');
        debugPrint('Android Foreground Notification ended successfully');
      }

      _activeDeviceId = null; // Clear active device when ending
      _lastLiveActivityData.clear(); // Clear all stored data when ending
    } on PlatformException catch (e) {
      debugPrint("Failed to end live activity: '${e.message}'.");
    }
  }

  /// Unified method to update all UI components with CO2 data
  /// This replaces the complex logic previously in BLE provider
  Future<void> updateWithCO2Data({
    required String deviceId,
    required String co2Value,
    required String deviceName,
    required DeviceSettings? deviceSettings,
    required String batteryLevel,
    required bool isCharging,
    required bool isConnected,
    required List<int> co2History,
  }) async {
    try {
      // Extract device settings or use defaults
      final String powerMode = deviceSettings?.powerMode.name ?? 'Now';
      final bool alarmEnabled = deviceSettings?.alarmEnabled ?? false;
      final bool vibrationEnabled = deviceSettings?.vibrationEnabled ?? false;

      // Create unified data model
      final liveActivityData = LiveActivityModel(
        deviceId: deviceId,
        deviceName: deviceName,
        co2Value: int.parse(co2Value),
        powerMode: powerMode,
        batteryLevel: int.parse(batteryLevel),
        isCharging: isCharging,
        isConnected: isConnected,
        alarmEnabled: alarmEnabled,
        vibrationEnabled: vibrationEnabled,
        co2History: co2History,
        greenUpperLimit: deviceSettings?.thresholds.greenUpperLimit ??
            Constants.defaultGreenUpperLimit,
        yellowUpperLimit: deviceSettings?.thresholds.yellowUpperLimit ??
            Constants.defaultYellowUpperLimit,
        graphMaxValue: deviceSettings?.graphMaxValue ?? 1600,
        graphMinValue: deviceSettings?.graphMinValue ?? 0,
        isRefreshing: false,
      );

      // Store the data for potential disconnection updates
      _lastLiveActivityData[deviceId] = liveActivityData;

      if (deviceSettings?.showLiveActivity == true) {
        if (Platform.isIOS) {
          // Check dismissal state for iOS
          bool wasDismissed = await wasUserDismissedThisSession();
          if (wasDismissed) {
            debugPrint(
                'LiveActivity: Was dismissed by user this session - update will be blocked');
            return;
          }
        }

        await updateLiveActivity(deviceId: deviceId, data: liveActivityData);
      } else {
        debugPrint(
            'LiveActivity: Android notification setting is disabled - stopping any active service');
        await endLiveActivity();
      }
    } catch (e) {
      debugPrint('LiveActivity: Error processing CO2 data update: $e');

      // Fallback for Android home widget
      if (Platform.isAndroid) {
        await HomeWidget.saveWidgetData(Constants.homeWidgetKey, '----');
        await HomeWidget.updateWidget(
          iOSName: Constants.iOSWidgetName,
          androidName: Constants.androidWidgetName,
        );
      }
    }
  }

  /// Method to update Live Activity when device disconnects
  /// Uses the last known data and marks the device as disconnected
  Future<void> updateWithDisconnectedState({
    required String deviceId,
  }) async {
    try {
      // Get the last known Live Activity data for this device
      final lastData = _lastLiveActivityData[deviceId];
      if (lastData == null) {
        debugPrint(
            'LiveActivity: No previous data found for device $deviceId, cannot update disconnected state');
        return;
      }

      // Create disconnected version using copyWith
      final disconnectedData = lastData.copyWith(
        isConnected: false,
        isRefreshing: false,
      );

      await updateLiveActivity(deviceId: deviceId, data: disconnectedData);
      debugPrint(
          'LiveActivity: Updated with disconnected state for device: $deviceId');
    } catch (e) {
      debugPrint('LiveActivity: Error updating disconnected state: $e');
    }
  }

  Future<bool> isLiveActivityActive() async {
    try {
      final bool isActive = await platform.invokeMethod('isLiveActivityActive');
      return isActive;
    } on PlatformException catch (e) {
      debugPrint("Failed to check live activity status: '${e.message}'.");
      return false;
    }
  }

  Future<void> resetDismissalState() async {
    try {
      await platform.invokeMethod('resetDismissalState');
    } on PlatformException catch (e) {
      debugPrint("Failed to reset dismissal state: '${e.message}'.");
    }
  }

  Future<bool> wasUserDismissedThisSession() async {
    try {
      final bool wasDismissed =
          await platform.invokeMethod('wasUserDismissedThisSession');
      return wasDismissed;
    } on PlatformException catch (e) {
      debugPrint("Failed to check user dismissal state: '${e.message}'.");
      return false;
    }
  }
}
