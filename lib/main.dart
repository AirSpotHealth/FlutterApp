import 'package:airspothealth/core/router/app_router.dart';
import 'package:airspothealth/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AirspotApp());
}

class AirspotApp extends StatelessWidget {
  const AirspotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
    );
  }
}
