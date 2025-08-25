import 'dart:convert';
import 'dart:io';

import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/models/live_activity_model.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

/// Enum for different types of device callbacks
enum CallbackType {
  refresh,
  dismissal,
  // Future callback types can be added here:
  // connectionChange,
  // dataUpdate,
  // errorOccurred,
}

/// Model to hold all callback types for a device
class DeviceCallbacks {
  VoidCallback? refreshCallback;
  Function(String deviceId)? dismissalCallback;

  DeviceCallbacks({
    this.refreshCallback,
    this.dismissalCallback,
  });

  /// Check if any callbacks are registered for this device
  bool get hasCallbacks => refreshCallback != null || dismissalCallback != null;

  /// Check if a specific callback type is registered
  bool hasCallback(CallbackType type) {
    switch (type) {
      case CallbackType.refresh:
        return refreshCallback != null;
      case CallbackType.dismissal:
        return dismissalCallback != null;
    }
  }

  /// Set a callback of specific type
  void setCallback(CallbackType type, dynamic callback) {
    switch (type) {
      case CallbackType.refresh:
        refreshCallback = callback as VoidCallback?;
        break;
      case CallbackType.dismissal:
        dismissalCallback = callback as Function(String deviceId)?;
        break;
    }
  }

  /// Clear a specific callback type
  void clearCallback(CallbackType type) {
    switch (type) {
      case CallbackType.refresh:
        refreshCallback = null;
        break;
      case CallbackType.dismissal:
        dismissalCallback = null;
        break;
    }
  }

  /// Clear all callbacks for this device
  void clear() {
    refreshCallback = null;
    dismissalCallback = null;
  }

  /// Get registered callback types for debugging
  List<CallbackType> get registeredCallbacks {
    return CallbackType.values.where((type) => hasCallback(type)).toList();
  }
}

class LiveActivityService {
  static const platform = MethodChannel('liveActivityChannel');

  // Singleton instance
  static final LiveActivityService _instance = LiveActivityService._internal();
  factory LiveActivityService() => _instance;
  LiveActivityService._internal() {
    _setupMethodCallHandler();
  }

  // Unified map of device callbacks using wrapper model
  final Map<String, DeviceCallbacks> _deviceCallbacks = {};

  // Track which device currently has active Live Activity
  String? _activeDeviceId;

  // Store the last Live Activity data for each device
  final Map<String, LiveActivityModel> _lastLiveActivityData = {};

