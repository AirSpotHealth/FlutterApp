import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:isar_plus/isar_plus.dart';

part 'ventilation_event.g.dart';

/// One continuing ventilation episode for a device: from the first persisted
/// threshold until sustained recovery (or expiry from missing readings).
/// Doubles as the notification-history record and the durable engine state.
@Collection(ignore: {'copyWith', 'hasDeteriorationNotification', 'isActive'})
class VentilationEvent {
  VentilationEvent({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.startedAt,
    required this.startValue,
    required this.peakValue,
    required this.peakAt,
    required this.lastValue,
    required this.lastReadingAt,
    this.endedAt,
    this.status = VentilationEventStatus.active,
    this.highestLevelNotified = VentilationLevel.none,
    this.notifications = const [],
    this.userAction = VentilationUserAction.none,
    this.userActionAt,
    this.reminderDueAt,
    this.reminderLevel = VentilationLevel.none,
    this.recoveredAt,
    this.recoveryValue,
    this.recoveryNotified = false,
  });

  static String makeId(String deviceId, DateTime startedAt) =>
      '$deviceId:${startedAt.millisecondsSinceEpoch}';

  @Id()
  final String id;

  @Index()
  final String deviceId;

  final String deviceName;

  final DateTime startedAt;
  final DateTime? endedAt;

  @EnumValue()
  final VentilationEventStatus status;

  /// Reading at the start of the persistence window that opened the event.
  final int startValue;
  final int peakValue;
  final DateTime peakAt;
  final int lastValue;
  final DateTime lastReadingAt;

  @EnumValue()
  final VentilationLevel highestLevelNotified;

  final List<VentilationNotificationRecord> notifications;

  @EnumValue()
  final VentilationUserAction userAction;
  final DateTime? userActionAt;

  /// Pending "Remind me" request; null when none.
  final DateTime? reminderDueAt;
  @EnumValue()
  final VentilationLevel reminderLevel;

  final DateTime? recoveredAt;
  final int? recoveryValue;
  final bool recoveryNotified;

  bool get isActive => status == VentilationEventStatus.active;

  bool get hasDeteriorationNotification => notifications
      .any((n) => n.kind != VentilationNotificationKind.recovery);

  VentilationEvent copyWith({
    String? deviceName,
    DateTime? Function()? endedAt,
    VentilationEventStatus? status,
    int? peakValue,
    DateTime? peakAt,
    int? lastValue,
    DateTime? lastReadingAt,
    VentilationLevel? highestLevelNotified,
    List<VentilationNotificationRecord>? notifications,
    VentilationUserAction? userAction,
    DateTime? Function()? userActionAt,
    DateTime? Function()? reminderDueAt,
    VentilationLevel? reminderLevel,
    DateTime? Function()? recoveredAt,
    int? Function()? recoveryValue,
    bool? recoveryNotified,
  }) {
    return VentilationEvent(
      id: id,
      deviceId: deviceId,
      deviceName: deviceName ?? this.deviceName,
      startedAt: startedAt,
      startValue: startValue,
      endedAt: endedAt != null ? endedAt() : this.endedAt,
      status: status ?? this.status,
      peakValue: peakValue ?? this.peakValue,
      peakAt: peakAt ?? this.peakAt,
      lastValue: lastValue ?? this.lastValue,
      lastReadingAt: lastReadingAt ?? this.lastReadingAt,
      highestLevelNotified: highestLevelNotified ?? this.highestLevelNotified,
      notifications: notifications ?? this.notifications,
      userAction: userAction ?? this.userAction,
      userActionAt: userActionAt != null ? userActionAt() : this.userActionAt,
      reminderDueAt:
          reminderDueAt != null ? reminderDueAt() : this.reminderDueAt,
      reminderLevel: reminderLevel ?? this.reminderLevel,
      recoveredAt: recoveredAt != null ? recoveredAt() : this.recoveredAt,
      recoveryValue:
          recoveryValue != null ? recoveryValue() : this.recoveryValue,
      recoveryNotified: recoveryNotified ?? this.recoveryNotified,
    );
  }
}

/// A notification that was delivered (or shown in-app) for an event.
@Embedded(ignore: {'copyWith'})
class VentilationNotificationRecord {
  const VentilationNotificationRecord({
    this.level = VentilationLevel.none,
    this.kind = VentilationNotificationKind.alert,
    this.co2 = 0,
    this.sentAt,
  });

  @EnumValue()
  final VentilationLevel level;

  @EnumValue()
  final VentilationNotificationKind kind;

  final int co2;

  final DateTime? sentAt;
}
