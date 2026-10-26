import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/models/sensor_error_state.dart';
import 'package:airspothealth/core/theme/app_theme.dart';
import 'package:airspothealth/features/device_settings/providers/sensor_error_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/sensor_error_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class StartupState extends SensorErrorNotifier {
  @override
  SensorErrorState? build(String arg) => SensorErrorState(
      errorCode: 0x40,
      isSlim: true,
      recoveryAttempts: 0,
      timestamp: DateTime.now(),
      deviceId: arg);
  void ready() => state = null;
}

void main() {
  test('unavailable readings are neutral, not green', () {
    final settings = DeviceSettings(deviceId: 'test');
    expect(settings.getValueColor(null), AppColors.textSecondary);
    expect(settings.getValueColor(390), AppColors.brandColorGreen);
  });
  test('only Slim startup is preparation; real faults remain errors', () {
    for (final slim in [true, false]) {
      for (final code in [0x40, 0x41, 0x44]) {
        final state = SensorErrorState(
            errorCode: code,
            isSlim: slim,
            recoveryAttempts: 0,
            timestamp: DateTime.now(),
            deviceId: 'test');
        expect(state.isPreparing, slim && code == 0x40);
        expect(state.isInError, !(slim && code == 0x40));
      }
    }
  });
  testWidgets(
      'preparation is neutral, accessible, and clears when a valid reading arrives',
      (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final notifier = StartupState();
    await tester.pumpWidget(ProviderScope(
        overrides: [sensorErrorProvider.overrideWith(() => notifier)],
        child: MaterialApp(
            theme: AppTheme.theme,
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(2)),
                child: child!),
            home: const Scaffold(
                body: SingleChildScrollView(
                    child: SensorErrorBanner(deviceId: 'test'))))));
    expect(find.text('Preparing sensor…'), findsOneWidget);
    expect(find.text('Sensor Issue Detected'), findsNothing);
    expect(find.text('Report Issue'), findsNothing);
    expect(tester.takeException(), null);
    notifier.ready();
    await tester.pump();
    expect(find.text('Preparing sensor…'), findsNothing);
  });
}
