import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/features/device_settings/pages/power_mode_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final enabled in [false, true]) {
    testWidgets('Slim shows two modes; commands enabled=$enabled',
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
}
