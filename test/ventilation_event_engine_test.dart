import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:airspothealth/core/services/ventilation_event_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drives the engine with a fixed reading cadence and a fake clock.
class Sim {
  Sim({NotificationPreferences? prefs, Duration? cadence})
      : prefs = prefs ??
            NotificationPreferences(
                deviceId: 'dev', smartNotificationsEnabled: true),
        cadence = cadence ?? const Duration(seconds: 30);

  final engine = VentilationEventEngine();
  final NotificationPreferences prefs;
  final Duration cadence;
  DateTime now = DateTime(2026, 9, 12, 10, 0);
  final effects = <VentilationEffect>[];

  /// Feed [value] every [cadence] for [duration] (inclusive of the first
  /// sample, exclusive of a sample at exactly duration end).
  void feed(int value, Duration duration) {
    final samples = duration.inSeconds ~/ cadence.inSeconds;
    for (var i = 0; i < samples; i++) {
      one(value);
    }
  }

  void one(int value, {Duration? gap}) {
    now = now.add(gap ?? cadence);
    effects.addAll(engine.onReading(
        'dev', VentilationReading(value, now), prefs));
  }

  void tick([Duration? gap]) {
    now = now.add(gap ?? cadence);
    effects.addAll(engine.onTick('dev', now, prefs));
  }

  List<NotifyLevel> get alerts => effects.whereType<NotifyLevel>().toList();
  List<NotifyReminder> get reminders =>
      effects.whereType<NotifyReminder>().toList();
  List<NotifyRecovery> get recoveries =>
      effects.whereType<NotifyRecovery>().toList();
  void drain() => effects.clear();
}

