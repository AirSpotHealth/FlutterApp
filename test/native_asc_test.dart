import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/models/native_asc_state.dart';
import 'package:airspothealth/features/device_settings/providers/native_asc_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/native_asc_setting_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> response(int mode,
    {bool verified = true, int error = 0, int? status}) {
  final bytes = [
    255,
    170,
    0x38,
    7,
    1,
    mode,
    verified ? 1 : 0,
    (error >> 8) & 255,
    error & 255,
    0,
    status ?? (mode == 2 ? 4 : 0x84)
  ];
  return [...bytes, bytes.fold<int>(0, (a, b) => a + b) & 255];
}

class ControlledNativeAsc extends NativeAscNotifier {
  ControlledNativeAsc(this.initial);
  final AsyncValue<NativeAscState> initial;
  @override
  AsyncValue<NativeAscState> build(String arg) => initial;
  @override
  Future<void> refresh() async {
    state = const AsyncLoading();
  }
}

void main() {
  test('commands distinguish native sensor learning from legacy software ASC',
      () {
    expect(DeviceCmdUtils.getNativeAsc(), [255, 170, 0x38, 0, 225]);
    expect(DeviceCmdUtils.setNativeAsc(true), [255, 170, 0x38, 1, 1, 227]);
    expect(DeviceCmdUtils.setNativeAsc(false), [255, 170, 0x38, 1, 0, 226]);
  });
  test('firmware capability and manual calibration fail closed', () {
    for (final version in ['0.17.7', '0.17.12', '-.-.-', 'garbage']) {
      expect(NativeAscState.supported(version), false);
    }
    expect(NativeAscState.supported('0.18.0'), true);
    expect(NativeAscState.canCalibrate('-.-.-', null), false);
    expect(NativeAscState.canCalibrate('garbage', null), false);
    expect(NativeAscState.canCalibrate('0.17.12', null), false);
    expect(NativeAscState.canCalibrate('0.18.0', null), false);
    expect(
        NativeAscState.canCalibrate(
            '0.21.2', NativeAscState.fromFrame(response(2))),
        false);
    expect(
        NativeAscState.canCalibrate(
            '0.22.0', NativeAscState.fromFrame(response(2))),
        true);
    expect(NativeAscState.canCalibrate('0.22.0', null), false);
    expect(
        NativeAscState.canCalibrate(
            '0.22.0', NativeAscState.fromFrame(response(2, error: -5))),
        false);
    expect(NativeAscState.canCalibrate('0.17.7', null), true);
    expect(NativeAscState.fromFrame(response(2)).manualAllowed, false);
    expect(NativeAscState.fromFrame(response(1)).manualAllowed, true);
    expect(NativeAscState.fromFrame(response(0)).manualAllowed, true);
    expect(
        NativeAscState.fromFrame(response(1, error: -5)).manualAllowed, false);
    expect(NativeAscState.fromFrame(response(1, status: 4)).verified, false);
    expect(NativeAscState.fromFrame(response(2, status: 0x84)).verified, false);
  });
  test(
      'malformed, truncated and corrupt acknowledgements cannot confirm a setting',
      () {
    final badChecksum = response(2)..[11] ^= 1;
    for (final frame in [
      badChecksum,
      response(2).take(10).toList(),
      response(3)
    ]) {
      expect(() => NativeAscState.fromFrame(frame), throwsFormatException);
    }
    expect(NativeAscState.fromFrame(response(1, error: -16)).error, -16);
  });
  testWidgets('native FRC remains available with ASC on in 0.22',
      (tester) async {
    final notifier =
        ControlledNativeAsc(AsyncData(NativeAscState.fromFrame(response(2))));
    await tester.pumpWidget(ProviderScope(
        overrides: [nativeAscProvider.overrideWith(() => notifier)],
        child: const MaterialApp(
            home: Scaffold(
                body: SingleChildScrollView(
                    child: NativeAscSettingWidget(
                        deviceId: 'test',
                        firmwareVersion: '0.22.0',
                        manualControls: Text('Native FRC controls')))))));
    expect(find.text('Native FRC controls'), findsOneWidget);
    expect(find.textContaining('at least once a week'), findsOneWidget);
    expect(
        find.textContaining('Manual calibration is unavailable'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  for (final mode in [0, 1, 2]) {
    testWidgets('read-only auto-calibration status for mode $mode',
        (tester) async {
      final notifier = ControlledNativeAsc(
          AsyncData(NativeAscState.fromFrame(response(mode))));
      await tester.pumpWidget(ProviderScope(
          overrides: [nativeAscProvider.overrideWith(() => notifier)],
          child: const MaterialApp(
              home: Scaffold(
                  body: SingleChildScrollView(
                      child: NativeAscSettingWidget(
                          deviceId: 'test',
                          firmwareVersion: '0.22.4',
                          manualControls:
                              Text('Forced recalibration controls')))))));
      expect(find.byType(SwitchListTile), findsNothing);
      expect(find.byType(Switch), findsNothing);
      expect(find.text('Forced recalibration controls'),
          mode == 2 ? findsOneWidget : findsNothing);
      expect(find.textContaining('Sensirion'), findsNothing);
      notifier.receive(response(mode, error: -5));
      await tester.pump();
      expect(find.text('Forced recalibration controls'), findsNothing);
      expect(find.text('Retry'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('unknown state does not claim enabled or expose controls',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
        overrides: [
          nativeAscProvider
              .overrideWith(() => ControlledNativeAsc(const AsyncLoading()))
        ],
        child: const MaterialApp(
            home: Scaffold(
                body: NativeAscSettingWidget(
                    deviceId: 'test',
                    firmwareVersion: '0.22.4',
                    manualControls: Text('Forced recalibration controls'))))));
    expect(find.text('Forced recalibration controls'), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
    expect(find.textContaining('Checking auto-calibration'), findsOneWidget);
  });
}
