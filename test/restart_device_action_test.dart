import 'dart:async';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/widgets/restart_device_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> show(WidgetTester tester, Future<bool> Function() send) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: RestartDeviceAction(sendRestart: send)),
    ));
  }

  test('restart sends the MCU reboot command, not factory reset', () {
    expect(DeviceCmdUtils.restartDevice(), [0xff, 0xaa, 0x27, 1, 1, 0xd2]);
  });

  testWidgets('cancel does not send; confirm sends once and reports a request',
      (tester) async {
    var calls = 0;
    final pending = Completer<bool>();
    await show(tester, () {
      calls++;
      return pending.future;
    });
    await tester.tap(find.text('Restart Device'));
    await tester.pumpAndSettle();
    expect(find.textContaining('settings, calibration and readings are kept'),
        findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(calls, 0);
    await tester.tap(find.text('Restart Device'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restart'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(calls, 1);
    await tester.tap(find.text('Requesting restart…'));
    expect(calls, 1);
    expect(find.byType(ListTile), findsNothing);
    pending.complete(true);
    await tester.pumpAndSettle();
    expect(find.textContaining('Restart requested.'), findsOneWidget);
    expect(calls, 1);
  });

  testWidgets('failed send explains connection or update instead of success',
      (tester) async {
    await show(tester, () async => false);
    await tester.tap(find.text('Restart Device'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not send the restart request.'),
        findsOneWidget);
    expect(find.textContaining('Restart requested.'), findsNothing);
  });

  testWidgets('timeout is bounded and never automatically retries',
      (tester) async {
    var calls = 0;
    final pending = Completer<bool>();
    await show(tester, () {
      calls++;
      return pending.future;
    });
    await tester.tap(find.text('Restart Device'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restart'));
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();
    expect(
        find.textContaining('Restart could not be confirmed.'), findsOneWidget);
    expect(calls, 1);
    pending.complete(false);
    await tester.pumpAndSettle();
  });
}
