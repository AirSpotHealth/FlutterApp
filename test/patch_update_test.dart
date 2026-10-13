import 'package:airspothealth/features/app_setup/app_updates_page.dart';
import 'package:airspothealth/features/app_setup/providers/app_version_provider.dart';
import 'dart:async';
import 'package:airspothealth/features/app_setup/providers/patch_update_provider.dart';
import 'package:airspothealth/features/app_setup/widgets/patch_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class FakeUpdater implements ShorebirdUpdater {
  @override
  bool isAvailable = true;
  Patch? current, next;
  UpdateStatus status = UpdateStatus.outdated;
  bool fail = false, stage = true;
  int downloads = 0;
  Completer<void>? gate;
  final tracks = <String?>[];
  @override
  Future<Patch?> readCurrentPatch() async => current;
  @override
  Future<Patch?> readNextPatch() async => next;
  @override
  Future<UpdateStatus> checkForUpdate({UpdateTrack? track}) async {
    tracks.add(track?.name);
    if (fail) throw StateError('offline');
    return status;
  }

  @override
  Future<void> update({UpdateTrack? track}) async {
    tracks.add(track?.name);
    downloads++;
    if (gate != null) await gate!.future;
    if (fail) throw StateError('offline');
    if (stage) next = const Patch(number: 2);
  }
}

void main() {
  late FakeUpdater updater;
  late ProviderContainer container;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    updater = FakeUpdater();
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(overrides: [
      shorebirdUpdaterProvider.overrideWithValue(updater),
      patchPreferencesProvider.overrideWith((ref) async => prefs),
      patchReleaseProvider.overrideWith((ref) async => '3.8.13+161'),
      appVersionProvider.overrideWith((ref) async => null),
    ]);
  });
  tearDown(() => container.dispose());

  test(
      'offers patch, uses existing stable track, stages once, requires restart',
      () async {
    final controller = container.read(patchUpdateProvider.notifier);
    expect(await controller.checkOnLaunch(), true);
    expect(await controller.checkOnLaunch(), false);
    expect(updater.downloads, 0);
    updater.gate = Completer();
    final download = controller.download();
    await controller.download();
    expect(container.read(patchUpdateProvider).phase, PatchPhase.downloading);
    updater.gate!.complete();
    await download;
    expect(updater.downloads, 1);
    expect(updater.tracks.every((track) => track == 'stable'), true);
    expect(container.read(patchUpdateProvider).phase, PatchPhase.ready);
    expect(container.read(patchUpdateProvider).currentPatch, null);
    expect(container.read(patchUpdateProvider).nextPatch, 2);
  });
  test('no-op update cannot claim a downloaded patch', () async {
    final controller = container.read(patchUpdateProvider.notifier);
    updater.stage = false;
    await controller.check();
    await controller.download();
    expect(container.read(patchUpdateProvider).phase, PatchPhase.available);
  });
  test('failed download stays retryable and unavailable engine never downloads',
      () async {
    final controller = container.read(patchUpdateProvider.notifier);
    await controller.check();
    updater.fail = true;
    await controller.download();
    expect(container.read(patchUpdateProvider).phase, PatchPhase.failed);
    updater.isAvailable = false;
    await controller.check();
    expect(container.read(patchUpdateProvider).phase, PatchPhase.unavailable);
  });
  test(
      'installed patch change is confirmed, and rollback remains restart-required',
      () async {
    updater.current = const Patch(number: 2);
    updater.status = UpdateStatus.restartRequired;
    final controller = container.read(patchUpdateProvider.notifier);
    await controller.check();
    expect(container.read(patchUpdateProvider).applied, true);
    expect(container.read(patchUpdateProvider).phase, PatchPhase.ready);
    expect(container.read(patchUpdateProvider).nextPatch, null);
    controller.acknowledgeApplied();
    updater.status = UpdateStatus.upToDate;
    await controller.check();
    expect(container.read(patchUpdateProvider).applied, false);
  });
  testWidgets(
      'App Setup keeps patch and store checks separate on a small screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AppUpdatesPage())));
    await tester.pumpAndSettle();
    expect(find.text('Quick app updates'), findsOneWidget);
    expect(find.text('Store updates'), findsOneWidget);
    expect(find.text('Store version could not be verified.'), findsOneWidget);
    expect(find.text('No newer store release is available.'), findsNothing);
    await tester.tap(find.text('Check for patches'));
    await tester.pumpAndSettle();
    expect(find.text('A small update is ready'), findsWidgets);
    expect(tester.takeException(), null);
  });

  testWidgets(
      'compact dialog shows download, pending restart and installed version',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await container.read(patchUpdateProvider.notifier).check();
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
            home: Builder(
                builder: (context) => Scaffold(
                    body: TextButton(
                        onPressed: () => showPatchUpdateDialog(context),
                        child: const Text('Open')))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('A small update is ready'), findsOneWidget);
    updater.gate = Completer();
    await tester.tap(find.text('Download update'));
    await tester.pump();
    expect(find.text('Downloading your update'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    updater.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Ready when you reopen'), findsOneWidget);
    expect(find.textContaining('isn’t active yet'), findsOneWidget);
    expect(tester.takeException(), null);
  });
}
