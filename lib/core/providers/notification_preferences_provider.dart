import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

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
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating notification preferences: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> setSmartNotifications(bool enabled) => updatePreferences(
      (p) => p.copyWith(smartNotificationsEnabled: enabled));

  Future<void> setNotifyStuffy(bool v) =>
      updatePreferences((p) => p.copyWith(notifyStuffy: v));

  Future<void> setNotifyPoor(bool v) =>
      updatePreferences((p) => p.copyWith(notifyPoor: v));

  Future<void> setNotifyImproved(bool v) =>
      updatePreferences((p) => p.copyWith(notifyImproved: v));

  Future<void> setVibration(bool v) =>
      updatePreferences((p) => p.copyWith(vibrationEnabled: v));

  Future<void> setShowInForeground(bool v) =>
      updatePreferences((p) => p.copyWith(showInForeground: v));

  Future<void> setReminders(bool v) =>
      updatePreferences((p) => p.copyWith(remindersEnabled: v));

  Future<void> setThresholds({int? stuffy, int? better, int? poor}) =>
      updatePreferences((p) => p.copyWith(
            stuffyThreshold: stuffy,
            betterThreshold: better,
            poorThreshold: poor,
          ));

  Future<void> setTiming({
    int? stuffyPersistMinutes,
    int? betterPersistMinutes,
    int? poorPersistMinutes,
    int? reminderMinutes,
    int? highPriorityReminderMinutes,
    int? recoveryMinutes,
  }) =>
      updatePreferences((p) => p.copyWith(
            stuffyPersistMinutes: stuffyPersistMinutes,
            betterPersistMinutes: betterPersistMinutes,
            poorPersistMinutes: poorPersistMinutes,
            reminderMinutes: reminderMinutes,
            highPriorityReminderMinutes: highPriorityReminderMinutes,
            recoveryMinutes: recoveryMinutes,
          ));

  Future<void> setQuietHours({
    bool? enabled,
    DateTime? start,
    DateTime? end,
  }) =>
      updatePreferences((p) => p.copyWith(
            quietHoursEnabled: enabled,
            quietHoursStart: start != null ? () => start : null,
            quietHoursEnd: end != null ? () => end : null,
          ));

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    await updatePreferences(
      (prefs) => NotificationPreferences.empty(deviceId: deviceId),
    );
  }
}
