import 'package:airspothealth/core/router/app_router.dart';
import 'package:airspothealth/core/services/home_widget_service.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/notification_service.dart';
import 'package:airspothealth/core/services/prefs_service.dart';
import 'package:airspothealth/core/theme/app_theme.dart';
import 'package:airspothealth/core/utils/local_date_format.dart';
import 'package:airspothealth/core/utils/storage_keys.dart';
import 'package:airspothealth/features/home/widgets/services_banner.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await [
    IsarService().initialize(),
    PrefsService().initialize(),
    LocalDateFormat().initialize(),
    NotificationService.initNotification(),
    HomeWidgetService().initialize(),
  ].wait;

  await _checkVersion();

  runApp(
    ProviderScope(
      child: const AirspotApp(),
    ),
  );
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

class AirspotApp extends StatelessWidget {
  const AirspotApp({super.key});

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
