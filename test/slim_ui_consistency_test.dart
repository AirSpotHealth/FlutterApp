import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:airspothealth/core/theme/app_theme.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/find_my_device/widgets/slim_locate_panel.dart';
import 'package:airspothealth/features/device_settings/widgets/slim_settling_card.dart';
import 'package:airspothealth/features/device_settings/models/slim_settling_state.dart';
import 'package:airspothealth/features/device_settings/models/native_asc_state.dart';
import 'package:airspothealth/features/device_settings/providers/native_asc_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/native_asc_setting_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class RetryAsc extends NativeAscNotifier {
  int retries = 0;
  @override
  AsyncValue<NativeAscState> build(String arg) =>
      AsyncError('Could not reach the device. Tap Retry.', StackTrace.current);
  @override
  Future<void> refresh() async {
    retries++;
    state = const AsyncLoading();
  }
}

void main() {
  final boundary = GlobalKey();
  Future<void> show(WidgetTester tester, Widget child,
      {double width = 390, double scale = 1}) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.theme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: RepaintBoundary(
          key: boundary,
          child: Scaffold(
            appBar: AppBar(
                title: const Text('AirSpot Slim',
                    style: TextStyle(fontFamily: 'Roboto'))),
            body: child,
          )),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> preview(WidgetTester tester, String name) async {
    final directory = Platform.environment['SLIM_UI_PREVIEW_DIR'];
    if (directory == null) return;
    await tester.runAsync(() async {
      final image = await (boundary.currentContext!.findRenderObject()
              as RenderRepaintBoundary)
          .toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory(directory).create(recursive: true);
      await File('$directory/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  setUpAll(() async {
    final fonts = Platform.environment['SLIM_UI_PREVIEW_FONTS'];
    if (fonts != null) {
      for (final family in ['Roboto', 'MaterialIcons']) {
        final filename = family == 'Roboto'
            ? 'Roboto-Regular.ttf'
            : 'MaterialIcons-Regular.otf';
        final loader = FontLoader(family)
          ..addFont(Future.value(ByteData.sublistView(await File(
                  family == 'Roboto'
                      ? (Platform.environment['SLIM_UI_PREVIEW_FONT'] ??
                          '$fonts/$filename')
                      : '$fonts/$filename')
              .readAsBytes())));
        await loader.load();
      }
    }
  });

  testWidgets(
      'locate blocks repeated taps while pending and recovers after failure',
      (tester) async {
    final pending = Completer<bool>();
    int requests = 0;
    await show(tester, SlimLocatePanel(onLocate: () {
      requests++;
      return pending.future;
    }));
    await preview(tester, 'slim-locate');
    final button = find.byType(Button);
    expect(tester.getSize(button).width, 358);
    expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
    await tester.tap(button);
    await tester.pump();
    await tester.tap(button);
    expect(requests, 1);
    pending.complete(false);
    await tester.pumpAndSettle();
    expect(find.text('Connect to Slim, then try again.'), findsOneWidget);
    expect(tester.widget<Button>(button).loading, false);
    expect(tester.takeException(), null);
  });

  for (final width in [320.0, 390.0, 768.0]) {
    testWidgets('Slim actions fit width $width with double-size text',
        (tester) async {
      await show(tester, SlimLocatePanel(onLocate: () async => true),
          width: width, scale: 2);
      await tester.ensureVisible(find.byType(Button));
      await tester.tap(find.byType(Button));
      await tester.pumpAndSettle();
      expect(find.textContaining('LED flash requested'), findsOneWidget);
      expect(tester.takeException(), null);
      for (final stage in [0, 2, 3]) {
        await show(
            tester,
            SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SettlingGuidance(
                    s: SlimSettlingState(stage, true, 0, 0, 43200, 600),
                    canStartRecovery: true,
                    onAction: (_) {})),
            width: width,
            scale: 2);
        await tester.ensureVisible(find.byType(Button));
        expect(tester.getSize(find.byType(Button)).height,
            greaterThanOrEqualTo(48));
        expect(tester.takeException(), null);
      }
    });
  }

  testWidgets('calibration retry aligns with content and invokes refresh',
      (tester) async {
    final notifier = RetryAsc();
    await show(
        tester,
        ProviderScope(
            overrides: [nativeAscProvider.overrideWith(() => notifier)],
            child: const SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: NativeAscSettingWidget(
                    deviceId: 'test',
                    firmwareVersion: '0.20.2',
                    manualControls: Text('Manual controls')))));
    await preview(tester, 'slim-calibration-retry');
    expect(tester.getTopLeft(find.byType(Button)).dx, 16);
    expect(tester.getSize(find.byType(Button)).width, 358);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(notifier.retries, 1);
    expect(find.text('Checking the sensor setting…'), findsOneWidget);
    expect(find.text('Manual controls'), findsNothing);
    expect(tester.takeException(), null);
  });

  testWidgets(
      'recovery action uses the shared button and preserves confirmation',
      (tester) async {
    int? action;
    await show(
        tester,
        SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SettlingGuidance(
                s: const SlimSettlingState(0, false, 0, 0, 0, 0),
                canStartRecovery: true,
                onAction: (value) => action = value)));
    await preview(tester, 'slim-recovery');
    await tester.tap(find.text('Start 12-hour check'));
    await tester.pumpAndSettle();
    expect(action, null);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(action, null);
    expect(tester.takeException(), null);
  });
}
