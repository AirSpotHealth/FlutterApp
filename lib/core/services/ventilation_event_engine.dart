import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/models/ventilation_event.dart';
import 'package:airspothealth/core/models/ventilation_level.dart';

/// A reading fed into the engine.
class VentilationReading {
  const VentilationReading(this.value, this.at);
  final int value;
  final DateTime at;
}

/// Something the coordinator must do after the engine evaluated a reading.
sealed class VentilationEffect {
  const VentilationEffect();
}

/// Deliver a deterioration alert for [level] (first time in this event).
class NotifyLevel extends VentilationEffect {
  const NotifyLevel(this.level, this.event, this.currentValue);
  final VentilationLevel level;
  final VentilationEvent event;
  final int currentValue;
}

/// Re-deliver the current level with the latest reading after "Remind me".
class NotifyReminder extends VentilationEffect {
  const NotifyReminder(this.level, this.event, this.currentValue);
  final VentilationLevel level;
  final VentilationEvent event;
  final int currentValue;
}

/// Deliver the recovery confirmation.
class NotifyRecovery extends VentilationEffect {
  const NotifyRecovery(this.event, this.currentValue, this.elapsed);
  final VentilationEvent event;
  final int currentValue;
  final Duration elapsed;
}

/// The event record changed and must be written to storage.
class PersistEvent extends VentilationEffect {
  const PersistEvent(this.event);
  final VentilationEvent event;
}

/// Per-device engine state. Only [activeEvent] is durable; the windows are
/// deliberately rebuilt from fresh readings after a restart or reconnect so
/// stale data can never satisfy a persistence or recovery rule.
class VentilationEngineState {
  VentilationEngineState({required this.deviceId, this.activeEvent});

  final String deviceId;
  VentilationEvent? activeEvent;

  /// Earliest timestamp since which every reading has been >= threshold[L].
  final Map<VentilationLevel, DateTime?> aboveSince = {};

  /// Reading value at the start of the [aboveSince] window (for "rising").
  final Map<VentilationLevel, int> windowStartValue = {};

  /// Consecutive readings at or above threshold[L] (spike suppression).
  final Map<VentilationLevel, int> consecutiveAbove = {};

  /// Whether level L may notify. Cleared when notified; re-armed only after a
  /// reading below threshold[L] - hysteresis.
  final Map<VentilationLevel, bool> armed = {
    VentilationLevel.stuffy: true,
    VentilationLevel.better: true,
    VentilationLevel.poor: true,
  };

  /// Earliest timestamp since which every reading has been < stuffy threshold.
  DateTime? belowSince;

  VentilationReading? lastReading;
  bool connected = true;

  void resetWindows() {
    aboveSince.clear();
    windowStartValue.clear();
    consecutiveAbove.clear();
    belowSince = null;
    lastReading = null;
  }
}

/// Pure ventilation-event rules. No IO, no clock: callers pass timestamps.
class VentilationEventEngine {
  VentilationEventEngine({
    this.hysteresisPpm = 100,
    this.fastRecoveryDropPpm = 300,
    this.fastRecoveryMinutes = 2,
    this.staleGap = const Duration(minutes: 7),
    this.expireAfter = const Duration(minutes: 30),
  });

  /// Buffer below a crossed threshold before it re-arms.
  final int hysteresisPpm;

  /// Recovery path B: fall from peak by at least this much.
  final int fastRecoveryDropPpm;

  /// Recovery path B: minutes the reading must stay in the lowest band.
  final int fastRecoveryMinutes;

  /// A gap between readings longer than this resets all windows.
  final Duration staleGap;

  /// An active event with no readings for this long is closed as expired.
  final Duration expireAfter;

  final Map<String, VentilationEngineState> _states = {};

  static const _levels = [
    VentilationLevel.stuffy,
    VentilationLevel.better,
    VentilationLevel.poor,
  ];

  Iterable<String> get deviceIds => _states.keys;

  VentilationEngineState stateFor(String deviceId) =>
      _states.putIfAbsent(deviceId, () => VentilationEngineState(deviceId: deviceId));

