# Smart notifications (ventilation events)

Decision record for the notification-actions redesign (handoff pack from Rob,
September 2026). Applies to the Flutter app only; both AirSpot Screen and
AirSpot Slim feed the same engine because their CO₂ readings arrive through the
same BLE path (`_BleDeviceCommunicationNotifier.setHomeValue`).

## Where things live

| Concern | File |
|---|---|
| Exact copy, colours, icons, action ids | `lib/core/models/ventilation_level.dart` |
| Per-device preferences (Isar) | `lib/core/models/notification_preferences.dart` |
| Event record / history / durable engine state (Isar) | `lib/core/models/ventilation_event.dart` |
| Pure rules engine (no IO) | `lib/core/services/ventilation_event_engine.dart` |
| Delivery, storage, timers, action routing | `lib/core/services/ventilation_notification_coordinator.dart` |
| Notification tap / action buttons, background queue | `lib/core/services/ventilation_action_handler.dart` |
| System notification with actions | `NotificationService.showVentilationNotification` |
| In-app foreground alert | `lib/core/widgets/ventilation_alert_card.dart` |
| Settings, advanced, history, detail pages | `lib/features/notification_settings/` |
| Tests | `test/ventilation_event_engine_test.dart`, `test/ventilation_copy_test.dart` |

## Rules as implemented

- Persistence: a level fires only when every reading since the window opened
  was at or above its threshold for the configured minutes (5 / 10 / 10).
  The window opens on the second consecutive reading above threshold, so a
  single breath spike never starts one. The early prompt also requires the
  reading to be stable or rising versus the window start.
- One event per episode. A level notifies once per event; a higher level
  notifies immediately, even while a reminder is pending, and cancels it.
- Hysteresis: a level re-arms only after a reading 100 ppm below its threshold.
- Reminder: only when the user asks. Fires once, with the reading current at
  that time, and is skipped if the event recovered.
- Recovery: 5 minutes below the stuffy threshold, or a fall of at least
  300 ppm from the peak plus 2 minutes in the lowest band. Sent only if a
  deterioration notification was sent. Elapsed time counts from the recorded
  user action when there is one, otherwise from the peak.
- Missing data: a gap over 7 minutes between readings, or a disconnect, resets
  every window. An active event with no reading for 30 minutes closes as
  expired with no notification.
- Quiet hours: the engine keeps tracking but emits nothing; a level that is
  still persisted when quiet hours end notifies on the next evaluation.
- Master switch off clears engine state and any visible alert.

The "Now" reading rate only sends a value on request, so persistence cannot be
evaluated. The settings page shows a hint to pick 1 min or faster.

## Answers to the handoff questions

1. Consistent on iOS and Android: all four states, exact copy, two action
   buttons per notification, reminder / taken-action / guidance / view-result
   flows, recovery, history with action and outcome, in-app coloured alert.
2. The persistence, hysteresis, escalation, reminder and recovery logic runs
   entirely in the app on the live BLE stream; no firmware change. The engine
   is pure Dart with a fake-clock test suite covering each rule.
3. History is stored locally in Isar per device (`VentilationEvent`). Cloud
   sync is not part of the MVP.
4. Platform limits:
   - Colour: iOS system notifications cannot carry a background colour or a
     tinted icon, so iOS relies on the written state; Android shows a
     state-coloured large icon and accent. Full colour blocks are used for the
     in-app alert card, live reading chip, settings and history.
   - Buttons: iOS shows actions when the notification is expanded. iOS action
     labels are registered once at launch, so "Remind me in N min" shows the
     default interval (10 / 5) even if the interval is customised; Android
     labels follow the setting.
   - Foreground: while the app is open and "Show while using AirSpot" is on,
     alerts appear as the in-app card instead of a system banner. Dark red
     pulses once on entry and honours reduced-motion.
   - Vibration: custom patterns on Android only; iOS uses the system haptic.
     Remind / Done from a notification are handled on a background isolate and
     queued, then applied by the app on its next reading, timer tick or resume.
5. MVP vs later: shipped now — everything above. Later — coloured notification
   image on iOS, cloud-synced history, per-level custom messages (removed on
   purpose: copy is fixed by the spec).
