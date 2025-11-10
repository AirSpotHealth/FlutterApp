import 'package:isar_plus/isar_plus.dart';

part 'notification_preferences.g.dart';

@Collection(ignore: {'copyWith'})
class NotificationPreferences {
  /// The device id - used as primary key
  @Id()
  final String deviceId;

  /// Enable smartphone notifications for high CO2
  final bool smartphoneNotificationsEnabled;

  /// Custom CO2 thresholds for notifications (can use alarm levels or custom)
  final List<NotificationThreshold> notificationThresholds;

  /// Notification vibration enabled
  final bool notificationVibrationEnabled;

  /// Show notification even when app is in foreground
  final bool showInForeground;

  /// Cooldown mode: 'time' for time-based cooldown, 'once' for once-per-crossing
  final String cooldownMode;

  /// Minimum time between notifications (in minutes) to avoid spam (only used when cooldownMode is 'time')
  final int cooldownMinutes;

  /// Last notification time (to implement time-based cooldown)
  final DateTime? lastNotificationTime;

  /// Last threshold value that triggered a notification (for time-based cooldown mode)
  final int? lastTriggeredThresholdValue;

  /// List of threshold IDs that have been triggered (for once-per-crossing mode)
  final List<int> triggeredThresholds;

  const NotificationPreferences({
    required this.deviceId,
    this.smartphoneNotificationsEnabled = false,
    this.notificationThresholds = defaultNotificationThresholds,
    this.notificationVibrationEnabled = true, // Vibration enabled by default
    this.showInForeground = true,
    this.cooldownMode = 'once',
    this.cooldownMinutes = 5,
    this.lastNotificationTime,
    this.lastTriggeredThresholdValue,
    this.triggeredThresholds = const [],
  });

  NotificationPreferences.empty({required this.deviceId})
      : smartphoneNotificationsEnabled = false,
        notificationThresholds = defaultNotificationThresholds,
        notificationVibrationEnabled = true, // Vibration enabled by default
        showInForeground = true,
        cooldownMode = 'once',
        cooldownMinutes = 5,
        lastNotificationTime = null,
        lastTriggeredThresholdValue = null,
        triggeredThresholds = const [];

  NotificationPreferences copyWith({
    String? deviceId,
    bool? smartphoneNotificationsEnabled,
    List<NotificationThreshold>? notificationThresholds,
    bool? notificationVibrationEnabled,
    bool? showInForeground,
    String? cooldownMode,
    int? cooldownMinutes,
    DateTime? Function()? lastNotificationTime,
    int? Function()? lastTriggeredThresholdValue,
    List<int>? triggeredThresholds,
  }) {
    return NotificationPreferences(
      deviceId: deviceId ?? this.deviceId,
      smartphoneNotificationsEnabled:
          smartphoneNotificationsEnabled ?? this.smartphoneNotificationsEnabled,
      notificationThresholds:
          notificationThresholds ?? this.notificationThresholds,
      notificationVibrationEnabled:
          notificationVibrationEnabled ?? this.notificationVibrationEnabled,
      showInForeground: showInForeground ?? this.showInForeground,
      cooldownMode: cooldownMode ?? this.cooldownMode,
      cooldownMinutes: cooldownMinutes ?? this.cooldownMinutes,
      lastNotificationTime: lastNotificationTime != null
          ? lastNotificationTime()
          : this.lastNotificationTime,
      lastTriggeredThresholdValue: lastTriggeredThresholdValue != null
          ? lastTriggeredThresholdValue()
          : this.lastTriggeredThresholdValue,
      triggeredThresholds: triggeredThresholds ?? this.triggeredThresholds,
    );
  }

  /// Check if cooldown period has passed
  bool get canSendNotification {
    // For 'once' mode, cooldown is handled by the monitoring service
    if (cooldownMode == 'once') return true;

    // For 'time' mode, check time-based cooldown
    if (lastNotificationTime == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastNotificationTime!);
    return difference.inMinutes >= cooldownMinutes;
  }
}

@embedded
class NotificationThreshold {
  final int id;
  final int co2Threshold;
  final bool enabled;
  final String? message; // Custom message for this threshold

  const NotificationThreshold({
    required this.id,
    required this.co2Threshold,
    required this.enabled,
    this.message,
  });

  NotificationThreshold copyWith({
    int? id,
    int? co2Threshold,
    bool? enabled,
    String? message,
  }) {
    return NotificationThreshold(
      id: id ?? this.id,
      co2Threshold: co2Threshold ?? this.co2Threshold,
      enabled: enabled ?? this.enabled,
      message: message ?? this.message,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationThreshold &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          co2Threshold == other.co2Threshold &&
          enabled == other.enabled &&
          message == other.message;

  @override
  int get hashCode =>
      id.hashCode ^
      co2Threshold.hashCode ^
      enabled.hashCode ^
      (message?.hashCode ?? 0);

  factory NotificationThreshold.empty(int id) {
    return NotificationThreshold(
      id: id,
      co2Threshold: 0,
      enabled: false,
      message: null,
    );
  }
}

// Default notification thresholds aligned with device alarm levels
const defaultNotificationThresholds = [
  NotificationThreshold(
    id: 0,
    co2Threshold: 800,
    enabled: true,
    message: 'CO₂ level is getting high',
  ),
  NotificationThreshold(
    id: 1,
    co2Threshold: 1000,
    enabled: true,
    message: 'Warning: High CO₂ detected',
  ),
  NotificationThreshold(
    id: 2,
    co2Threshold: 1200,
    enabled: true,
    message: 'Alert: Very high CO₂!',
  ),
  NotificationThreshold(
    id: 3,
    co2Threshold: 1500,
    enabled: true,
    message: 'Critical: Dangerous CO₂ levels!',
  ),
];
