import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/features/device_settings/pages/power_mode_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final enabled in [false, true]) {
    testWidgets('Slim shows three modes; commands enabled=$enabled',
        (tester) async {
      tester.view.physicalSize = const Size(320, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      PowerMode? chosen;
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: SlimMeasurementModeChoices(
              firmwareVersion: enabled ? '0.22.1' : '0.21.2',
              enabled: enabled,
              selectedMode: enabled ? PowerMode.high : null,
              onChanged: (mode) => chosen = mode,
            )),
      ))));
      expect(find.text('Single shot'), findsOneWidget);
      expect(find.text('Continuous'), findsOneWidget);
      expect(find.text('Single shot with sleep'), findsOneWidget);
      await tester.tap(find.text('Single shot with sleep'));
      expect(chosen, isNull);
      expect(find.text('Requires firmware 0.22.7 or later'), findsOneWidget);
      for (final old in ['Now', '1 min', '3 min', '5 sec']) {
        expect(find.text(old), findsNothing);
      }
      expect(find.text('Firmware update required'),
          enabled ? findsNothing : findsOneWidget);
      await tester.tap(find.text('Single shot'));
      expect(chosen, enabled ? PowerMode.low : null);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
      'Sleep mode is selectable on 0.22.7 at narrow width and large text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    PowerMode? chosen;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
                child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SlimMeasurementModeChoices(
                            firmwareVersion: '0.22.7',
                            enabled: true,
                            selectedMode: PowerMode.singleShotSleep,
                            onChanged: (mode) => chosen = mode)))))));
    await tester.ensureVisible(find.text('Single shot with sleep'));
    await tester.tap(find.text('Single shot with sleep'));
    expect(chosen, PowerMode.singleShotSleep);
    expect(find.text('Selected'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  test('Sleep mode has its own wire value without changing legacy modes', () {
    expect(PowerMode.fromValue(4), PowerMode.singleShotSleep);
    expect(
        DeviceSettings.empty(deviceId: 'slim')
            .copyWith(powerMode: PowerMode.singleShotSleep)
            .powerModeCmd,
        [255, 170, 5, 1, 4, 179]);
    expect(PowerMode.medium.index, 2);
    expect(PowerMode.high.index, 3);
  });
}