  // Set up method call handler to listen for refresh requests and dismissal events
  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((call) async {
      debugPrint('🔔 Received method call from native: ${call.method}');
      debugPrint('🔔 Arguments: ${call.arguments}');

      switch (call.method) {
        case 'onRefreshRequested':
          debugPrint('📲 Live Activity refresh requested');
          _handleRefreshRequest();
          break;
        case 'onLiveActivityDismissed':
          debugPrint('🚫 Live Activity dismissed by user');
          final String? deviceId = call.arguments != null
              ? call.arguments['deviceId'] as String?
              : null;
          debugPrint('🆔 Device ID from dismissal: $deviceId');
          _handleDismissalEvent(deviceId);
          break;
        default:
          debugPrint('❓ Unknown method call: ${call.method}');
      }
    });
  }

  void _handleRefreshRequest() {
    // If we know which device has active Live Activity, refresh that one
    if (_activeDeviceId != null &&
        _deviceCallbacks.containsKey(_activeDeviceId)) {
      final refreshCallback =
          _deviceCallbacks[_activeDeviceId]?.refreshCallback;
      if (refreshCallback != null) {
        debugPrint('Refreshing active Live Activity device: $_activeDeviceId');
        refreshCallback.call();

        updateLiveActivity(
            data: _lastLiveActivityData[_activeDeviceId]!.copyWith(
          isRefreshing: true,
        ));
        return;
      }
    }

    // Fallback: refresh all registered devices
    debugPrint(
        'Refreshing all registered devices (${_deviceCallbacks.length} devices)');
    for (final entry in _deviceCallbacks.entries) {
      entry.value.refreshCallback?.call();
    }
  }

  void _handleDismissalEvent(String? deviceId) {
    debugPrint('🚫 Processing dismissal event...');
    debugPrint('🆔 Device ID parameter: $deviceId');
    debugPrint('🎯 Current active device: $_activeDeviceId');
    debugPrint('📋 Registered callbacks: ${_deviceCallbacks.keys.toList()}');
    debugPrint('📊 Total callback devices: ${_deviceCallbacks.length}');

    // Use active device if no specific device provided
    final targetDeviceId = deviceId ?? _activeDeviceId;
    debugPrint('🎯 Target device for dismissal: $targetDeviceId');

    if (targetDeviceId != null &&
        _deviceCallbacks.containsKey(targetDeviceId)) {
      final dismissalCallback =
          _deviceCallbacks[targetDeviceId]?.dismissalCallback;
      debugPrint(
          '🔄 Found callback for target device: ${dismissalCallback != null}');

      if (dismissalCallback != null) {
        debugPrint('✅ Calling dismissal callback for device: $targetDeviceId');
        dismissalCallback.call(targetDeviceId);

        // Clear active device when dismissed
        _activeDeviceId = null;
        debugPrint('🗑️ Cleared active device');
        return;
      } else {
        debugPrint(
            '⚠️ No dismissal callback registered for device: $targetDeviceId');
      }
    } else {
      debugPrint('⚠️ Target device not found in callbacks or is null');
    }

    // Fallback: call dismissal for all registered devices
    debugPrint(
        '🔄 Fallback: calling dismissal for all ${_deviceCallbacks.length} registered devices');
    int callbacksInvoked = 0;
    for (final entry in _deviceCallbacks.entries) {
      if (entry.value.dismissalCallback != null) {
        debugPrint('✅ Calling dismissal callback for device: ${entry.key}');
        entry.value.dismissalCallback?.call(entry.key);
        callbacksInvoked++;
      } else {
        debugPrint('⚠️ No dismissal callback for device: ${entry.key}');
      }
    }
    debugPrint('📊 Total dismissal callbacks invoked: $callbacksInvoked');

    // Clear active device when dismissed
    _activeDeviceId = null;
    debugPrint('🗑️ Cleared active device');
  }

  // Set the callback for refresh requests for a specific device
  void setDeviceRefreshCallback(String deviceId, VoidCallback callback) {
    _deviceCallbacks.putIfAbsent(deviceId, () => DeviceCallbacks());
    _deviceCallbacks[deviceId]!.refreshCallback = callback;
    debugPrint('Live Activity refresh callback set for device: $deviceId');
  }

  // Set the callback for dismissal events for a specific device
  void setDeviceDismissalCallback(
      String deviceId, Function(String deviceId) callback) {
    _deviceCallbacks.putIfAbsent(deviceId, () => DeviceCallbacks());
    _deviceCallbacks[deviceId]!.dismissalCallback = callback;
    debugPrint('Live Activity dismissal callback set for device: $deviceId');
  }

  // Clear the refresh callback for a specific device
  void clearDeviceRefreshCallback(String deviceId) {
    if (_deviceCallbacks.containsKey(deviceId)) {
      _deviceCallbacks[deviceId]!.refreshCallback = null;

      // Remove the device entry if no callbacks remain
      if (!_deviceCallbacks[deviceId]!.hasCallbacks) {
        _deviceCallbacks.remove(deviceId);
      }

      if (_activeDeviceId == deviceId) {
        _activeDeviceId = null;
      }
    }
    debugPrint('Live Activity refresh callback cleared for device: $deviceId');
  }

  // Clear the dismissal callback for a specific device
  void clearDeviceDismissalCallback(String deviceId) {
    if (_deviceCallbacks.containsKey(deviceId)) {
      _deviceCallbacks[deviceId]!.dismissalCallback = null;

      // Remove the device entry if no callbacks remain
      if (!_deviceCallbacks[deviceId]!.hasCallbacks) {
        _deviceCallbacks.remove(deviceId);
      }
    }
    debugPrint(
        'Live Activity dismissal callback cleared for device: $deviceId');
  }

  // Clear all callbacks for a specific device
  void clearAllDeviceCallbacks(String deviceId) {
    if (_deviceCallbacks.containsKey(deviceId)) {
      _deviceCallbacks[deviceId]!.clear();
      _deviceCallbacks.remove(deviceId);

      if (_activeDeviceId == deviceId) {
        _activeDeviceId = null;
      }
    }
    debugPrint('All Live Activity callbacks cleared for device: $deviceId');
  }

  // MARK: - Convenience and Debugging Methods

  /// Check if a device has any callbacks registered
  bool hasDeviceCallbacks(String deviceId) {
    return _deviceCallbacks.containsKey(deviceId) &&
        _deviceCallbacks[deviceId]!.hasCallbacks;
  }

  /// Check if a device has a specific callback type registered
  bool hasDeviceCallback(String deviceId, CallbackType type) {
    return _deviceCallbacks.containsKey(deviceId) &&
        _deviceCallbacks[deviceId]!.hasCallback(type);
  }

  /// Get all registered device IDs with callbacks
  List<String> get registeredDeviceIds => _deviceCallbacks.keys.toList();

  /// Get callback types registered for a specific device (for debugging)
  List<CallbackType> getRegisteredCallbackTypes(String deviceId) {
    return _deviceCallbacks[deviceId]?.registeredCallbacks ?? [];
  }

  /// Print debug information about all registered callbacks
  void debugPrintCallbackStatus() {
    debugPrint('=== Live Activity Callback Status ===');
    debugPrint('Active device: $_activeDeviceId');
    debugPrint('Total devices with callbacks: ${_deviceCallbacks.length}');

    for (final entry in _deviceCallbacks.entries) {
      final deviceId = entry.key;
      final callbacks = entry.value;
      final types = callbacks.registeredCallbacks.map((t) => t.name).join(', ');
      debugPrint('Device $deviceId: [$types]');
    }
    debugPrint('=====================================');
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
      debugPrint(
          'Live Activity update requested${deviceId != null ? ' for device: $deviceId' : ''} with connection: ${data.isConnected}');

      // Store the data regardless of device settings for potential future use
      if (deviceId != null) {
        _lastLiveActivityData[deviceId] = data;
      }

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
          'Live Activity updated successfully${deviceId != null ? ' for device: $deviceId' : ''} - Connection: ${data.isConnected ? "Connected" : "Disconnected"}');
    } on PlatformException catch (e) {
      debugPrint("Failed to update live activity: '${e.message}'.");

      // If update fails and device is disconnected, ensure we still show disconnected state
      if (!data.isConnected && deviceId != null) {
        debugPrint(
            "Update failed for disconnected device, attempting to restart Live Activity with disconnected state");
        try {
          // Try to create a new Live Activity with the disconnected state
          await platform.invokeMethod('startLiveActivity', data.toJson());
        } catch (retryError) {
          debugPrint(
              "Failed to restart Live Activity with disconnected state: $retryError");
        }
      }
    } catch (e) {
      debugPrint("Unexpected error updating live activity: $e");
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
        await updateLiveActivity(deviceId: deviceId, data: liveActivityData);
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
      debugPrint(
          'LiveActivity: Updating disconnected state for device: $deviceId');

      // Get the last known Live Activity data for this device
      final lastData = _lastLiveActivityData[deviceId];
      if (lastData == null) {
        debugPrint(
            'LiveActivity: No previous data found for device $deviceId, cannot update disconnected state');
        return;
      }

      // Only update if this device currently has an active Live Activity
      final isActive = await isLiveActivityActive();
      if (!isActive) {
        debugPrint(
            'LiveActivity: No active Live Activity found, skipping disconnected state update');
        return;
      }

      // Check if this device is the one with the active Live Activity
      if (_activeDeviceId != deviceId) {
        debugPrint(
            'LiveActivity: Device $deviceId is not the active Live Activity device ($_activeDeviceId), skipping update');
        return;
      }

      // Create disconnected version using copyWith
      final disconnectedData = lastData.copyWith(
        isConnected: false,
        isRefreshing: false,
      );

      // Force update even if settings say not to show Live Activity
      // This ensures the disconnected state is shown immediately
      await platform.invokeMethod(
        'updateLiveActivity',
        disconnectedData.toJson(),
      );

      // Update Android home widget as well
      await _updateAndroidHomeWidget(disconnectedData);

      // Store the disconnected state as the latest data
      _lastLiveActivityData[deviceId] = disconnectedData;

      debugPrint(
          'LiveActivity: Successfully updated with disconnected state for device: $deviceId');
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

  /// Force refresh the Live Activity by ending current one and starting new one
  /// This helps resolve stale activity issues
  Future<void> forceRefreshLiveActivity() async {
    try {
      debugPrint('LiveActivity: Force refreshing Live Activity');

      // End current activity first
      await endLiveActivity();

      // Wait a moment for clean transition
      await Future.delayed(const Duration(milliseconds: 500));

      // Find the device with active Live Activity and restart it
      if (_activeDeviceId != null) {
        final lastData = _lastLiveActivityData[_activeDeviceId];
        if (lastData != null) {
          debugPrint(
              'LiveActivity: Restarting with last known data for device: $_activeDeviceId');
          await updateLiveActivity(data: lastData, deviceId: _activeDeviceId);
        }
      }
    } catch (e) {
      debugPrint('LiveActivity: Error force refreshing: $e');
    }
  }

  /// Check if Live Activity should be refreshed (for background app refresh)
  Future<void> refreshIfNeeded() async {
    try {
      final isActive = await isLiveActivityActive();
      if (!isActive && _activeDeviceId != null) {
        final lastData = _lastLiveActivityData[_activeDeviceId];
        if (lastData != null && lastData.isConnected) {
          debugPrint(
              'LiveActivity: No active Live Activity found but should be active, restarting');
          await updateLiveActivity(data: lastData, deviceId: _activeDeviceId);
        }
      }
    } catch (e) {
      debugPrint('LiveActivity: Error checking refresh status: $e');
    }
  }
}