  /// Adopt a durable active event (e.g. loaded from storage after restart).
  void restoreEvent(VentilationEvent event) {
    final s = stateFor(event.deviceId);
    s.activeEvent = event.isActive ? event : null;
    if (s.activeEvent != null) {
      for (final level in _levels) {
        if (level.rank <= event.highestLevelNotified.rank) {
          s.armed[level] = false;
        }
      }
    }
  }

  VentilationEvent? activeEvent(String deviceId) => _states[deviceId]?.activeEvent;

  void onDisconnected(String deviceId) {
    final s = stateFor(deviceId);
    s.connected = false;
    s.resetWindows();
  }

  void onConnected(String deviceId) {
    final s = stateFor(deviceId);
    s.connected = true;
    s.resetWindows();
  }

  /// User asked for a reminder from the notification or in-app card.
  List<VentilationEffect> requestReminder(
    String deviceId,
    VentilationLevel level,
    DateTime now,
    NotificationPreferences prefs,
  ) {
    final s = stateFor(deviceId);
    final event = s.activeEvent;
    if (event == null || !prefs.remindersEnabled) return const [];
    final minutes = VentilationCopy.reminderMinutesFor(
      level,
      reminderMinutes: prefs.reminderMinutes,
      highPriorityReminderMinutes: prefs.highPriorityReminderMinutes,
    );
    s.activeEvent = event.copyWith(
      reminderDueAt: () => now.add(Duration(minutes: minutes)),
      reminderLevel: level,
    );
    return [PersistEvent(s.activeEvent!)];
  }

  /// User recorded what they did after "I've taken action".
  List<VentilationEffect> recordUserAction(
    String deviceId,
    VentilationUserAction action,
    DateTime now,
  ) {
    final s = stateFor(deviceId);
    final event = s.activeEvent;
    if (event == null) return const [];
    s.activeEvent = event.copyWith(
      userAction: action,
      userActionAt: () => now,
      reminderDueAt: () => null, // taking action replaces a pending reminder
      reminderLevel: VentilationLevel.none,
    );
    return [PersistEvent(s.activeEvent!)];
  }

  /// User dismissed the recovery notification / card with "Done".
  List<VentilationEffect> dismissRecovery(String deviceId) => const [];

  /// Forget everything for a device (master switch turned off).
  List<VentilationEffect> clear(String deviceId, DateTime now) {
    final s = _states.remove(deviceId);
    final event = s?.activeEvent;
    if (event == null) return const [];
    return [
      PersistEvent(event.copyWith(
        status: VentilationEventStatus.expired,
        endedAt: () => now,
      )),
    ];
  }

  /// Timer-driven evaluation: reminders and expiry without a new reading.
  ///
  /// [deliveryAllowed] is false during quiet hours: state keeps tracking but
  /// nothing is emitted or marked as notified, so it fires afterwards.
  List<VentilationEffect> onTick(
    String deviceId,
    DateTime now,
    NotificationPreferences prefs, {
    bool deliveryAllowed = true,
  }) {
    final s = _states[deviceId];
    if (s == null) return const [];
    final effects = <VentilationEffect>[];
    _expireIfStale(s, now, effects);
    _fireDueReminder(s, now, prefs, effects,
        currentValue: null, deliveryAllowed: deliveryAllowed);
    return effects;
  }

