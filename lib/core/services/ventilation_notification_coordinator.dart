import 'dart:async';

import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/models/ventilation_event.dart';
import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:airspothealth/core/providers/notification_preferences_provider.dart';
import 'package:airspothealth/core/providers/ventilation_alert_provider.dart';
import 'package:airspothealth/core/providers/ventilation_history_provider.dart';
import 'package:airspothealth/core/router/app_router.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/notification_service.dart';
import 'package:airspothealth/core/services/ventilation_action_handler.dart';
import 'package:airspothealth/core/services/ventilation_event_engine.dart';
import 'package:airspothealth/core/services/vibration_pattern_service.dart';
import 'package:airspothealth/features/notification_settings/widgets/guidance_sheet.dart';
import 'package:airspothealth/features/notification_settings/widgets/taken_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

final ventilationCoordinatorProvider =
    Provider<VentilationNotificationCoordinator>((ref) {
  final coordinator = VentilationNotificationCoordinator(ref);
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

/// Glue between BLE readings, the pure [VentilationEventEngine], storage,
/// system notifications and the in-app alert card.
class VentilationNotificationCoordinator {
  VentilationNotificationCoordinator(this._ref) {
    instance = this;
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => _onTick());
    _restoreActiveEvents();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VentilationActionHandler.flushDeferredUi();
    });
  }

  static VentilationNotificationCoordinator? instance;

  final Ref _ref;
  final IsarService _isar = IsarService();
  final VentilationEventEngine engine = VentilationEventEngine();
  final Map<String, String> _deviceNames = {};
  Timer? _ticker;

  void dispose() {
    _ticker?.cancel();
    if (instance == this) instance = null;
  }

  bool get canPresentUi => AppRouter.navigatorKey.currentContext != null;

  bool get _appInForeground =>
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  NotificationPreferences _prefs(String deviceId) =>
      _ref.read(notificationPreferencesProvider(deviceId));

  // ---------------------------------------------------------------- inputs

  /// A fresh live CO₂ reading from either device model.
  Future<void> onReading({
    required String deviceId,
    required String deviceName,
    required int value,
    required DateTime at,
  }) async {
    if (value <= 0) return; // sensor error / warm-up frames carry no reading
    _deviceNames[deviceId] = deviceName;
    await drainPendingActions();
    final prefs = _prefs(deviceId);
    if (!prefs.smartNotificationsEnabled) {
      debugPrint('Ventilation[$deviceId]: smart notifications OFF, $value ppm ignored');
    }
    final quiet = prefs.isInQuietHours(at);
    final effects = engine.onReading(
      deviceId,
      VentilationReading(value, at),
      prefs,
      deliveryAllowed: !quiet,
    );
    if (prefs.smartNotificationsEnabled) {
      debugPrint(
          'Ventilation[$deviceId]: $value ppm at ${at.toIso8601String()} '
          'quiet=$quiet ${_describe(deviceId, at)} '
          'effects=${effects.map((e) => e.runtimeType).join(',')}');
    }
    await _apply(deviceId, effects, prefs);
  }

  /// Compact window/event summary for logs.
  String _describe(String deviceId, DateTime now) {
    final s = engine.stateFor(deviceId);
    final windows = s.aboveSince.entries
        .where((e) => e.value != null)
        .map((e) =>
            '${e.key.name}:${now.difference(e.value!).inSeconds}s'
            '${s.armed[e.key] == true ? '' : '(fired)'}')
        .join(' ');
    final event = s.activeEvent;
    final ev = event == null
        ? 'no-event'
        : 'event=${event.highestLevelNotified.name} peak=${event.peakValue}'
            '${event.reminderDueAt != null ? ' reminder@${event.reminderDueAt}' : ''}';
    final below =
        s.belowSince == null ? '' : ' below:${now.difference(s.belowSince!).inSeconds}s';
    return 'windows[${windows.isEmpty ? '-' : windows}]$below $ev';
  }

  void onConnected(String deviceId) => engine.onConnected(deviceId);

  void onDisconnected(String deviceId) => engine.onDisconnected(deviceId);

  Future<void> onAppResumed() async {
    await drainPendingActions();
    await VentilationActionHandler.flushDeferredUi();
  }

  Future<void> _onTick() async {
    await drainPendingActions();
    final now = DateTime.now();
    for (final deviceId in engine.deviceIds.toList()) {
      final prefs = _prefs(deviceId);
      final effects = engine.onTick(deviceId, now, prefs,
          deliveryAllowed: !prefs.isInQuietHours(now));
      await _apply(deviceId, effects, prefs);
    }
  }

  /// Master switch turned off: forget engine state and clear any alert.
  Future<void> onNotificationsDisabled(String deviceId) async {
    final effects = engine.clear(deviceId, DateTime.now());
    await _apply(deviceId, effects, _prefs(deviceId));
    await _dismissDelivered(deviceId);
  }

  // ---------------------------------------------------------------- actions

  Future<void> requestReminder(String deviceId, VentilationLevel level) async {
    final prefs = _prefs(deviceId);
    final effects =
        engine.requestReminder(deviceId, level, DateTime.now(), prefs);
    await _apply(deviceId, effects, prefs);
    await _dismissDelivered(deviceId);
  }

  Future<void> recordUserAction(
      String deviceId, VentilationUserAction action) async {
    final effects = engine.recordUserAction(deviceId, action, DateTime.now());
    await _apply(deviceId, effects, _prefs(deviceId));
    await _dismissDelivered(deviceId);
  }

  Future<void> dismiss(String deviceId) => _dismissDelivered(deviceId);

  Future<void> drainPendingActions() async {
    final pending = await VentilationActionHandler.takeAll();
    for (final action in pending) {
      switch (action.actionId) {
        case VentilationActionIds.remind:
          final prefs = _prefs(action.deviceId);
          final effects = engine.requestReminder(
              action.deviceId, action.level, action.at, prefs);
          await _apply(action.deviceId, effects, prefs);
          break;
        case VentilationActionIds.done:
          await _dismissDelivered(action.deviceId);
          break;
        default:
          debugPrint('Ventilation: unknown queued action ${action.actionId}');
      }
    }
  }

  /// Present the UI for a tap or a UI-opening action button.
  Future<void> presentUiAction(String actionId, VentilationPayload p) async {
    if (actionId == VentilationActionIds.takenAction ||
        actionId == VentilationActionIds.viewResult) {
      await _dismissDelivered(p.deviceId);
    }
    _presentUi(actionId, p);
  }

  void _presentUi(String actionId, VentilationPayload p) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;
    switch (actionId) {
      case VentilationActionIds.takenAction:
        showTakenActionSheet(context, deviceId: p.deviceId);
      case VentilationActionIds.whatCanIDo:
        showGuidanceSheet(context, deviceId: p.deviceId);
      case VentilationActionIds.viewResult:
        openEventDetail(p.deviceId, p.eventId);
      default: // body tap
        if (p.kind == VentilationNotificationKind.recovery) {
          openEventDetail(p.deviceId, p.eventId);
        } else {
          openLiveReading(p.deviceId);
        }
    }
  }

  void openEventDetail(String deviceId, String eventId) {
    AppRouter.router.pushNamed(
      RouteNames.ventilationEventDetail,
      pathParameters: {'deviceId': deviceId, 'eventId': eventId},
    );
  }

  void openLiveReading(String deviceId) {
    AppRouter.router.pushNamed(
      RouteNames.deviceGraph,
      pathParameters: {'deviceId': deviceId},
    );
  }

  // ---------------------------------------------------------------- effects

  Future<void> _apply(
    String deviceId,
    List<VentilationEffect> effects,
    NotificationPreferences prefs,
  ) async {
    for (final effect in effects) {
      switch (effect) {
        case PersistEvent(:final event):
          _persist(event);
        case NotifyLevel(:final level, :final event, :final currentValue):
          await _deliver(
            deviceId: deviceId,
            event: event,
            level: level,
            kind: VentilationNotificationKind.alert,
            title: level.title,
            body: _body(level, currentValue, prefs),
            prefs: prefs,
          );
        case NotifyReminder(:final level, :final event, :final currentValue):
          await _deliver(
            deviceId: deviceId,
            event: event,
            level: level,
            kind: VentilationNotificationKind.reminder,
            title: level.title,
            body: _body(level, currentValue, prefs),
            prefs: prefs,
          );
        case NotifyRecovery(:final event, :final currentValue, :final elapsed):
          await _deliver(
            deviceId: deviceId,
            event: event,
            level: VentilationLevel.none,
            kind: VentilationNotificationKind.recovery,
            title: VentilationCopy.recoveryTitle,
            body: VentilationCopy.recoveryBody(
              peakValue: event.peakValue,
              currentValue: currentValue,
              elapsed: elapsed,
            ),
            prefs: prefs,
          );
      }
    }
  }

  String _body(VentilationLevel level, int value, NotificationPreferences p) =>
      VentilationCopy.body(
        level: level,
        currentValue: value,
        betterThreshold: p.betterThreshold,
        betterPersistMinutes: p.betterPersistMinutes,
        poorThreshold: p.poorThreshold,
      );

  void _persist(VentilationEvent event) {
    var toSave = event;
    if (toSave.deviceName.isEmpty) {
      final name = _deviceNames[event.deviceId];
      if (name != null) toSave = toSave.copyWith(deviceName: name);
    }
    try {
      _isar.write((isar) => isar.ventilationEvents.put(toSave));
      _ref.read(ventilationHistoryVersionProvider.notifier).state++;
    } catch (e) {
      debugPrint('Ventilation: failed to persist event ${event.id}: $e');
    }
  }

  void _restoreActiveEvents() {
    try {
      final active = _isar.read<List<VentilationEvent>>((isar) => isar
          .ventilationEvents
          .where()
          .statusEqualTo(VentilationEventStatus.active)
          .findAll());
      for (final event in active) {
        engine.restoreEvent(event);
        debugPrint('Ventilation: restored active event ${event.id}');
      }
    } catch (e) {
      debugPrint('Ventilation: could not restore events: $e');
    }
  }

  Future<void> _deliver({
    required String deviceId,
    required VentilationEvent event,
    required VentilationLevel level,
    required VentilationNotificationKind kind,
    required String title,
    required String body,
    required NotificationPreferences prefs,
  }) async {
    final reminderMinutes = VentilationCopy.reminderMinutesFor(
      level,
      reminderMinutes: prefs.reminderMinutes,
      highPriorityReminderMinutes: prefs.highPriorityReminderMinutes,
    );
    final payload = VentilationPayload(
      deviceId: deviceId,
      eventId: event.id,
      level: level,
      kind: kind,
    );

    debugPrint('Ventilation[$deviceId]: deliver ${kind.name} ${level.name} '
        'foreground=$_appInForeground "$title"');
    if (_appInForeground) {
      if (!prefs.showInForeground) {
        debugPrint('Ventilation: app open and foreground alerts off; skipped');
        return;
      }
      _ref.read(ventilationAlertProvider.notifier).show(VentilationAlert(
            deviceId: deviceId,
            eventId: event.id,
            level: level,
            kind: kind,
            title: title,
            body: body,
            reminderMinutes: reminderMinutes,
            remindersEnabled: prefs.remindersEnabled,
          ));
    } else {
      await NotificationService.showVentilationNotification(
        deviceId: deviceId,
        deviceName: event.deviceName.isEmpty
            ? (_deviceNames[deviceId] ?? '')
            : event.deviceName,
        level: level,
        kind: kind,
        title: title,
        body: body,
        reminderMinutes: reminderMinutes,
        remindersEnabled: prefs.remindersEnabled,
        payload: payload.encode(),
      );
    }

    if (prefs.vibrationEnabled && kind != VentilationNotificationKind.recovery) {
      await VibrationPatternService.triggerForLevel(level);
    }
  }

  Future<void> _dismissDelivered(String deviceId) async {
    _ref.read(ventilationAlertProvider.notifier).dismiss(deviceId: deviceId);
    await NotificationService.cancelVentilationNotification(deviceId);
  }
}
