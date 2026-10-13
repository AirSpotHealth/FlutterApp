import 'package:airspothealth/core/theme/app_theme.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/restart_device_action.dart';
import 'package:airspothealth/features/device_settings/widgets/slim_diagnostics_export.dart';
import 'package:airspothealth/features/app_setup/providers/patch_update_provider.dart';
import 'package:airspothealth/features/app_setup/widgets/patch_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class PreviewPatch extends PatchUpdateNotifier {
  @override
  PatchUpdateState build() => const PatchUpdateState(
      phase: PatchPhase.available, release: '3.8.13+161', currentPatch: 1);
}

void main() {
  testWidgets(
      'settings rows and sheets reuse app components without inline descriptions',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ProviderScope(
        overrides: [patchUpdateProvider.overrideWith(PreviewPatch.new)],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme.copyWith(
                appBarTheme: AppTheme.theme.appBarTheme.copyWith(
                    titleTextStyle: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: Colors.white))),
            home: Builder(
                builder: (context) => Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(title: const Text('Device Settings')),
                    body: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          SettingItemWidget(
                              item: SettingItem(
                                  title: 'Power Off Device',
                                  assetIcon: Assets.powerOff,
                                  suffixWidget: const SizedBox()),
                              onTap: () {}),
                          RestartDeviceAction(sendRestart: () async => true),
                          SettingItemWidget(
                              item: SettingItem(
                                  title: 'Factory Reset',
                                  assetIcon: Assets.factoryReset,
                                  suffixWidget: const SizedBox()),
                              onTap: () {}),
                          SettingItemWidget(
                              item: SettingItem(
                                  title: 'Export Diagnostics',
                                  assetIcon: Assets.reportIssue,
                                  suffixWidget: const SizedBox()),
                              onTap: () => showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  builder: (_) => DiagnosticsExportSheet(
                                      onExport: () async {}))),
                          SettingItemWidget(
                              item: SettingItem(
                                  title: 'App Updates',
                                  assetIcon: Assets.deviceUpdate,
                                  suffixWidget: const SizedBox()),
                              onTap: () => showPatchUpdateDialog(context)),
                        ])))))));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNothing);
    expect(find.text('Keeps settings, calibration and saved readings'),
        findsNothing);
    await tester.tap(find.text('Restart Device'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export Diagnostics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('App Updates'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), null);
  });
}