  /// Evaluate a fresh live reading.
  List<VentilationEffect> onReading(
    String deviceId,
    VentilationReading reading,
    NotificationPreferences prefs, {
    bool deliveryAllowed = true,
  }) {
    final s = stateFor(deviceId);
    final effects = <VentilationEffect>[];

    if (!prefs.smartNotificationsEnabled) {
      effects.addAll(clear(deviceId, reading.at));
      return effects;
    }

    s.connected = true;
    final now = reading.at;
    final value = reading.value;

    // Missing data never counts towards persistence or recovery.
    final last = s.lastReading;
    if (last != null && now.difference(last.at) > staleGap) {
      s.resetWindows();
    }
    _expireIfStale(s, now, effects);
    s.lastReading = reading;

    // ---- update windows -------------------------------------------------
    final thresholds = _thresholds(prefs);
    for (final level in _levels) {
      final threshold = thresholds[level]!;
      if (value >= threshold) {
        final count = (s.consecutiveAbove[level] ?? 0) + 1;
        s.consecutiveAbove[level] = count;
        // Spike suppression: the window opens on the second consecutive
        // reading, anchored at the first one.
        if (count == 2 && s.aboveSince[level] == null) {
          s.aboveSince[level] = last?.at ?? now;
          s.windowStartValue[level] = last?.value ?? value;
        }
      } else {
        s.consecutiveAbove[level] = 0;
        s.aboveSince[level] = null;
        s.windowStartValue.remove(level);
        if (value < threshold - hysteresisPpm) {
          s.armed[level] = true;
        }
      }
    }
    if (value < thresholds[VentilationLevel.stuffy]!) {
      s.belowSince ??= now;
    } else {
      s.belowSince = null;
    }

    // ---- track the active event ----------------------------------------
    var event = s.activeEvent;
    if (event != null) {
      var updated = event.copyWith(lastValue: value, lastReadingAt: now);
      if (value > updated.peakValue) {
        updated = updated.copyWith(peakValue: value, peakAt: now);
      }
      event = updated;
      s.activeEvent = event;
    }

    // ---- escalation / first alert: highest persisted, armed, enabled level
    VentilationLevel? fire;
    for (final level in _levels.reversed) {
      if (!deliveryAllowed) break;
      if (!_enabled(level, prefs)) continue;
      if (s.armed[level] != true) continue;
      if (event != null && level.rank <= event.highestLevelNotified.rank) {
        continue; // never repeat the same or a lower level in one event
      }
      if (_persisted(s, level, now, prefs, value)) {
        fire = level;
        break;
      }
    }

    if (fire != null) {
      final windowStart = s.aboveSince[fire]!;
      final startValue = s.windowStartValue[fire] ?? value;
      event ??= VentilationEvent(
        id: VentilationEvent.makeId(deviceId, windowStart),
        deviceId: deviceId,
        deviceName: '',
        startedAt: windowStart,
        startValue: startValue,
        peakValue: value,
        peakAt: now,
        lastValue: value,
        lastReadingAt: now,
      );
      event = event.copyWith(
        highestLevelNotified: fire,
        reminderDueAt: () => null, // escalation cancels a pending reminder
        reminderLevel: VentilationLevel.none,
        notifications: [
          ...event.notifications,
          VentilationNotificationRecord(
            level: fire,
            kind: VentilationNotificationKind.alert,
            co2: value,
            sentAt: now,
          ),
        ],
      );
      for (final level in _levels) {
        if (level.rank <= fire.rank) s.armed[level] = false;
      }
      s.activeEvent = event;
      effects.add(NotifyLevel(fire, event, value));
      effects.add(PersistEvent(event));
      return effects;
    }

    if (event == null) return effects;

    // ---- pending reminder ---------------------------------------------
    if (_fireDueReminder(s, now, prefs, effects,
        currentValue: value, deliveryAllowed: deliveryAllowed)) {
      return effects;
    }

    // ---- recovery -----------------------------------------------------
    if (_recovered(s, event, now, prefs, value)) {
      final elapsedFrom = event.userActionAt ?? event.peakAt;
      final elapsed = now.difference(elapsedFrom);
      final notify = deliveryAllowed &&
          prefs.notifyImproved &&
          event.hasDeteriorationNotification;
      var ended = event.copyWith(
        status: VentilationEventStatus.recovered,
        endedAt: () => now,
        recoveredAt: () => now,
        recoveryValue: () => value,
        recoveryNotified: notify,
        reminderDueAt: () => null,
        reminderLevel: VentilationLevel.none,
      );
      if (notify) {
        ended = ended.copyWith(notifications: [
          ...ended.notifications,
          VentilationNotificationRecord(
            level: VentilationLevel.none,
            kind: VentilationNotificationKind.recovery,
            co2: value,
            sentAt: now,
          ),
        ]);
        effects.add(NotifyRecovery(ended, value, elapsed));
      }
      s.activeEvent = null;
      effects.add(PersistEvent(ended));
      return effects;
    }

    effects.add(PersistEvent(event));
    return effects;
  }

  // ------------------------------------------------------------------ rules

