import 'package:isar_plus/isar_plus.dart';

part 'notification_preferences.g.dart';

/// Per-device smartphone notification preferences for the ventilation event
/// engine. Engine state itself lives in [VentilationEvent]; this record only
/// holds what the user configured.
@Collection(ignore: {'copyWith', 'isInQuietHours'})
class NotificationPreferences {
  /// The device id - used as primary key
  @Id()
  final String deviceId;

  /// Master switch: "Smart notifications".
  final bool smartNotificationsEnabled;

  /// "Air is getting stuffy" (early prompt) enabled.
  final bool notifyStuffy;

  /// "Ventilation is poor" (high priority) enabled.
  final bool notifyPoor;

  /// "Air improves again" (recovery) enabled.
  final bool notifyImproved;

  /// Vibrate with notifications.
  final bool vibrationEnabled;

  /// Show alerts while the app is open (in-app alert card).
  final bool showInForeground;

  /// Offer "Remind me" and honour reminder requests.
  final bool remindersEnabled;

  // ---- Advanced: thresholds (ppm) ----
  final int stuffyThreshold;
  final int betterThreshold;
  final int poorThreshold;

  // ---- Advanced: timing (minutes) ----
  final int stuffyPersistMinutes;
  final int betterPersistMinutes;
  final int poorPersistMinutes;
  final int reminderMinutes;
  final int highPriorityReminderMinutes;
  final int recoveryMinutes;

  // ---- Advanced: quiet hours ----
  final bool quietHoursEnabled;
  final DateTime? quietHoursStart;
  final DateTime? quietHoursEnd;

  static const defaultStuffyThreshold = 800;
  static const defaultBetterThreshold = 1000;
  static const defaultPoorThreshold = 1500;
  static const defaultStuffyPersistMinutes = 5;
  static const defaultBetterPersistMinutes = 10;
  static const defaultPoorPersistMinutes = 10;
  static const defaultReminderMinutes = 10;
  static const defaultHighPriorityReminderMinutes = 5;
  static const defaultRecoveryMinutes = 5;

  NotificationPreferences({
    required this.deviceId,
    this.smartNotificationsEnabled = false,
    this.notifyStuffy = true,
    this.notifyPoor = true,
    this.notifyImproved = true,
    this.vibrationEnabled = true,
    this.showInForeground = true,
    this.remindersEnabled = true,
    this.stuffyThreshold = 800,
    this.betterThreshold = 1000,
    this.poorThreshold = 1500,
    this.stuffyPersistMinutes = 5,
    this.betterPersistMinutes = 10,
    this.poorPersistMinutes = 10,
    this.reminderMinutes = 10,
    this.highPriorityReminderMinutes = 5,
    this.recoveryMinutes = 5,
    this.quietHoursEnabled = false,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  NotificationPreferences.empty({required this.deviceId})
      : smartNotificationsEnabled = false,
        notifyStuffy = true,
        notifyPoor = true,
        notifyImproved = true,
        vibrationEnabled = true,
        showInForeground = true,
        remindersEnabled = true,
        stuffyThreshold = 800,
        betterThreshold = 1000,
        poorThreshold = 1500,
        stuffyPersistMinutes = 5,
        betterPersistMinutes = 10,
        poorPersistMinutes = 10,
        reminderMinutes = 10,
        highPriorityReminderMinutes = 5,
        recoveryMinutes = 5,
        quietHoursEnabled = false,
        quietHoursStart = null,
        quietHoursEnd = null;

  NotificationPreferences copyWith({
    bool? smartNotificationsEnabled,
    bool? notifyStuffy,
    bool? notifyPoor,
    bool? notifyImproved,
    bool? vibrationEnabled,
    bool? showInForeground,
    bool? remindersEnabled,
    int? stuffyThreshold,
    int? betterThreshold,
    int? poorThreshold,
    int? stuffyPersistMinutes,
    int? betterPersistMinutes,
    int? poorPersistMinutes,
    int? reminderMinutes,
    int? highPriorityReminderMinutes,
    int? recoveryMinutes,
    bool? quietHoursEnabled,
    DateTime? Function()? quietHoursStart,
    DateTime? Function()? quietHoursEnd,
  }) {
    return NotificationPreferences(
      deviceId: deviceId,
      smartNotificationsEnabled:
          smartNotificationsEnabled ?? this.smartNotificationsEnabled,
      notifyStuffy: notifyStuffy ?? this.notifyStuffy,
      notifyPoor: notifyPoor ?? this.notifyPoor,
      notifyImproved: notifyImproved ?? this.notifyImproved,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showInForeground: showInForeground ?? this.showInForeground,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      stuffyThreshold: stuffyThreshold ?? this.stuffyThreshold,
      betterThreshold: betterThreshold ?? this.betterThreshold,
      poorThreshold: poorThreshold ?? this.poorThreshold,
      stuffyPersistMinutes: stuffyPersistMinutes ?? this.stuffyPersistMinutes,
      betterPersistMinutes: betterPersistMinutes ?? this.betterPersistMinutes,
      poorPersistMinutes: poorPersistMinutes ?? this.poorPersistMinutes,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      highPriorityReminderMinutes:
          highPriorityReminderMinutes ?? this.highPriorityReminderMinutes,
      recoveryMinutes: recoveryMinutes ?? this.recoveryMinutes,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart:
          quietHoursStart != null ? quietHoursStart() : this.quietHoursStart,
      quietHoursEnd: quietHoursEnd != null ? quietHoursEnd() : this.quietHoursEnd,
    );
  }

  /// True when [at] falls inside the configured quiet-hours window.
  /// Windows may cross midnight (e.g. 22:00 to 06:00). Only the time of day
  /// of [quietHoursStart]/[quietHoursEnd] is used.
  bool isInQuietHours(DateTime at) {
    if (!quietHoursEnabled || quietHoursStart == null || quietHoursEnd == null) {
      return false;
    }
    final start = quietHoursStart!.hour * 60 + quietHoursStart!.minute;
    final end = quietHoursEnd!.hour * 60 + quietHoursEnd!.minute;
    final now = at.hour * 60 + at.minute;
    if (start == end) return false;
    if (start < end) return now >= start && now < end;
    return now >= start || now < end; // crosses midnight
  }
}
