import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

/// Provider for notification preferences per device
final notificationPreferencesProvider = NotifierProvider.family<
    NotificationPreferencesNotifier,
    NotificationPreferences,
    String>(NotificationPreferencesNotifier.new);

class NotificationPreferencesNotifier
    extends FamilyNotifier<NotificationPreferences, String> {
  final IsarService _isarService = IsarService();

  String get deviceId => arg;

  @override
  NotificationPreferences build(String deviceId) {
    // Load preferences from database
    final prefs = _isarService.read<NotificationPreferences?>((isar) {
      return isar.notificationPreferences
          .where()
          .deviceIdEqualTo(deviceId)
          .findFirst();
    });

    return prefs ?? NotificationPreferences.empty(deviceId: deviceId);
  }

  /// Update notification preferences
  Future<void> updatePreferences(
    NotificationPreferences Function(NotificationPreferences current) update, {
    bool persist = true,
  }) async {
    try {
      final updated = update(state);
      state = updated;

      if (persist) {
        _isarService.write((isar) {
          isar.notificationPreferences.put(updated);
        });
        debugPrint('Notification preferences saved for device: $deviceId');
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating notification preferences: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Toggle smartphone notifications
  Future<void> toggleSmartphoneNotifications(bool enabled) async {
    await updatePreferences(
      (prefs) => prefs.copyWith(smartphoneNotificationsEnabled: enabled),
    );
  }

  /// Update a specific notification threshold
  Future<void> updateThreshold(
      int index, NotificationThreshold threshold) async {
    final thresholds =
        List<NotificationThreshold>.from(state.notificationThresholds);
    if (index >= 0 && index < thresholds.length) {
      thresholds[index] = threshold;
      await updatePreferences(
        (prefs) => prefs.copyWith(notificationThresholds: thresholds),
      );
    }
  }

  /// Update cooldown mode
  Future<void> updateCooldownMode(String mode) async {
    await updatePreferences(
      (prefs) => prefs.copyWith(cooldownMode: mode),
    );
  }

  /// Update cooldown period (only used for time-based cooldown)
  Future<void> updateCooldown(int minutes) async {
    await updatePreferences(
      (prefs) => prefs.copyWith(cooldownMinutes: minutes),
    );
  }

  /// Update last notification time
  Future<void> updateLastNotificationTime(DateTime time) async {
    await updatePreferences(
      (prefs) => prefs.copyWith(lastNotificationTime: time),
      persist: true,
    );
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    await updatePreferences(
      (prefs) => NotificationPreferences.empty(deviceId: deviceId),
    );
  }
}
