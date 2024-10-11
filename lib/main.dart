import 'package:airspothealth/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AirspotApp());
}

class AirspotApp extends StatelessWidget {
  const AirspotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airspot Health',
      theme: AppTheme.theme,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Airspot Health'),
      ),
      body: const Center(
        child: Text('Welcome to Airspot Health'),
      ),
    );
  }
}
