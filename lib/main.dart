import 'package:airspothealth/core/router/app_router.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/live_activity_service.dart';
import 'package:airspothealth/core/services/notification_service.dart';
import 'package:airspothealth/core/services/prefs_service.dart';
import 'package:airspothealth/core/theme/app_theme.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/local_date_format.dart';
import 'package:airspothealth/core/utils/storage_keys.dart';
import 'package:airspothealth/features/home/widgets/services_banner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first (required by NotificationService)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
  }

  // Initialize other services in parallel
  await [
    Supabase.initialize(
      url: Constants.supabaseUrl,
      publishableKey: Constants.supabaseAnonKey,
    ),
    IsarService().initialize(),
    PrefsService().initialize(),
    LocalDateFormat().initialize(),
    NotificationService.initNotification(),
    _initializeHomeWidget(),
  ].wait;

  // Clean up stale Live Activities IMMEDIATELY before BLE connects
  // This prevents race condition where new Live Activities are created before cleanup
  await _cleanupStaleNotifications();

  await _checkVersion();

  runApp(
    ProviderScope(
      child: const AirspotApp(),
    ),
  );
}

Future<void> _cleanupStaleNotifications() async {
  try {
    debugPrint(
        '🧹 Startup: Removing stale Live Activities from previous app session');

    // Since BLE devices disconnect when app is killed, any Live Activities
    // from previous session are showing stale "connected" data
    // Remove them BEFORE BLE auto-connect happens (which triggers in bluetoothStateProvider)
    await LiveActivityService().endLiveActivity();

    debugPrint(
        '✅ Stale Live Activities cleared - fresh ones will be created on device reconnection');
  } catch (e) {
    debugPrint('❌ Error during startup notification cleanup: $e');
  }
}

Future<void> _initializeHomeWidget() async {
  try {
    // Configure Home Widget with App Group
    await HomeWidget.setAppGroupId(Constants.appGroupId);
    debugPrint(
        '✅ Home Widget initialized with App Group: ${Constants.appGroupId}');
  } catch (e) {
    debugPrint('❌ Failed to initialize Home Widget: $e');
  }
}

Future<void> _checkVersion() async {
  try {
    // Get prefs and version info first
    final prefs = PrefsService();
    final currentVersion = prefs.getString(StorageKeys.appVerion);
    final appVersion = await PackageInfo.fromPlatform();

    // If versions match, no need to proceed
    if (currentVersion == appVersion.version) {
      return;
    }

    debugPrint('currentVersion: $currentVersion');
    debugPrint('appVersion: ${appVersion.version}');

    // For first install, just save version and return
    if (currentVersion == '') {
      await prefs.setString(
          StorageKeys.appVerion, appVersion.version.toString());
      return;
    }

    // For version change, clear data first, then save new version
    IsarService().clearAllData(); // Wait for clear to complete
    await prefs.setString(StorageKeys.appVerion, appVersion.version.toString());
  } catch (e) {
    debugPrint(
        'Error during version check: $e, StackTrace: ${StackTrace.current}');
  }
}

class AirspotApp extends StatefulWidget {
  const AirspotApp({super.key});

  @override
  State<AirspotApp> createState() => _AirspotAppState();
}

class _AirspotAppState extends State<AirspotApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint('App lifecycle state changed: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - clean up stale notifications
        // and restart missing live activities
        _handleAppResumed();
        break;

      case AppLifecycleState.paused:
        // App is about to go to background or be terminated
        // Note: This doesn't mean app is killed, just backgrounded
        debugPrint('App paused - devices will disconnect if app is killed');
        break;

      case AppLifecycleState.detached:
        // App is about to be terminated (killed by system or user)
        // Since BLE devices disconnect when app is killed, remove all Live Activities
        _handleAppTermination();
        break;

      case AppLifecycleState.inactive:
        // App is inactive (transitioning between states)
        break;

      case AppLifecycleState.hidden:
        // App window is hidden
        break;
    }
  }

  void _handleAppResumed() {
    debugPrint('App resumed - checking for missing Live Activities');

    // Check and restart any missing Live Activities for connected devices
    // This handles edge cases where toggle is ON but notification isn't showing
    LiveActivityService().checkAndRestartMissingLiveActivities();
  }

  void _handleAppTermination() {
    debugPrint(
        'App being terminated - removing all Live Activities/notifications');
    debugPrint('Reason: BLE devices disconnect when app is killed');

    try {
      // End all Live Activities since devices will disconnect anyway
      LiveActivityService().endLiveActivity();
      debugPrint(
          '✅ All Live Activities/notifications removed on app termination');
    } catch (e) {
      debugPrint('❌ Error removing Live Activities on termination: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.0),
        ),
        child: Stack(
          children: [
            child!,
            const Align(
              alignment: Alignment.bottomCenter,
              child: ServicesBanner(),
            ),
          ],
        ),
      ),
    );
  }
}
