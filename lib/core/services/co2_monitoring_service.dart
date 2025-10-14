import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/services/notification_service.dart';
import 'package:flutter/foundation.dart';

/// Service to monitor CO2 levels and trigger notifications
class Co2MonitoringService {
  // Keep track of which thresholds have already triggered to avoid spam
  static final Map<String, Set<int>> _triggeredThresholds = {};
  static final Map<String, int> _lastCo2Value = {};

  /// Check CO2 value against notification preferences and trigger if needed
  static Future<void> checkAndNotify({
    required String deviceId,
    required String deviceName,
    required int co2Value,
    required NotificationPreferences preferences,
  }) async {
    // Check if notifications are enabled
    if (!preferences.smartphoneNotificationsEnabled) {
      return;
    }

    // Check cooldown period (only for time-based cooldown)
    if (preferences.cooldownMode == 'time' &&
        !preferences.canSendNotification) {
      debugPrint(
          'Notification cooldown active for device: $deviceId. Minutes remaining: ${preferences.cooldownMinutes - DateTime.now().difference(preferences.lastNotificationTime!).inMinutes}');
      return;
    }

    // Get last CO2 value for this device
    final lastValue = _lastCo2Value[deviceId] ?? 0;
    _lastCo2Value[deviceId] = co2Value;

    // Initialize triggered thresholds set for this device if not exists
    _triggeredThresholds[deviceId] ??= <int>{};

    // Find the highest threshold that's exceeded and enabled
    NotificationThreshold? thresholdToTrigger;
    for (final threshold
        in preferences.notificationThresholds.where((t) => t.enabled).toList()
          ..sort((a, b) => b.co2Threshold.compareTo(a.co2Threshold))) {
      if (co2Value >= threshold.co2Threshold) {
        thresholdToTrigger = threshold;
        break;
      }
    }

    if (thresholdToTrigger == null) {
      // CO2 is below all thresholds, reset triggered thresholds
      _triggeredThresholds[deviceId]?.clear();
      return;
    }

    // Only trigger notification if CO2 is crossing ABOVE the threshold (not falling)
    // This prevents notifications when CO2 is falling from a higher level
    if (lastValue >= thresholdToTrigger.co2Threshold) {
      // CO2 was already above this threshold, no notification needed
      debugPrint(
          'CO2 already above threshold ${thresholdToTrigger.co2Threshold}, no notification needed');
      return;
    }

    // Check if this threshold has already been triggered
    final thresholdId = thresholdToTrigger.id;
    if (_triggeredThresholds[deviceId]!.contains(thresholdId)) {
      // Already triggered, don't send notification again unless value went down and came back up
      if (lastValue < thresholdToTrigger.co2Threshold &&
          co2Value >= thresholdToTrigger.co2Threshold) {
        // Value went down below threshold and came back up - re-trigger notification
        debugPrint(
            'CO2 came back above threshold ${thresholdToTrigger.co2Threshold}, re-triggering notification');
        // Remove from triggered set so it can be triggered again
        _triggeredThresholds[deviceId]!.remove(thresholdId);
      } else {
        // Still above threshold or didn't cross from below - no notification
        debugPrint(
            'Threshold ${thresholdToTrigger.co2Threshold} already triggered, skipping notification');
        return;
      }
    }

    // Send notification
    try {
      await NotificationService.showCO2Notification(
        deviceName: deviceName,
        co2Value: co2Value,
        threshold: thresholdToTrigger.co2Threshold,
        customMessage: thresholdToTrigger.message,
        playSound: preferences.notificationSoundEnabled,
        vibrate: preferences.notificationVibrationEnabled,
      );

      // Mark this threshold as triggered
      _triggeredThresholds[deviceId]!.add(thresholdId);

      // Update last notification time through the provider
      // Note: This should be called from the provider to update the state
      debugPrint(
          'CO2 notification sent for device: $deviceName, value: $co2Value, threshold: ${thresholdToTrigger.co2Threshold}');
    } catch (e) {
      debugPrint('Error sending CO2 notification: $e');
    }
  }

  /// Reset triggered thresholds for a device (e.g., when reconnecting)
  static void resetTriggeredThresholds(String deviceId) {
    _triggeredThresholds[deviceId]?.clear();
    _lastCo2Value.remove(deviceId);
    debugPrint('Reset triggered thresholds for device: $deviceId');
  }

  /// Clear all monitoring state
  static void clearAll() {
    _triggeredThresholds.clear();
    _lastCo2Value.clear();
    debugPrint('Cleared all CO2 monitoring state');
  }
}
