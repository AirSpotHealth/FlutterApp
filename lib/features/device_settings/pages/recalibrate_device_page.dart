import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/providers/recalibration_time_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecalibrateDevicePage extends ConsumerWidget {
  const RecalibrateDevicePage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(recalibrationTimeProvider(deviceId), (oldState, newState) {
      if (newState != null &&
          newState <= 0 &&
          oldState != null &&
          oldState > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Recalibration completed successfully, Correction value: $newState'),
          ),
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(recalibrationTimeProvider(deviceId).notifier)
              .setRecalibrationDone();
        });
      }
    });

    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    final int? recalibrationTime =
        ref.watch(recalibrationTimeProvider(deviceId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: DeviceSettingsNameWidget(
            deviceId: deviceId, suffixText: 'Recalibrate'),
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
            if (recalibrationTime == null)
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
              )
            else if (recalibrationTime > 0) ...[
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  text: 'Calibration in Progress\n',
                  children: [
                    TextSpan(
                      text: 'Remaining Time: $recalibrationTime seconds',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ] else ...[
              Text('Calibration Completed',
                  style: context.textTheme.bodyLarge?.weight600),
              const SizedBox(height: 16),
              Text(
                'Correction Value: $recalibrationTime',
                style: context.textTheme.bodyMedium,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
