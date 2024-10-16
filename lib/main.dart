import 'package:airspothealth/core/router/app_router.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await IsarService().initialize();

  runApp(
    const ProviderScope(
      child: AirspotApp(),
    ),
  );
}

class AirspotApp extends StatelessWidget {
  const AirspotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
