import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/services/notification_service.dart';
import 'package:flutter/foundation.dart';

/// Service to monitor CO2 levels and trigger notifications
class Co2MonitoringService {
  // Keep track of which thresholds have already triggered to avoid spam
  static final Map<String, Set<int>> _triggeredThresholds = {};
  static final Map<String, int> _lastCo2Value = {};

  /// Check CO2 value against notification preferences and trigger if needed
  /// Returns updated preferences with triggered thresholds and last notification time if any changes were made
  static Future<NotificationPreferences?> checkAndNotify({
    required String deviceId,
    required String deviceName,
    required int co2Value,
    required NotificationPreferences preferences,
  }) async {
    // Check if notifications are enabled
    if (!preferences.smartphoneNotificationsEnabled) {
      return null;
    }

    // Check cooldown period (only for time-based cooldown)
    // Note: We'll check this again later if we need to bypass for higher thresholds
    final bool cooldownActive =
        preferences.cooldownMode == 'time' && !preferences.canSendNotification;

    // Get last CO2 value for this device
    final lastValue = _lastCo2Value[deviceId] ?? 0;
    _lastCo2Value[deviceId] = co2Value;

    // Use the persisted triggered thresholds from preferences (convert List to Set for operations)
    final triggeredThresholds = Set<int>.from(preferences.triggeredThresholds);
    debugPrint(
        'CO2 Monitoring - Device: $deviceId, Current CO2: $co2Value, Last CO2: $lastValue');
    debugPrint(
        'CO2 Monitoring - Triggered thresholds from preferences: ${preferences.triggeredThresholds}');
    debugPrint(
        'CO2 Monitoring - Working with triggered thresholds: $triggeredThresholds');

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
      // CO2 is below all thresholds, reset triggered thresholds and last threshold value
      if (triggeredThresholds.isNotEmpty ||
          preferences.lastTriggeredThresholdValue != null) {
        debugPrint(
            'CO2 below all thresholds, clearing triggered thresholds and last threshold value');
        return preferences.copyWith(
          triggeredThresholds: const [],
          lastTriggeredThresholdValue: () => null,
        );
      }
      return null;
    }

    // At this point, thresholdToTrigger is guaranteed to be non-null
    final threshold = thresholdToTrigger;

    // For 'once' mode, check if threshold has already been triggered
    // For 'time' mode, skip this check and rely on time-based cooldown instead
    final thresholdId = threshold.id;
    if (preferences.cooldownMode == 'once') {
      // Check if this threshold has already been triggered
      if (triggeredThresholds.contains(thresholdId)) {
        // Already triggered, don't send notification again unless value went down and came back up
        if (lastValue < threshold.co2Threshold &&
            co2Value >= threshold.co2Threshold &&
            lastValue != 0) {
          // Only allow re-triggering if we have valid lastValue (not app restart)
          // Value went down below threshold and came back up - re-trigger notification
          debugPrint(
              'CO2 came back above threshold ${threshold.co2Threshold}, re-triggering notification');
          // Remove from triggered set so it can be triggered again
          triggeredThresholds.remove(thresholdId);
        } else {
          // Still above threshold, didn't cross from below, or app just restarted - no notification
          debugPrint(
              'Threshold ${threshold.co2Threshold} already triggered, skipping notification (lastValue: $lastValue) [once mode]');
          return null;
        }
      }

      // Only trigger notification if CO2 is crossing ABOVE the threshold (not falling)
      // This prevents notifications when CO2 is falling from a higher level
      if (lastValue >= threshold.co2Threshold && lastValue != 0) {
        // CO2 was already above this threshold, no notification needed
        debugPrint(
            'CO2 already above threshold ${threshold.co2Threshold}, no notification needed [once mode]');
        return null;
      }
    } else {
      // Time-based cooldown mode
      // Check if cooldown is active
      if (cooldownActive) {
        // Cooldown is active, but check if this is a HIGHER threshold than the last triggered one
        final lastThresholdValue = preferences.lastTriggeredThresholdValue ?? 0;
        if (threshold.co2Threshold > lastThresholdValue) {
          // Higher threshold - bypass cooldown and send notification
          debugPrint(
              'Time-based cooldown: Bypassing cooldown for higher threshold (${threshold.co2Threshold} > $lastThresholdValue)');
        } else {
          // Same or lower threshold - respect cooldown
          debugPrint(
              'Notification cooldown active for device: $deviceId. Minutes remaining: ${preferences.cooldownMinutes - DateTime.now().difference(preferences.lastNotificationTime!).inMinutes}');
          return null;
        }
      } else {
        // Cooldown not active - notification will be sent
        debugPrint(
            'Time-based cooldown mode - notification will be sent (cooldown not active)');
      }
    }

    // Send notification
    try {
      debugPrint(
          'CO2 Monitoring - Sound: always on, Vibration enabled: ${preferences.notificationVibrationEnabled}');

      await NotificationService.showCO2Notification(
        deviceName: deviceName,
        co2Value: co2Value,
        threshold: threshold.co2Threshold,
        customMessage: threshold.message,
        vibrate: preferences.notificationVibrationEnabled,
      );

      // Mark this threshold as triggered (only for 'once' mode)
      if (preferences.cooldownMode == 'once') {
        triggeredThresholds.add(thresholdId);
      }

      debugPrint(
          'CO2 notification sent for device: $deviceName, value: $co2Value, threshold: ${threshold.co2Threshold}');
    } catch (e) {
      debugPrint('Error sending CO2 notification: $e');
    }

    // Return updated preferences with the new triggered threshold (if in 'once' mode), last notification time, and last threshold value
    return preferences.copyWith(
      triggeredThresholds: triggeredThresholds.toList(),
      lastNotificationTime: () => DateTime
          .now(), // Update last notification time for time-based cooldown
      lastTriggeredThresholdValue: () => threshold
          .co2Threshold, // Track which threshold triggered for comparison
    );
  }

  /// Reset triggered thresholds for a device (e.g., when reconnecting)
  static void resetTriggeredThresholds(String deviceId) {
    _triggeredThresholds[deviceId]?.clear();
    _lastCo2Value.remove(deviceId);
    debugPrint('Reset triggered thresholds for device: $deviceId');
  }

  /// Clear all monitoring state
  static void clearAll() {
    _lastCo2Value.clear();
    debugPrint('Cleared all CO2 monitoring state');
  }
}
