import 'package:airspothealth/core/providers/language_provider.dart';
import 'package:airspothealth/core/router/app_router.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/notification_service.dart';
import 'package:airspothealth/core/services/prefs_service.dart';
import 'package:airspothealth/core/theme/app_theme.dart';
import 'package:airspothealth/core/utils/storage_keys.dart';
import 'package:airspothealth/features/home/widgets/services_banner.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:system_date_time_format/system_date_time_format.dart';

late final DateFormat systemDateFormat;
late final DateFormat systemTimeFormat;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize slang with default locale (will be overridden by language provider)
  LocaleSettings.setLocale(AppLocale.en);

  await [
    IsarService().initialize(),
    PrefsService().initialize(),
  ].wait;

  systemDateFormat =
      DateFormat(await SystemDateTimeFormat().getDatePattern() ?? 'yyyy-MM-dd');
  systemTimeFormat =
      DateFormat(await SystemDateTimeFormat().getTimePattern() ?? 'HH:mm:ss');

  await NotificationService.initNotification();

  await _checkVersion();

  runApp(
    ProviderScope(
      child: TranslationProvider(
        child: const AirspotApp(),
      ),
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

class AirspotApp extends ConsumerWidget {
  const AirspotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the language provider to rebuild when locale changes
    final currentLocale = ref.watch(languageProvider);

    return MaterialApp.router(
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: AppLocaleUtils.supportedLocales,
      locale: currentLocale.flutterLocale,
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
