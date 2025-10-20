import 'dart:io';

import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/models/live_activity_model.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/widget_service.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';

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

  // Track which devices currently have active Live Activities (max 3)
  final Set<String> _activeDeviceIds = <String>{};
  static const int maxActiveDevices = 3;

  // Store the most recent Live Activity data for each active device
  // This is ONLY for Live Activities (ephemeral, tied to notification lifecycle)
  // Widgets use their own persistent storage via WidgetService
  final Map<String, LiveActivityModel> _activeLiveActivities = {};

  // Track activity start times for each device
  final Map<String, DateTime> _activityStartTimes = {};

  // Set up method call handler to listen for refresh requests and dismissal events
  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((call) async {
      debugPrint('🔔 Received method call from native: ${call.method}');
      debugPrint('🔔 Arguments: ${call.arguments}');

      switch (call.method) {
        case 'onRefreshRequested':
          debugPrint('📲 Live Activity refresh requested');
          final String? deviceId = call.arguments != null
              ? call.arguments['deviceId'] as String?
              : null;
          _handleRefreshRequest(deviceId);
          break;
        case 'onLiveActivityDismissed':
          debugPrint('🚫 Live Activity dismissed by user');
          final String? deviceId = call.arguments != null
              ? call.arguments['deviceId'] as String?
              : null;
          debugPrint('🆔 Device ID from dismissal: $deviceId');
          _handleDismissalEvent(deviceId);
          break;
        case 'onRestartLiveActivityRequested':
          debugPrint('🔄 Live Activity restart requested');
          final String? deviceId = call.arguments != null
              ? call.arguments['deviceId'] as String?
              : null;
          _handleRestartRequest(deviceId!);
          break;
        case 'onAutoDisableLiveActivity':
          debugPrint('🔄 Auto-disable Live Activity requested');
          final String? deviceId = call.arguments != null
              ? call.arguments['deviceId'] as String?
              : null;
          _handleAutoDisableRequest(deviceId!);
          break;
        default:
          debugPrint('❓ Unknown method call: ${call.method}');
      }
    });
  }

  void _handleRefreshRequest(String? deviceId) {
    if (deviceId != null) {
      // Refresh specific device (from widget)
      debugPrint('Refreshing specific device from widget: $deviceId');

      if (_deviceCallbacks.containsKey(deviceId)) {
        final refreshCallback = _deviceCallbacks[deviceId]?.refreshCallback;
        if (refreshCallback != null) {
          debugPrint('Calling refresh callback for device: $deviceId');

          // Update widget refreshing state FIRST (for immediate UI feedback)
          WidgetService()
              .setRefreshingState(deviceId: deviceId, isRefreshing: true);

          // Then call the refresh callback
          refreshCallback.call();

          // Update the specific device's Live Activity with refreshing state if active
          if (_activeDeviceIds.contains(deviceId)) {
            final deviceData = _activeLiveActivities[deviceId];
            if (deviceData != null) {
              _updateDeviceLiveActivity(
                deviceId: deviceId,
                data: deviceData.copyWith(isRefreshing: true),
              );
            }
          }
        } else {
          debugPrint('No refresh callback registered for device: $deviceId');
        }
      } else {
        debugPrint('Device not found in callbacks: $deviceId');
      }
    } else {
      // Refresh all devices with callbacks (from notification or legacy)
      debugPrint(
          'Refreshing all devices with callbacks (${_deviceCallbacks.length} devices)');

      for (final deviceId in _deviceCallbacks.keys) {
        final refreshCallback = _deviceCallbacks[deviceId]?.refreshCallback;
        if (refreshCallback != null) {
          debugPrint('Refreshing device: $deviceId');

          // Update widget refreshing state FIRST (for immediate UI feedback)
          WidgetService()
              .setRefreshingState(deviceId: deviceId, isRefreshing: true);

          // Then call the refresh callback
          refreshCallback.call();

          // Update the specific device's Live Activity with refreshing state if active
          if (_activeDeviceIds.contains(deviceId)) {
            final deviceData = _activeLiveActivities[deviceId];
            if (deviceData != null) {
              _updateDeviceLiveActivity(
                deviceId: deviceId,
                data: deviceData.copyWith(isRefreshing: true),
              );
            }
          }
        }
      }
    }
  }

  void _handleDismissalEvent(String? deviceId) {
    debugPrint('🚫 Processing dismissal event...');
    debugPrint('🆔 Device ID parameter: $deviceId');
    debugPrint('🎯 Current active devices: ${_activeDeviceIds.toList()}');
    debugPrint('📋 Registered callbacks: ${_deviceCallbacks.keys.toList()}');
    debugPrint('📊 Total callback devices: ${_deviceCallbacks.length}');

    if (deviceId != null &&
        deviceId != 'all' &&
        _deviceCallbacks.containsKey(deviceId)) {
      // Specific device dismissal
      final dismissalCallback = _deviceCallbacks[deviceId]?.dismissalCallback;
      debugPrint(
          '🔄 Found callback for target device: ${dismissalCallback != null}');

      if (dismissalCallback != null) {
        debugPrint('✅ Calling dismissal callback for device: $deviceId');
        dismissalCallback.call(deviceId);

        // Remove from active devices but keep data for widgets
        _activeDeviceIds.remove(deviceId);
        // NOTE: We keep _activeLiveActivities for widgets to continue showing data
        _activityStartTimes.remove(deviceId);
        debugPrint(
            '🗑️ Removed device from active devices: $deviceId (widget data retained)');
        return;
      } else {
        debugPrint('⚠️ No dismissal callback registered for device: $deviceId');
      }
    } else if (deviceId == null || deviceId == 'all') {
      // No specific device or "all" - dismiss all active devices
      debugPrint(
          '🔄 Dismissing all active devices (${_activeDeviceIds.length} devices)');
      for (final activeDeviceId in _activeDeviceIds.toList()) {
        if (_deviceCallbacks.containsKey(activeDeviceId)) {
          final dismissalCallback =
              _deviceCallbacks[activeDeviceId]?.dismissalCallback;
          if (dismissalCallback != null) {
            debugPrint(
                '✅ Calling dismissal callback for device: $activeDeviceId');
            dismissalCallback.call(activeDeviceId);
          }
        }
        // NOTE: We keep _activeLiveActivities for widgets to continue showing data
        _activityStartTimes.remove(activeDeviceId);
      }
      _activeDeviceIds.clear();
      debugPrint('🗑️ Cleared all active devices (widget data retained)');
    } else {
      debugPrint('⚠️ Target device not found in callbacks: $deviceId');
    }
  }

  void _handleRestartRequest(String deviceId) {
    debugPrint('🔄 Restart requested for device: $deviceId');

    if (_activeLiveActivities.containsKey(deviceId)) {
      // Reset start time for the device
      _activityStartTimes[deviceId] = DateTime.now();

      final lastData = _activeLiveActivities[deviceId]!;
      final restartedData = lastData.copyWith(
        activityStartTime: _activityStartTimes[deviceId],
      );

      // Restart the Live Activity with fresh start time
      updateLiveActivity(data: restartedData, deviceId: deviceId);

      debugPrint('✅ Live Activity restarted for device: $deviceId');
    } else {
      debugPrint(
          '❌ Cannot restart Live Activity - no data found for device: $deviceId');
    }
  }

  void _handleAutoDisableRequest(String deviceId) {
    debugPrint('🔄 Handling auto-disable request for device: $deviceId');
    // Add the device to the auto-disable list
    _devicesToAutoDisable.add(deviceId);

    // Also immediately disable the setting if possible
    // This ensures the setting is disabled even if the provider isn't accessed
    _immediatelyDisableLiveActivitySetting(deviceId);
  }

  /// Immediately disable the live activity setting for a device
  void _immediatelyDisableLiveActivitySetting(String deviceId) {
    try {
      debugPrint(
          'LiveActivity: Immediately disabling live activity setting for device: $deviceId');

      // We need to access the device settings directly
      // This is a bit of a hack but ensures immediate disabling
      final currentSettings = IsarService().read<DeviceSettings?>((isar) {
        return isar.deviceSettings
            .where()
            .deviceIdEqualTo(deviceId)
            .findFirst();
      });

      if (currentSettings != null && currentSettings.showLiveActivity) {
        final updatedSettings =
            currentSettings.copyWith(showLiveActivity: false);

        IsarService().write((isar) {
          isar.deviceSettings.put(updatedSettings);
        });

        debugPrint(
            'LiveActivity: Successfully disabled live activity setting for device: $deviceId');

        // Remove only this device's Live Activity notification
        removeDeviceLiveActivity(deviceId);
      }
    } catch (e) {
      debugPrint(
          'LiveActivity: Error immediately disabling setting for device $deviceId: $e');
    }
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

      _activeDeviceIds.remove(deviceId);
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

      _activeDeviceIds.remove(deviceId);
      // NOTE: We keep _activeLiveActivities for widgets to continue showing data
    }
    debugPrint(
        'All Live Activity callbacks cleared for device: $deviceId (widget data retained)');
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
    debugPrint('Active devices: ${_activeDeviceIds.toList()}');
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
    _activeLiveActivities.remove(deviceId);
    debugPrint('Live Activity data cleared for device: $deviceId');
  }

  // Get the last known Live Activity data for a device (useful for debugging)
  LiveActivityModel? getLastDeviceData(String deviceId) {
    return _activeLiveActivities[deviceId];
  }

  // Check if we have stored data for a device
  bool hasDataForDevice(String deviceId) {
    return _activeLiveActivities.containsKey(deviceId);
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

  // Get all currently active devices
  Set<String> getActiveDevices() {
    return Set.from(_activeDeviceIds);
  }

  // Check if a specific device is active
  bool isDeviceActive(String deviceId) {
    return _activeDeviceIds.contains(deviceId);
  }

  // Check if a device has stored data (was previously active)
  bool wasDevicePreviouslyActive(String deviceId) {
    return _activeLiveActivities.containsKey(deviceId);
  }

  // Get the number of active devices
  int getActiveDeviceCount() {
    return _activeDeviceIds.length;
  }

  // Check if we can add more devices
  bool canAddMoreDevices() {
    return _activeDeviceIds.length < maxActiveDevices;
  }

  Future<void> updateLiveActivity(
      {required LiveActivityModel data, String? deviceId}) async {
    if (deviceId != null) {
      await _updateDeviceLiveActivity(deviceId: deviceId, data: data);
    } else {
      // Legacy single device support
      await _updateSingleDeviceLiveActivity(data: data);
    }
  }

  Future<void> _updateDeviceLiveActivity({
    required String deviceId,
    required LiveActivityModel data,
  }) async {
    try {
      debugPrint(
          'Live Activity update requested for device: $deviceId with connection: ${data.isConnected}');

      // Store the data
      _activeLiveActivities[deviceId] = data;

      // Check if we can add this device (max 3 devices)
      if (_activeDeviceIds.length >= maxActiveDevices &&
          !_activeDeviceIds.contains(deviceId)) {
        debugPrint(
            'Maximum number of active devices ($maxActiveDevices) reached, cannot add device: $deviceId');
        return;
      }

      // Check if device already has a notification (update vs add)
      final isNewDevice = !_activeDeviceIds.contains(deviceId);

      // Track activity start time for new devices
      if (isNewDevice) {
        _activityStartTimes[deviceId] = DateTime.now();
      }

      // Add device to active devices
      _activeDeviceIds.add(deviceId);

      // Update data with activity start time
      final updatedData = data.copyWith(
        activityStartTime: _activityStartTimes[deviceId],
      );

      // Check if live activity is about to expire and auto-disable if needed
      _checkAndHandleExpiry(deviceId, updatedData);

      // Update the specific device's Live Activity
      // NOTE: Widgets are updated separately via WidgetService
      if (Platform.isAndroid) {
        if (isNewDevice) {
          // Add new notification
          await platform.invokeMethod('addDeviceNotification', {
            'deviceId': deviceId,
            'data': updatedData.toJson(),
          });
        } else {
          // Update existing notification with new data
          await platform.invokeMethod('updateDeviceNotification', {
            'deviceId': deviceId,
            'data': updatedData.toJson(),
          });
        }
      } else if (Platform.isIOS) {
        await platform.invokeMethod('updateLiveActivity', updatedData.toJson());
      }

      debugPrint(
          'Live Activity updated successfully for device: $deviceId - Connection: ${data.isConnected ? "Connected" : "Disconnected"}');
    } on PlatformException catch (e) {
      debugPrint(
          "Failed to update live activity for device $deviceId: '${e.message}'.");

      // If update fails and device is disconnected, ensure we still show disconnected state
      if (!data.isConnected) {
        debugPrint(
            "Update failed for disconnected device, attempting to restart Live Activity with disconnected state");
        try {
          if (Platform.isAndroid) {
            await platform.invokeMethod('addDeviceNotification', {
              'deviceId': deviceId,
              'data': data.toJson(),
            });
          } else if (Platform.isIOS) {
            await platform.invokeMethod('startLiveActivity', data.toJson());
          }
        } catch (retryError) {
          debugPrint(
              "Failed to restart Live Activity with disconnected state: $retryError");
        }
      }
    } catch (e) {
      debugPrint(
          "Unexpected error updating live activity for device $deviceId: $e");
    }
  }

  Future<void> _updateSingleDeviceLiveActivity(
      {required LiveActivityModel data}) async {
    try {
      debugPrint(
          'Live Activity update requested (legacy single device) with connection: ${data.isConnected}');

      // NOTE: Widgets are updated separately via WidgetService

      await platform.invokeMethod(
        'updateLiveActivity',
        data.toJson(),
      );
      debugPrint(
          'Live Activity updated successfully (legacy) - Connection: ${data.isConnected ? "Connected" : "Disconnected"}');
    } on PlatformException catch (e) {
      debugPrint("Failed to update live activity: '${e.message}'.");
    } catch (e) {
      debugPrint("Unexpected error updating live activity: $e");
    }
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

      _activeDeviceIds.clear(); // Clear all active devices when ending
      _activeLiveActivities.clear(); // Clear all stored data when ending
    } on PlatformException catch (e) {
      debugPrint("Failed to end live activity: '${e.message}'.");
    }
  }

  Future<void> removeDeviceLiveActivity(String deviceId) async {
    try {
      debugPrint('Removing Live Activity for device: $deviceId');

      if (Platform.isAndroid) {
        await platform
            .invokeMethod('removeDeviceNotification', {'deviceId': deviceId});
      } else if (Platform.isIOS) {
        // For iOS, we'll end all Live Activities since iOS doesn't support multiple
        await platform.invokeMethod('endLiveActivity');
      }

      _activeDeviceIds.remove(deviceId);
      // NOTE: We intentionally DO NOT remove from _activeLiveActivities here
      // because widgets need this data even when Live Activity is disabled.
      // The data will persist for widgets but the Live Activity notification is removed.
      debugPrint(
          'Live Activity removed successfully for device: $deviceId (widget data retained)');
    } on PlatformException catch (e) {
      debugPrint(
          "Failed to remove live activity for device $deviceId: '${e.message}'.");
    } catch (e) {
      debugPrint(
          "Unexpected error removing live activity for device $deviceId: $e");
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

      // Create unified data model with display CO2 value (minimum 400 for user-facing components)
      // NOTE: Zone percentages are NOT calculated here - they're only needed for widgets
      final actualCO2Value = int.parse(co2Value);
      final displayCO2Value = actualCO2Value < 400 ? 400 : actualCO2Value;
      final displayCO2History =
          co2History.map((value) => value < 400 ? 400 : value).toList();

      final liveActivityData = LiveActivityModel(
        deviceId: deviceId,
        deviceName: deviceName,
        co2Value: displayCO2Value,
        powerMode: powerMode,
        batteryLevel: int.parse(batteryLevel),
        isCharging: isCharging,
        isConnected: isConnected,
        alarmEnabled: alarmEnabled,
        vibrationEnabled: vibrationEnabled,
        co2History: displayCO2History,
        greenUpperLimit: deviceSettings?.thresholds.greenUpperLimit ??
            Constants.defaultGreenUpperLimit,
        yellowUpperLimit: deviceSettings?.thresholds.yellowUpperLimit ??
            Constants.defaultYellowUpperLimit,
        graphMaxValue: deviceSettings?.graphMaxValue ?? 1600,
        graphMinValue: deviceSettings?.graphMinValue ?? 0,
        isRefreshing: false,
        // Zone percentages not needed for Live Activities (only for widgets)
        greenZonePercentage: 0,
        yellowZonePercentage: 0,
        redZonePercentage: 0,
        dominantZone: 'none',
        dominantZonePercentage: 0,
      );

      // Check if this is a reconnection scenario (device was disconnected and now connected)
      final wasDisconnected = _activeLiveActivities[deviceId]?.isConnected == false;
      final isNowConnected = isConnected;
      final isReconnection = wasDisconnected && isNowConnected;

      // Store the data for potential disconnection updates
      _activeLiveActivities[deviceId] = liveActivityData;

      // NOTE: Widgets are updated separately via WidgetService (called by BLE provider)

      // Handle Live Activity based on toggle
      if (deviceSettings?.showLiveActivity == true) {
        if (isReconnection) {
          debugPrint('LiveActivity: Detected reconnection for device $deviceId - restarting with fresh timer');
          // For reconnection, ensure we get a fresh Live Activity with new timer
          await _restartLiveActivityForReconnection(deviceId: deviceId, data: liveActivityData);
        } else {
          await updateLiveActivity(deviceId: deviceId, data: liveActivityData);
        }
        // NOTE: On iOS, only ONE Live Activity can be active at a time.
        // If multiple devices have Live Activity enabled, the most recently
        // updated device will be shown. This is an iOS platform limitation.
      } else {
        // If Live Activity is disabled, only remove if it's actually active
        if (_activeDeviceIds.contains(deviceId)) {
          if (Platform.isAndroid) {
            // Android: Can remove specific device notification without affecting others
            await removeDeviceLiveActivity(deviceId);
          } else if (Platform.isIOS) {
            // iOS: Skip removal to preserve other active devices
            // iOS only supports 1 Live Activity per app, so calling removeDeviceLiveActivity
            // would end ALL Live Activities, affecting other devices that have it enabled.
            _activeDeviceIds.remove(deviceId);
            debugPrint(
                'iOS: Skipped Live Activity removal for $deviceId to preserve other active devices');
          }
        }
      }
    } catch (e) {
      debugPrint('LiveActivity: Error processing CO2 data update: $e');
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
      final lastData = _activeLiveActivities[deviceId];
      if (lastData == null) {
        debugPrint(
            'LiveActivity: No previous data found for device $deviceId, cannot update disconnected state');
        return;
      }

      // Only update if this device currently has an active Live Activity
      if (!_activeDeviceIds.contains(deviceId)) {
        debugPrint(
            'LiveActivity: Device $deviceId is not in active devices, skipping disconnected state update');
        return;
      }

      // Create disconnected version using copyWith
      final disconnectedData = lastData.copyWith(
        isConnected: false,
        isRefreshing: false,
        lastUpdated: DateTime.now(), // Update the timestamp for disconnection
      );

      // Force update even if settings say not to show Live Activity
      // This ensures the disconnected state is shown immediately
      if (Platform.isAndroid) {
        await platform.invokeMethod('addDeviceNotification', {
          'deviceId': deviceId,
          'data': disconnectedData.toJson(),
        });
      } else if (Platform.isIOS) {
        await platform.invokeMethod(
            'updateLiveActivity', disconnectedData.toJson());
      }

      // NOTE: Widgets are updated separately via WidgetService (called by BLE provider)

      // Store the disconnected state as the latest data
      _activeLiveActivities[deviceId] = disconnectedData;

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

      // Restart Live Activities for all active devices
      for (final deviceId in _activeDeviceIds) {
        final lastData = _activeLiveActivities[deviceId];
        if (lastData != null) {
          debugPrint(
              'LiveActivity: Restarting with last known data for device: $deviceId');
          await updateLiveActivity(data: lastData, deviceId: deviceId);
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
      if (!isActive && _activeDeviceIds.isNotEmpty) {
        debugPrint(
            'LiveActivity: No active Live Activity found but should be active, restarting for ${_activeDeviceIds.length} devices');

        // Restart Live Activities for all active devices
        for (final deviceId in _activeDeviceIds) {
          final lastData = _activeLiveActivities[deviceId];
          if (lastData != null && lastData.isConnected) {
            await updateLiveActivity(data: lastData, deviceId: deviceId);
          }
        }
      }
    } catch (e) {
      debugPrint('LiveActivity: Error checking refresh status: $e');
    }
  }

  /// Check if live activity is about to expire and auto-disable the setting
  void _checkAndHandleExpiry(String deviceId, LiveActivityModel data) {
    try {
      final activityStartTime = _activityStartTimes[deviceId];
      if (activityStartTime == null) return;

      final now = DateTime.now();
      final timeElapsed = now.difference(activityStartTime);

      // DEBUG MODE: Use shorter times for testing
      // Production: 8 hours total, 10 minutes warning
      // Debug: 2 minutes total, 30 seconds warning
      const bool isDebugMode = bool.fromEnvironment('dart.vm.product') == false;

      final Duration totalDuration =
          isDebugMode ? const Duration(minutes: 2) : const Duration(hours: 8);
      final Duration warningDuration = isDebugMode
          ? const Duration(seconds: 30)
          : const Duration(minutes: 10);

      final Duration timeUntilExpiry = totalDuration - timeElapsed;

      // If we're in the warning period (last 30 seconds in debug, last 10 minutes in production)
      if (timeUntilExpiry <= warningDuration &&
          timeUntilExpiry > Duration.zero) {
        debugPrint(
            'LiveActivity: Device $deviceId is approaching expiry in ${timeUntilExpiry.inSeconds} seconds');

        // Auto-disable the live activity setting
        _autoDisableLiveActivitySetting(deviceId);
      }
    } catch (e) {
      debugPrint(
          'LiveActivity: Error checking expiry for device $deviceId: $e');
    }
  }

  /// Automatically disable the live activity setting for a device
  void _autoDisableLiveActivitySetting(String deviceId) {
    try {
      // Import the provider here to avoid circular dependencies
      // We'll use a different approach - send a notification that the provider can listen to
      debugPrint(
          'LiveActivity: Auto-disabling live activity setting for device: $deviceId');

      // Send a notification that the device settings provider can listen to
      // This avoids circular dependency issues
      _notifyAutoDisable(deviceId);
    } catch (e) {
      debugPrint(
          'LiveActivity: Error auto-disabling setting for device $deviceId: $e');
    }
  }

  /// Notify that a device's live activity setting should be auto-disabled
  void _notifyAutoDisable(String deviceId) {
    // This will be handled by the device settings provider
    // We'll use a simple callback approach
    debugPrint('LiveActivity: Notifying auto-disable for device: $deviceId');

    // Store the device ID that should be auto-disabled
    // The device settings provider can check this when needed
    _devicesToAutoDisable.add(deviceId);
  }

  // Track devices that should have their live activity setting auto-disabled
  final Set<String> _devicesToAutoDisable = <String>{};

  /// Check if a device should be auto-disabled and clear it from the list
  bool shouldAutoDisableDevice(String deviceId) {
    final shouldDisable = _devicesToAutoDisable.contains(deviceId);
    if (shouldDisable) {
      _devicesToAutoDisable.remove(deviceId);
    }
    return shouldDisable;
  }

  /// Restart Live Activity for reconnected device to get fresh 8-hour timer
  Future<void> _restartLiveActivityForReconnection({
    required String deviceId,
    required LiveActivityModel data,
  }) async {
    try {
      debugPrint('LiveActivity: Restarting Live Activity for reconnected device: $deviceId');
      
      // Remove the old Live Activity first
      if (_activeDeviceIds.contains(deviceId)) {
        await removeDeviceLiveActivity(deviceId);
        
        // Wait a moment for clean transition
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      // Reset the activity start time for fresh timer
      _activityStartTimes[deviceId] = DateTime.now();
      
      // Create fresh Live Activity with new start time
      final freshData = data.copyWith(
        activityStartTime: _activityStartTimes[deviceId],
        lastUpdated: DateTime.now(),
      );
      
      // Start fresh Live Activity
      await updateLiveActivity(deviceId: deviceId, data: freshData);
      
      debugPrint('LiveActivity: Successfully restarted Live Activity with fresh timer for device: $deviceId');
    } catch (e) {
      debugPrint('LiveActivity: Error restarting Live Activity for device $deviceId: $e');
      // Fallback to regular update if restart fails
      await updateLiveActivity(deviceId: deviceId, data: data);
    }
  }

  /// Clean up stale disconnected notifications
  /// This should be called when the app comes to foreground
  Future<void> cleanupStaleDisconnectedNotifications() async {
    try {
      debugPrint('LiveActivity: Checking for stale disconnected notifications');
      
      final staleDevices = <String>[];
      
      // Check each active device
      for (final deviceId in _activeDeviceIds.toList()) {
        final deviceData = _activeLiveActivities[deviceId];
        
        if (deviceData != null && !deviceData.isConnected) {
          // Check how long the device has been disconnected
          final lastUpdated = deviceData.lastUpdated ?? DateTime.now();
          final timeSinceUpdate = DateTime.now().difference(lastUpdated);
          
          // If disconnected for more than 10 minutes, consider it stale
          if (timeSinceUpdate.inMinutes > 10) {
            debugPrint('LiveActivity: Found stale disconnected notification for device: $deviceId (disconnected for ${timeSinceUpdate.inMinutes} minutes)');
            staleDevices.add(deviceId);
          }
        }
      }
      
      // Clean up stale devices
      for (final deviceId in staleDevices) {
        debugPrint('LiveActivity: Cleaning up stale notification for device: $deviceId');
        
        // Remove the notification
        await removeDeviceLiveActivity(deviceId);
        
        // Optionally disable the Live Activity setting to prevent future ghost notifications
        _immediatelyDisableLiveActivitySetting(deviceId);
      }
      
      if (staleDevices.isNotEmpty) {
        debugPrint('LiveActivity: Cleaned up ${staleDevices.length} stale disconnected notifications');
      } else {
        debugPrint('LiveActivity: No stale disconnected notifications found');
      }
    } catch (e) {
      debugPrint('LiveActivity: Error cleaning up stale notifications: $e');
    }
  }
}
