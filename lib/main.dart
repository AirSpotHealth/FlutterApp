import 'package:airspothealth/core/router/app_router.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/notification_service.dart';
import 'package:airspothealth/core/services/prefs_service.dart';
import 'package:airspothealth/core/theme/app_theme.dart';
import 'package:airspothealth/core/utils/storage_keys.dart';
import 'package:airspothealth/features/home/widgets/services_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:system_date_time_format/system_date_time_format.dart';

late final DateFormat systemDateFormat;
late final DateFormat systemTimeFormat;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await [
    IsarService().initialize(),
    PrefsService().initialize(),
  ].wait;

  systemDateFormat =
      DateFormat(await SystemDateTimeFormat().getDatePattern() ?? 'yyyy-MM-dd');
  systemTimeFormat =
      DateFormat(await SystemDateTimeFormat().getTimePattern() ?? 'HH:mm:ss');

  await [_checkVersion(), NotificationService.initNotification()].wait;

  runApp(
    const ProviderScope(
      child: AirspotApp(),
    ),
  );
}

Future<void> _checkVersion() async {
  final prefs = PrefsService();
  final currentVersion = prefs.getString(StorageKeys.appVerion);
  final appVersion = await PackageInfo.fromPlatform();

  if (currentVersion != appVersion.version) {
    await prefs.setString(StorageKeys.appVerion, appVersion.version);

    if (currentVersion == '') return;

    await IsarService().clearAllData();
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
