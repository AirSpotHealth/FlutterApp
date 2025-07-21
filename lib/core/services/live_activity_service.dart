import 'dart:io';

import 'package:airspothealth/core/models/live_activity_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // Helper method to get platform name for logging
  String _getPlatformName() {
    if (Platform.isIOS) {
      return 'iOS (Live Activity)';
    } else if (Platform.isAndroid) {
      return 'Android (Foreground Notification)';
    } else {
      return 'Unknown Platform';
    }
  }

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

  Future<void> startLiveActivity(
      {required LiveActivityModel data, String? deviceId}) async {
    try {
      // Track which device started the Live Activity
      if (deviceId != null) {
        setActiveDevice(deviceId);
      }

      await platform.invokeMethod(
        'startLiveActivity',
        data.toJson(),
      );

      final platformName = _getPlatformName();
      debugPrint(
          'Live Activity started successfully on $platformName${deviceId != null ? ' for device: $deviceId' : ''}');
    } on PlatformException catch (e) {
      debugPrint("Failed to start live activity: '${e.message}'.");
    }
  }

  Future<void> updateLiveActivity(
      {required LiveActivityModel data, String? deviceId}) async {
    try {
      // Track which device is updating the Live Activity
      if (deviceId != null) {
        setActiveDevice(deviceId);
      }

      await platform.invokeMethod(
        'updateLiveActivity',
        data.toJson(),
      );

      final platformName = _getPlatformName();
      debugPrint(
          'Live Activity updated successfully on $platformName${deviceId != null ? ' for device: $deviceId' : ''}');
    } on PlatformException catch (e) {
      debugPrint("Failed to update live activity: '${e.message}'.");
    }
  }

  Future<void> endLiveActivity() async {
    try {
      await platform.invokeMethod(
        'endLiveActivity',
      );
      _activeDeviceId = null; // Clear active device when ending

      final platformName = _getPlatformName();
      debugPrint('Live Activity ended successfully on $platformName');
    } on PlatformException catch (e) {
      debugPrint("Failed to end live activity: '${e.message}'.");
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
