import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airspothealth/features/device_settings/models/initial_settling_state.dart';
import 'package:airspothealth/features/device_settings/widgets/initial_settling_notice.dart';

List<int> frame(int active, int remaining) {
  final bytes = [
    255,
    170,
    62,
    6,
    1,
    active,
    0,
    0,
    remaining >> 8,
    remaining & 255
  ];
  return [...bytes, bytes.fold<int>(0, (a, b) => a + b) & 255];
}

void main() {
  test('reads firmware progress and completion, rejects corrupt status', () {
    final value = InitialSettlingState.fromFrame(frame(1, 3540));
    expect(value.active, isTrue);
    expect(value.remainingSeconds, 3540);
    expect(InitialSettlingState.fromFrame(frame(0, 0)).active, isFalse);
    expect(() => InitialSettlingState.fromFrame(frame(1, 0)),
        throwsFormatException);
    expect(() => InitialSettlingState.fromFrame(frame(1, 3601)),
        throwsFormatException);
    final bad = frame(1, 60)..[10] = 0;
    expect(() => InitialSettlingState.fromFrame(bad), throwsFormatException);
    expect(InitialSettlingState.supported('0.22.3'), isFalse);
    expect(InitialSettlingState.supported('0.22.4'), isTrue);
    expect(InitialSettlingState.supported('0.23.0'), isTrue);
    expect(
        InitialSettlingState.request.last,
        InitialSettlingState.request.take(4).fold<int>(0, (a, b) => a + b) &
            255);
  });
  testWidgets('settling notice fits narrow cards with large text',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2)),
      child: const SingleChildScrollView(
          child: SizedBox(
              width: 280,
              child: InitialSettlingBanner(remainingSeconds: 3540))),
    ))));
    expect(find.text('Sensor settling'), findsOneWidget);
    expect(find.textContaining('59 min'), findsOneWidget);
    expect(find.textContaining('white blink'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