  Map<VentilationLevel, int> _thresholds(NotificationPreferences p) => {
        VentilationLevel.stuffy: p.stuffyThreshold,
        VentilationLevel.better: p.betterThreshold,
        VentilationLevel.poor: p.poorThreshold,
      };

  Duration _persistFor(VentilationLevel level, NotificationPreferences p) {
    switch (level) {
      case VentilationLevel.stuffy:
        return Duration(minutes: p.stuffyPersistMinutes);
      case VentilationLevel.better:
        return Duration(minutes: p.betterPersistMinutes);
      case VentilationLevel.poor:
        return Duration(minutes: p.poorPersistMinutes);
      case VentilationLevel.none:
        return Duration.zero;
    }
  }

  bool _enabled(VentilationLevel level, NotificationPreferences p) {
    switch (level) {
      case VentilationLevel.stuffy:
        return p.notifyStuffy;
      case VentilationLevel.better:
        return true; // intermediate state controlled by the master switch
      case VentilationLevel.poor:
        return p.notifyPoor;
      case VentilationLevel.none:
        return false;
    }
  }

  bool _persisted(
    VentilationEngineState s,
    VentilationLevel level,
    DateTime now,
    NotificationPreferences prefs,
    int value,
  ) {
    final since = s.aboveSince[level];
    if (since == null) return false;
    if (now.difference(since) < _persistFor(level, prefs)) return false;
    if (level == VentilationLevel.stuffy) {
      // Early prompt also requires "stable or rising".
      final start = s.windowStartValue[level] ?? value;
      if (value < start) return false;
    }
    return true;
  }

  bool _recovered(
    VentilationEngineState s,
    VentilationEvent event,
    DateTime now,
    NotificationPreferences prefs,
    int value,
  ) {
    if (!s.connected) return false;
    final since = s.belowSince;
    if (since == null) return false;
    final inLowestBand = now.difference(since);
    if (inLowestBand >= Duration(minutes: prefs.recoveryMinutes)) return true;
    final fell = event.peakValue - value >= fastRecoveryDropPpm;
    return fell && inLowestBand >= Duration(minutes: fastRecoveryMinutes);
  }

  bool _fireDueReminder(
    VentilationEngineState s,
    DateTime now,
    NotificationPreferences prefs,
    List<VentilationEffect> effects, {
    required int? currentValue,
    required bool deliveryAllowed,
  }) {
    final event = s.activeEvent;
    final due = event?.reminderDueAt;
    if (event == null || due == null || now.isBefore(due)) return false;
    if (!deliveryAllowed) return false; // stays due until quiet hours end
    final level = event.reminderLevel == VentilationLevel.none
        ? event.highestLevelNotified
        : event.reminderLevel;
    final value = currentValue ?? event.lastValue;
    // Do not remind from a stale reading.
    if (currentValue == null &&
        now.difference(event.lastReadingAt) > staleGap) {
      s.activeEvent = event.copyWith(
        reminderDueAt: () => null,
        reminderLevel: VentilationLevel.none,
      );
      effects.add(PersistEvent(s.activeEvent!));
      return false;
    }
    final updated = event.copyWith(
      reminderDueAt: () => null,
      reminderLevel: VentilationLevel.none,
      notifications: [
        ...event.notifications,
        VentilationNotificationRecord(
          level: level,
          kind: VentilationNotificationKind.reminder,
          co2: value,
          sentAt: now,
        ),
      ],
    );
    s.activeEvent = updated;
    effects.add(NotifyReminder(level, updated, value));
    effects.add(PersistEvent(updated));
    return true;
  }

  void _expireIfStale(
    VentilationEngineState s,
    DateTime now,
    List<VentilationEffect> effects,
  ) {
    final event = s.activeEvent;
    if (event == null) return;
    if (now.difference(event.lastReadingAt) < expireAfter) return;
    final expired = event.copyWith(
      status: VentilationEventStatus.expired,
      endedAt: () => now,
      reminderDueAt: () => null,
      reminderLevel: VentilationLevel.none,
    );
    s.activeEvent = null;
    s.resetWindows();
    effects.add(PersistEvent(expired));
  }
}
