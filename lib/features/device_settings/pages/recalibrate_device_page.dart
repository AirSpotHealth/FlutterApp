import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/providers/recalibration_time_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecalibrateDevicePage extends ConsumerWidget {
  const RecalibrateDevicePage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    final int? recalibrationTime =
        ref.watch(recalibrationTimeProvider(deviceId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Recalibrate AirSpot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            GestureDetector(
                onTap: () {
                  ref
                      .read(bleDeviceCommunicationProvider(deviceId).notifier)
                      .sendCommand(DeviceCmdUtils.startRecalibration());
                },
                child: Image.asset(Assets.recalibrateImage, height: 100)),
            const SizedBox(height: 100),
            const Text(
                'The AirSpot device automatically calibrates itself to the lowest CO₂ levels it sees over a week.'),
            const SizedBox(height: 16),
            const Text(
                'If your AirSpot requires forced calibration then place it in a well-ventilated outdoor space, stand at least 1.5 meters away from it, and press the calibration icon above.'),
            const Spacer(),
            if (recalibrationTime != null) ...[
              const SizedBox(height: 16),
              Text(
                'Calibration in Progress: Remaining Time: $recalibrationTime seconds',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ] else
              SwitchListTile(
                title: const Text('Auto Calibration',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                value: deviceSettings.autoCalibration,
                onChanged: (bool value) {
                  ref
                      .read(deviceSettingsProvider(deviceId).notifier)
                      .updateSettings(
                          deviceSettings.copyWith(autoCalibration: value));
                },
              ),
          ],
        ),
      ),
    );
  }
}
