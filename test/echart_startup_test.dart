import 'dart:async';

import 'package:airspothealth/core/widgets/airspot_chart/echart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// The WebView plugin's platform interface is used only to exercise its callbacks.
// ignore: depend_on_referenced_packages
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class _Platform extends WebViewPlatform {
  late _Controller controller;
  late _Delegate delegate;

  @override
  PlatformWebViewController createPlatformWebViewController(
          PlatformWebViewControllerCreationParams params) =>
      controller = _Controller(params);

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
          PlatformNavigationDelegateCreationParams params) =>
      delegate = _Delegate(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
          PlatformWebViewWidgetCreationParams params) =>
      _Widget(params);
}

class _Controller extends PlatformWebViewController {
  _Controller(super.params) : super.implementation();
  final scripts = <String>[];
  final initialization = Completer<void>();
  bool loaded = false;

  @override
  Future<void> setBackgroundColor(Color color) async {}
  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
  @override
  Future<void> setPlatformNavigationDelegate(
      PlatformNavigationDelegate handler) async {}
  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async {}
  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {
    loaded = true;
  }

  @override
  Future<void> runJavaScript(String script) async {
    scripts.add(script);
    if (scripts.length == 1) await initialization.future;
  }
}

class _Delegate extends PlatformNavigationDelegate {
  _Delegate(super.params) : super.implementation();
  late PageEventCallback finished;
  @override
  Future<void> setOnPageFinished(PageEventCallback callback) async {
    finished = callback;
  }

  @override
  Future<void> setOnPageStarted(PageEventCallback callback) async {}
  @override
  Future<void> setOnNavigationRequest(
      NavigationRequestCallback callback) async {}
  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback callback) async {}
}

class _Widget extends PlatformWebViewWidget {
  _Widget(super.params) : super.implementation();
  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  late _Platform platform;
  setUp(() {
    platform = _Platform();
    WebViewPlatform.instance = platform;
  });

  testWidgets('queues latest readings until chart initialization completes',
      (tester) async {
    Future<void> show(String option) =>
        tester.pumpWidget(MaterialApp(home: EChart(option: option)));
    await show('{"series":[]}');
    await tester.pump();
    expect(platform.controller.loaded, isTrue);
    await show('{"series":[{"data":[[1,500]]}]}');
    expect(platform.controller.scripts, isEmpty);
    platform.delegate.finished('about:blank');
    expect(platform.controller.scripts, hasLength(1));
    await show('{"series":[{"data":[[2,600]]}]}');
    expect(platform.controller.scripts, hasLength(1));
    platform.controller.initialization.complete();
    await tester.pump();
    expect(platform.controller.scripts, hasLength(2));
    expect(platform.controller.scripts.last, contains('[2,600]'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposal during initialization does not send a queued update',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EChart(option: '{}')));
    await tester.pump();
    platform.delegate.finished('about:blank');
    await tester.pumpWidget(const SizedBox());
    platform.controller.initialization.complete();
    await tester.pump();
    expect(platform.controller.scripts, hasLength(1));
    expect(tester.takeException(), isNull);
  });
}
