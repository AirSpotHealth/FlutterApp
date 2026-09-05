import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/services/supabase_service.dart';
import 'package:airspothealth/core/services/sync_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:airspothealth/core/providers/auto_sync_preference_provider.dart';
import 'package:airspothealth/core/services/cloud_sync_access.dart';
import 'package:airspothealth/core/services/prefs_service.dart';
import 'package:airspothealth/core/widgets/sync_status_indicator.dart';
import 'package:airspothealth/features/app_setup/providers/dev_mode_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/cloud_sync_setting_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({'auto_sync_enabled': true});
    await PrefsService().initialize();
  });

  test('saved auto-sync on cannot enable cloud access outside dev mode',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(CloudSyncAccess.enabled, false);
    expect(CloudSyncAccess.requireEnabled, throwsStateError);
    expect(container.read(autoSyncPreferenceProvider), false);
    await container.read(autoSyncPreferenceProvider.notifier).setEnabled(true);
    expect(container.read(autoSyncPreferenceProvider), false);
  });

  test('dev mode enables access and disabling it revokes access immediately',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final mode = container.read(devModeProvider.notifier);
    mode.enableDevMode();
    expect(CloudSyncAccess.enabled, true);
    expect(container.read(autoSyncPreferenceProvider), true);
    await container.read(autoSyncPreferenceProvider.notifier).setEnabled(false);
    mode.disableDevMode();
    expect(CloudSyncAccess.enabled, false);
    expect(container.read(autoSyncPreferenceProvider), false);
    mode.enableDevMode();
    container.read(autoSyncPreferenceProvider);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(autoSyncPreferenceProvider), false);
  });

  test('service entry points block sync and claims outside dev mode', () async {
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-only',
      authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(() => Supabase.instance.dispose());
    final reading =
        DeviceData(deviceId: 'test', dateTime: DateTime(2026), value: 600);
    await expectLater(SupabaseService().claimDevice('test'), throwsStateError);
    await expectLater(
        SupabaseService().uploadReadings([reading]), throwsStateError);
    await expectLater(SyncService().syncData(), throwsStateError);
    // Immediate background uploads silently stop and leave local data unsynced.
    await SyncService().uploadImmediateReading(reading);
    expect(reading.synced, false);
  });

  testWidgets('cloud controls and status stay hidden outside dev mode',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(
            home: Scaffold(
      body: Column(children: [
        CloudSyncSettingWidget(deviceId: 'test'),
        SyncStatusIndicator(deviceId: 'test'),
      ]),
    ))));
    expect(find.text('Cloud Sync'), findsNothing);
    expect(find.byIcon(Icons.cloud_outlined), findsNothing);
  });
}
