import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airspothealth/features/device_settings/models/slim_settling_state.dart';
import 'package:airspothealth/features/device_settings/widgets/slim_settling_card.dart';
import 'package:airspothealth/features/device_settings/service/slim_preferences_reset.dart';
import 'slim_test_helpers.dart' show frame;

void main() {
  List<int> status({int stage = 1, int seconds = 120, int error = 0}) {
    final d = ByteData(22);
    d.setUint8(0, 1);
    d.setUint8(1, stage);
    d.setUint8(2, 1);
    d.setInt16(4, error);
    d.setUint32(6, 7);
    d.setUint32(14, seconds);
    return frame(0x3c, d.buffer.asUint8List());
  }

  test('firmware capability and strict status validation', () {
    expect(SlimSettlingState.supported('0.18.9'), false);
    expect(SlimSettlingState.nativeTestModesSupported('0.21.2'), false);
    expect(SlimSettlingState.nativeTestModesSupported('0.22.0'), true);
    expect(SlimSettlingState.nativeTestModesSupported('unknown'), false);
    expect(SlimSettlingState.supported('0.19.0'), true);
    expect(SlimSettlingState.supported('unknown'), false);
    expect(SlimSettlingState.continuousRecoverySupported('0.20.2'), false);
    expect(SlimSettlingState.continuousRecoverySupported('0.21.0'), true);
    expect(SlimSettlingState.continuousRecoverySupported('unknown'), false);
    expect(SlimSettlingState.request(action: 3, generation: 7),
        frame(0x3c, [3, 0, 0, 0, 7]));
    final s = SlimSettlingState.fromFrame(status());
    expect(s.seconds, 120);
    expect(s.generation, 7);
    expect(s.running, true);
    expect(() => SlimSettlingState.fromFrame(status()..last ^= 1),
        throwsFormatException);
    expect(() => SlimSettlingState.fromFrame(status(stage: 6)),
        throwsFormatException);
    expect(() => SlimSettlingState.fromFrame(status(seconds: 43201)),
        throwsFormatException);
    expect(
        () => SlimSettlingState.fromFrame(status(error: -5)), throwsStateError);
    expect(SlimSettlingState.request(action: 1, generation: 7),
        frame(0x3c, [1, 0, 0, 0, 7]));
  });
  test(
      'preferences reset uses separate command and requires its valid acknowledgement',
      () async {
    expect(SlimPreferencesReset.command, frame(0x3d, []));
    final stream = StreamController<List<int>>.broadcast(sync: true);
    final result = SlimPreferencesReset.run(
        responses: stream.stream,
        send: () async {
          stream.add(frame(
              0xfa, [1])); // destructive reset ACK cannot authorize completion
          stream.add(frame(0x3d, [0, 0])..last ^= 1);
          stream.add(frame(0x3d, [0, 0]));
          return true;
        });
    await result;
    expect(stream.hasListener, false);
    await stream.close();
  });
  test(
      'preferences failure preserves caller state and times out without confirmation',
      () async {
    final stream = StreamController<List<int>>.broadcast(sync: true);
    await expectLater(
        SlimPreferencesReset.run(
            responses: stream.stream,
            send: () async {
              stream.add(frame(0x3d, [255, 251]));
              return true;
            }),
        throwsStateError);
    await expectLater(
        SlimPreferencesReset.run(
            responses: stream.stream,
            timeout: const Duration(milliseconds: 10),
            send: () async => true),
        throwsA(isA<TimeoutException>()));
    await stream.close();
  });
  testWidgets(
      'fresh air action, paused state, acknowledgement and narrow layout',
      (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    int? action;
    Future<void> show(int stage, bool running, int fresh) =>
        tester.pumpWidget(MaterialApp(
            home: Scaffold(
                body: SingleChildScrollView(
                    child: SettlingGuidance(
                        s: SlimSettlingState(
                            stage, running, 7, 0, 43200, fresh),
                        onAction: (a) => action = a)))));
    await show(2, false, 0);
    expect(find.text('Fresh air needed'), findsOneWidget);
    await tester.tap(find.text('Start fresh-air step'));
    expect(action, 1);
    action = null;
    await show(3, true, 599);
    await tester.tap(find.text('I completed the fresh-air exposure'));
    expect(action, null);
    await show(3, true, 600);
    await tester.tap(find.text('I completed the fresh-air exposure'));
    expect(action, 2);
    await show(1, false, 0);
    expect(find.text('Settling paused'), findsOneWidget);
    await show(4, false, 600);
    expect(find.text('Recovery guidance completed'), findsOneWidget);
    expect(find.textContaining('does not certify accuracy'), findsOneWidget);
    expect(tester.takeException(), null);
    bool opened = false;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SettlingGuidance(
      s: const SlimSettlingState(2, false, 7, 0, 43200, 0),
      onAction: (_) {},
      onOpenDetails: () => opened = true,
    ))));
    expect(find.text('Fresh air needed'), findsOneWidget);
    await tester.tap(find.text('Fresh air needed'));
    expect(opened, true);
    expect(tester.takeException(), null);
  });
  testWidgets(
      'recovery start requires confirmation and is hidden on older firmware',
      (tester) async {
    int? action;
    Future<void> show(bool enabled) => tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SettlingGuidance(
                s: const SlimSettlingState(0, false, 0, 0, 0, 0),
                canStartRecovery: enabled,
                onAction: (a) => action = a))));
    await show(false);
    expect(find.text('Start 12-hour check'), findsNothing);
    await show(true);
    await tester.tap(find.text('Start 12-hour check'));
    await tester.pumpAndSettle();
    expect(action, null);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(action, null);
    await tester.tap(find.text('Start 12-hour check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start check'));
    await tester.pumpAndSettle();
    expect(action, 3);
    expect(tester.takeException(), null);
  });
}
