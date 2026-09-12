import 'dart:convert';
import 'dart:ui' show DartPluginRegistrant;

import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:airspothealth/core/services/ventilation_notification_coordinator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Payload attached to every ventilation notification.
class VentilationPayload {
  const VentilationPayload({
    required this.deviceId,
    required this.eventId,
    required this.level,
    required this.kind,
  });

  static const type = 'ventilation';

  final String deviceId;
  final String eventId;
  final VentilationLevel level;
  final VentilationNotificationKind kind;

  String encode() => jsonEncode({
        'type': type,
        'deviceId': deviceId,
        'eventId': eventId,
        'level': level.index,
        'kind': kind.index,
      });

  static VentilationPayload? tryDecode(String? raw) {
    if (raw == null || !raw.startsWith('{')) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['type'] != type) return null;
      return VentilationPayload(
        deviceId: map['deviceId'] as String,
        eventId: map['eventId'] as String,
        level: VentilationLevel.values[map['level'] as int],
        kind: VentilationNotificationKind.values[map['kind'] as int],
      );
    } catch (_) {
      return null;
    }
  }
}

/// An action chosen on a notification that must be applied to the engine.
class PendingVentilationAction {
  const PendingVentilationAction({
    required this.actionId,
    required this.deviceId,
    required this.eventId,
    required this.level,
    required this.at,
  });

  final String actionId;
  final String deviceId;
  final String eventId;
  final VentilationLevel level;
  final DateTime at;

  Map<String, dynamic> toJson() => {
        'actionId': actionId,
        'deviceId': deviceId,
        'eventId': eventId,
        'level': level.index,
        'at': at.millisecondsSinceEpoch,
      };

  static PendingVentilationAction fromJson(Map<String, dynamic> m) =>
      PendingVentilationAction(
        actionId: m['actionId'] as String,
        deviceId: m['deviceId'] as String,
        eventId: m['eventId'] as String,
        level: VentilationLevel.values[m['level'] as int],
        at: DateTime.fromMillisecondsSinceEpoch(m['at'] as int),
      );
}

/// Routes notification taps and action buttons to the coordinator.
///
/// Remind / Done can arrive on a background isolate that has no access to the
/// running engine, so they are queued in SharedPreferences and drained by the
/// coordinator on its next reading, tick or app resume. Actions that open UI
/// always arrive on the main isolate.
class VentilationActionHandler {
  VentilationActionHandler._();

  static const pendingKey = 'ventilation_pending_actions';

  /// UI to present once the app's navigator exists (cold start from a tap).
  static NotificationResponse? _deferredUi;

  /// Returns true when the response was a ventilation notification.
  static Future<bool> handle(NotificationResponse response,
      {required bool background}) async {
    final payload = VentilationPayload.tryDecode(response.payload);
    if (payload == null) return false;

    final actionId = response.actionId;
    final needsUi = actionId == null ||
        actionId.isEmpty ||
        actionId == VentilationActionIds.takenAction ||
        actionId == VentilationActionIds.whatCanIDo ||
        actionId == VentilationActionIds.viewResult;

    if (!needsUi) {
      await enqueue(PendingVentilationAction(
        actionId: actionId,
        deviceId: payload.deviceId,
        eventId: payload.eventId,
        level: payload.level,
        at: DateTime.now(),
      ));
      if (!background) {
        await VentilationNotificationCoordinator.instance?.drainPendingActions();
      }
      return true;
    }

    final coordinator = VentilationNotificationCoordinator.instance;
    if (coordinator == null || !coordinator.canPresentUi) {
      _deferredUi = response;
      return true;
    }
    await coordinator.presentUiAction(actionId ?? '', payload);
    return true;
  }

  /// Present a tap/action that arrived before the UI was ready.
  static Future<void> flushDeferredUi() async {
    final response = _deferredUi;
    if (response == null) return;
    _deferredUi = null;
    await handle(response, background: false);
  }

  static Future<void> enqueue(PendingVentilationAction action) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final list = _readList(prefs)..add(action.toJson());
    await prefs.setString(pendingKey, jsonEncode(list));
    debugPrint('Ventilation: queued ${action.actionId} for ${action.deviceId}');
  }

  static Future<List<PendingVentilationAction>> takeAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final list = _readList(prefs);
    if (list.isEmpty) return const [];
    await prefs.remove(pendingKey);
    return list
        .map((e) => PendingVentilationAction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<dynamic> _readList(SharedPreferences prefs) {
    final raw = prefs.getString(pendingKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return List<dynamic>.from(jsonDecode(raw) as List);
    } catch (_) {
      return [];
    }
  }
}

/// Background isolate entry point for notification actions.
@pragma('vm:entry-point')
Future<void> ventilationBackgroundNotificationResponse(
    NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await VentilationActionHandler.handle(response, background: true);
}
