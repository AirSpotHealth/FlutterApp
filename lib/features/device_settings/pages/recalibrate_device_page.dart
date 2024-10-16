import 'package:airspothealth/core/utils/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecalibrateDevicePage extends ConsumerWidget {
  const RecalibrateDevicePage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Recalibrate AirSpot'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          Image.asset(Assets.recalibrateImage, height: 100),
          const SizedBox(height: 100),
          const Text(
              'The AirSpot device automatically calibrates itself to the lowest CO₂ levels it sees over a week.'),
          const SizedBox(height: 16),
          const Text(
              'If your AirSpot requires forced calibration then place it in a well-ventilated outdoor space, stand at least 1.5 meters away from it, and press the calibration icon above.'),
        ],
      ),
    );
  }
}
