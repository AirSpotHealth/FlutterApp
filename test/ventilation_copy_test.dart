import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String body(VentilationLevel level, int value) => VentilationCopy.body(
        level: level,
        currentValue: value,
        betterThreshold: 1000,
        betterPersistMinutes: 10,
        poorThreshold: 1500,
      );

  test('titles and bodies match the specification exactly', () {
    expect(VentilationLevel.stuffy.title, 'Air is getting stuffy');
    expect(body(VentilationLevel.stuffy, 840),
        'CO₂ 840 ppm and rising — let in outdoor air if practical.');
    expect(VentilationLevel.better.title, 'Ventilation could be better');
    expect(body(VentilationLevel.better, 1200),
        'CO₂ above 1,000 ppm for 10 min — improve ventilation.');
    expect(VentilationLevel.poor.title, 'Poor ventilation detected');
    expect(body(VentilationLevel.poor, 1600),
        'CO₂ above 1,500 ppm — improve ventilation or move.');
    expect(VentilationCopy.recoveryTitle, 'The air has improved');
    expect(
        VentilationCopy.recoveryBody(
            peakValue: 1420,
            currentValue: 760,
            elapsed: const Duration(minutes: 12)),
        'CO₂ fell from 1,420 to 760 ppm in 12 min.');
  });

  test('elapsed time formatting', () {
    expect(VentilationCopy.elapsed(const Duration(seconds: 20)), 'under 1 min');
    expect(VentilationCopy.elapsed(const Duration(minutes: 12)), '12 min');
    expect(VentilationCopy.elapsed(const Duration(minutes: 60)), '1 h');
    expect(VentilationCopy.elapsed(const Duration(minutes: 65)), '1 h 5 min');
  });

  test('no shorthand symbols in user-facing wording', () {
    final texts = [
      for (final l in [
        VentilationLevel.stuffy,
        VentilationLevel.better,
        VentilationLevel.poor
      ]) ...[l.title, body(l, 1234), l.stateLabel],
      VentilationCopy.recoveryTitle,
      VentilationCopy.recoveryBody(
          peakValue: 2000, currentValue: 500, elapsed: const Duration(hours: 2)),
      ...VentilationCopy.guidanceItems,
      VentilationCopy.guidanceNote,
      VentilationActionIds.takenActionLabel,
      VentilationActionIds.whatCanIDoLabel,
      VentilationActionIds.remindLabel(10),
      for (final a in VentilationUserActionX.choices) a.label,
    ];
    for (final t in texts) {
      expect(t, isNot(contains('>')), reason: t);
      expect(t, isNot(contains('<')), reason: t);
      expect(t, isNot(contains('&')), reason: t);
      expect(t, isNot(contains('→')), reason: t);
      expect(t, isNot(contains('minutes')), reason: t);
    }
    expect(VentilationActionIds.remindLabel(5), 'Remind me in 5 min');
  });

  test('quiet hours window, including overnight', () {
    DateTime t(int h, [int m = 0]) => DateTime(2026, 1, 1, h, m);
    final overnight = NotificationPreferences(
      deviceId: 'd',
      quietHoursEnabled: true,
      quietHoursStart: t(22),
      quietHoursEnd: t(6),
    );
    expect(overnight.isInQuietHours(t(23)), isTrue);
    expect(overnight.isInQuietHours(t(2)), isTrue);
    expect(overnight.isInQuietHours(t(6)), isFalse);
    expect(overnight.isInQuietHours(t(12)), isFalse);

    final daytime = overnight.copyWith(
        quietHoursStart: () => t(9), quietHoursEnd: () => t(17));
    expect(daytime.isInQuietHours(t(9)), isTrue);
    expect(daytime.isInQuietHours(t(16, 59)), isTrue);
    expect(daytime.isInQuietHours(t(17)), isFalse);
    expect(daytime.isInQuietHours(t(3)), isFalse);

    expect(overnight.copyWith(quietHoursEnabled: false).isInQuietHours(t(23)),
        isFalse);
  });
}