void main() {
  group('persistence', () {
    test('no alert before the early prompt persists for 5 minutes', () {
      final sim = Sim();
      sim.feed(850, const Duration(minutes: 4));
      expect(sim.alerts, isEmpty);
    });

    test('early prompt fires once 800 ppm persists for 5 minutes', () {
      final sim = Sim();
      sim.feed(850, const Duration(minutes: 6));
      expect(sim.alerts.map((a) => a.level), [VentilationLevel.stuffy]);
      expect(sim.alerts.single.event.highestLevelNotified,
          VentilationLevel.stuffy);
    });

    test('a 4-minute excursion that drops below threshold never alerts', () {
      final sim = Sim();
      sim.feed(900, const Duration(minutes: 4));
      sim.feed(700, const Duration(minutes: 2));
      sim.feed(900, const Duration(minutes: 4));
      expect(sim.alerts, isEmpty);
    });

    test('a lone breath spike is ignored', () {
      final sim = Sim();
      sim.feed(600, const Duration(minutes: 2));
      sim.one(1800);
      sim.feed(600, const Duration(minutes: 12));
      expect(sim.alerts, isEmpty);
      expect(sim.engine.activeEvent('dev'), isNull);
    });

    test('falling CO2 does not trigger the early prompt', () {
      final sim = Sim();
      // Above 800 but falling steadily for 6 minutes.
      var v = 990;
      for (var i = 0; i < 12; i++) {
        sim.one(v);
        v -= 10;
      }
      expect(sim.alerts, isEmpty);
    });

    test('a stale gap resets persistence windows', () {
      final sim = Sim();
      sim.feed(900, const Duration(minutes: 3));
      sim.one(900, gap: const Duration(minutes: 10));
      sim.feed(900, const Duration(minutes: 3));
      expect(sim.alerts, isEmpty, reason: 'gap must not count as persistence');
      sim.feed(900, const Duration(minutes: 3));
      expect(sim.alerts.length, 1);
    });
  });

  group('one event, escalation and hysteresis', () {
    test('same level is not repeated while it stays high', () {
      final sim = Sim();
      sim.feed(900, const Duration(minutes: 30));
      expect(sim.alerts.length, 1);
    });

    test('escalates through 1,000 and 1,500 without repeating', () {
      final sim = Sim();
      sim.feed(900, const Duration(minutes: 6));
      sim.feed(1100, const Duration(minutes: 11));
      sim.feed(1600, const Duration(minutes: 11));
      expect(sim.alerts.map((a) => a.level), [
        VentilationLevel.stuffy,
        VentilationLevel.better,
        VentilationLevel.poor,
      ]);
      final ids = sim.alerts.map((a) => a.event.id).toSet();
      expect(ids.length, 1, reason: 'all alerts belong to one event');
      expect(sim.alerts.last.event.peakValue, 1600);
    });

    test('a higher level fires while a reminder is pending and cancels it', () {
      final sim = Sim(
          prefs: NotificationPreferences(
              deviceId: 'dev',
              smartNotificationsEnabled: true,
              reminderMinutes: 15));
      sim.feed(900, const Duration(minutes: 6));
      sim.drain();
      sim.engine.requestReminder(
          'dev', VentilationLevel.stuffy, sim.now, sim.prefs);
      sim.feed(1100, const Duration(minutes: 11));
      expect(sim.alerts.map((a) => a.level), [VentilationLevel.better]);
      expect(sim.reminders, isEmpty);
      expect(sim.engine.activeEvent('dev')!.reminderDueAt, isNull);
    });

    test('a level re-arms only after dropping 100 ppm below its threshold',
        () {
      final sim = Sim();
      sim.feed(1100, const Duration(minutes: 11));
      expect(sim.alerts.map((a) => a.level),
          containsAll([VentilationLevel.stuffy, VentilationLevel.better]));
      sim.drain();
      // Dip to 950 (below 1,000 but not below 900) then back up: no repeat.
      sim.feed(950, const Duration(minutes: 1));
      sim.feed(1100, const Duration(minutes: 11));
      expect(sim.alerts, isEmpty);
      // Dip to 850 (< 900) then back: still no repeat within the same event,
      // because a level never repeats inside one event without a reminder.
      sim.feed(850, const Duration(minutes: 1));
      sim.feed(1100, const Duration(minutes: 11));
      expect(sim.alerts, isEmpty);
    });

    test('poor level can be disabled while better still fires', () {
      final sim = Sim(
          prefs: NotificationPreferences(
              deviceId: 'dev',
              smartNotificationsEnabled: true,
              notifyStuffy: false,
              notifyPoor: false));
      sim.feed(1600, const Duration(minutes: 11));
      expect(sim.alerts.map((a) => a.level), [VentilationLevel.better]);
    });

    test('master switch off keeps the engine idle', () {
      final sim = Sim(prefs: NotificationPreferences(deviceId: 'dev'));
      sim.feed(1600, const Duration(minutes: 20));
      expect(sim.alerts, isEmpty);
      expect(sim.engine.activeEvent('dev'), isNull);
    });
  });

  group('reminders', () {
    test('reminder fires after the interval with the current reading', () {
      final sim = Sim();
      sim.feed(900, const Duration(minutes: 6));
      sim.drain();
      sim.engine.requestReminder(
          'dev', VentilationLevel.stuffy, sim.now, sim.prefs);
      sim.feed(920, const Duration(minutes: 9));
      expect(sim.reminders, isEmpty);
      sim.feed(940, const Duration(minutes: 2));
      expect(sim.reminders.length, 1);
      expect(sim.reminders.single.currentValue, 940);
      expect(sim.reminders.single.level, VentilationLevel.stuffy);
      // One reminder per request.
      sim.feed(940, const Duration(minutes: 20));
      expect(sim.reminders.length, 1);
    });

    test('high-priority reminder uses the 5 minute interval', () {
      final sim = Sim();
      sim.feed(1600, const Duration(minutes: 11));
      sim.drain();
      sim.engine.requestReminder(
          'dev', VentilationLevel.poor, sim.now, sim.prefs);
      sim.feed(1600, const Duration(minutes: 4));
      expect(sim.reminders, isEmpty);
      sim.feed(1600, const Duration(minutes: 2));
      expect(sim.reminders.length, 1);
    });

    test('reminder is skipped once the event has recovered', () {
      final sim = Sim();
      sim.feed(900, const Duration(minutes: 6));
      sim.drain();
      sim.engine.requestReminder(
          'dev', VentilationLevel.stuffy, sim.now, sim.prefs);
      sim.feed(600, const Duration(minutes: 6));
      expect(sim.recoveries.length, 1);
      sim.feed(600, const Duration(minutes: 10));
      sim.tick(const Duration(minutes: 5));
      expect(sim.reminders, isEmpty);
    });

    test('reminders are ignored when the toggle is off', () {
      final sim = Sim(
          prefs: NotificationPreferences(
              deviceId: 'dev',
              smartNotificationsEnabled: true,
              remindersEnabled: false));
      sim.feed(900, const Duration(minutes: 6));
      sim.drain();
      sim.engine.requestReminder(
          'dev', VentilationLevel.stuffy, sim.now, sim.prefs);
      sim.feed(900, const Duration(minutes: 15));
      expect(sim.reminders, isEmpty);
    });

    test('a timer tick fires a due reminder using the last fresh reading', () {
      final sim = Sim();
      sim.feed(900, const Duration(minutes: 6));
      sim.drain();
      sim.engine.requestReminder(
          'dev', VentilationLevel.stuffy, sim.now, sim.prefs);
      sim.feed(910, const Duration(minutes: 9, seconds: 30));
      sim.tick(const Duration(minutes: 1));
      expect(sim.reminders.length, 1);
      expect(sim.reminders.single.currentValue, 910);
    });
  });

  group('recovery', () {
    test('recovers after 5 minutes below 800 and reports peak and elapsed',
        () {
      final sim = Sim();
      sim.feed(900, const Duration(minutes: 6));
      sim.one(1420);
      final peakAt = sim.now; // first sample at the peak value
      sim.one(1420);
      sim.drain();
      sim.feed(760, const Duration(minutes: 6));
      expect(sim.recoveries.length, 1);
      final r = sim.recoveries.single;
      expect(r.event.peakValue, 1420);
      expect(r.event.peakAt, peakAt);
      expect(r.currentValue, 760);
      expect(r.elapsed, r.event.recoveredAt!.difference(peakAt));
      expect(r.elapsed, greaterThanOrEqualTo(const Duration(minutes: 2)));
      expect(r.event.status, VentilationEventStatus.recovered);
      expect(sim.engine.activeEvent('dev'), isNull);
    });

    test('fast recovery after a 300 ppm drop into the lowest band', () {
      final sim = Sim();
      sim.feed(1100, const Duration(minutes: 11));
      sim.drain();
      sim.feed(700, const Duration(minutes: 2, seconds: 30));
      expect(sim.recoveries.length, 1);
    });

    test('a small drop into the lowest band still needs 5 minutes', () {
      final sim = Sim();
      sim.feed(850, const Duration(minutes: 6));
      sim.drain();
      sim.feed(780, const Duration(minutes: 3));
      expect(sim.recoveries, isEmpty);
      sim.feed(780, const Duration(minutes: 3));
      expect(sim.recoveries.length, 1);
    });

    test('elapsed counts from the recorded user action when present', () {
      final sim = Sim();
      sim.feed(900, const Duration(minutes: 6));
      sim.feed(1000, const Duration(minutes: 1));
      sim.engine.recordUserAction(
          'dev', VentilationUserAction.openedWindowOrDoor, sim.now);
      final actionAt = sim.now;
      sim.drain();
      sim.feed(600, const Duration(minutes: 6));
      final r = sim.recoveries.single;
      expect(r.elapsed, r.event.recoveredAt!.difference(actionAt));
      expect(
          r.event.userAction, VentilationUserAction.openedWindowOrDoor);
    });

    test('no recovery without a deterioration notification', () {
      final sim = Sim(
          prefs: NotificationPreferences(
              deviceId: 'dev',
              smartNotificationsEnabled: true,
              notifyImproved: false));
      sim.feed(900, const Duration(minutes: 6));
      sim.drain();
      sim.feed(600, const Duration(minutes: 6));
      expect(sim.recoveries, isEmpty);
      expect(sim.engine.activeEvent('dev'), isNull,
          reason: 'event still ends silently');
    });

    test('recovery is never inferred across a disconnect', () {
      final sim = Sim();
      sim.feed(850, const Duration(minutes: 6));
      sim.drain();
      sim.feed(600, const Duration(minutes: 3));
      sim.engine.onDisconnected('dev');
      sim.engine.onConnected('dev');
      sim.feed(600, const Duration(minutes: 3));
      expect(sim.recoveries, isEmpty,
          reason: 'the below-threshold window restarted on reconnect');
      sim.feed(600, const Duration(minutes: 3));
      expect(sim.recoveries.length, 1);
    });

    test('recovery is never inferred across a stale gap', () {
      final sim = Sim();
      sim.feed(850, const Duration(minutes: 6));
      sim.drain();
      sim.feed(600, const Duration(minutes: 3));
      sim.one(600, gap: const Duration(minutes: 10));
      sim.feed(600, const Duration(minutes: 3));
      expect(sim.recoveries, isEmpty);
    });

    test('after recovery a new episode creates a new event', () {
      final sim = Sim();
      sim.feed(900, const Duration(minutes: 6));
      sim.feed(600, const Duration(minutes: 6));
      sim.drain();
      sim.feed(900, const Duration(minutes: 6));
      expect(sim.alerts.length, 1);
      expect(sim.alerts.single.event.notifications.length, 1);
    });
  });

  group('expiry', () {
    test('an active event closes silently after 30 minutes of silence', () {
      final sim = Sim();
      sim.feed(900, const Duration(minutes: 6));
      sim.drain();
      sim.tick(const Duration(minutes: 31));
      expect(sim.recoveries, isEmpty);
      expect(sim.engine.activeEvent('dev'), isNull);
      final persisted = sim.effects.whereType<PersistEvent>().last.event;
      expect(persisted.status, VentilationEventStatus.expired);
    });
  });
}
