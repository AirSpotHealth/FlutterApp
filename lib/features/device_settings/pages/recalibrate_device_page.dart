import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/recalibration_time_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecalibrateDevicePage extends ConsumerWidget {
  const RecalibrateDevicePage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncProgressValue>(recalibrationTimeProvider(deviceId),
        (_, nStatus) {
      if (nStatus.isSuccess) {
        // reset the calibration status after 5 seconds
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(seconds: 5), () {
            ref
                .read(recalibrationTimeProvider(deviceId).notifier)
                .setRecalibrationTime(null);
          });
        });
      }
    });

    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    final AsyncProgressValue calibrationStatus =
        ref.watch(recalibrationTimeProvider(deviceId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: DeviceSettingsNameWidget(
            deviceId: deviceId, suffixText: 'Calibrate'),
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
                'If Autocalibration is enabled, AirSpot will calibrate itself on the assumption that it has made measurements in fresh air at least once a week. It is usually best to to leave this OFF. See full manual for details.'),
            const Spacer(),
            ...calibrationStatus.when(
              none: () {
                return [
                  SwitchListTile(
                    title: const Text('Auto Calibration',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    value: deviceSettings.autoCalibration,
                    onChanged: (bool value) {
                      ref
                          .read(deviceSettingsProvider(deviceId).notifier)
                          .updateSettings(
                              deviceSettings.copyWith(autoCalibration: value));
                    },
                  )
                ];
              },
              inProgress: (progress, message) {
                return [
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      text: 'Calibration in Progress\n',
                      children: [
                        TextSpan(
                          text: 'Remaining Time: ${progress.toInt()} seconds',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16)
                ];
              },
              success: (data) {
                return [
                  Text('Calibration Completed',
                      style: context.textTheme.bodyLarge?.weight600),
                  const SizedBox(height: 16),
                  Text(
                    'Correction Value: $data',
                    style: context.textTheme.bodyMedium,
                  ),
                ];
              },
              failure: (error) {
                return [];
              },
            )
          ],
        ),
      ),
    );
  }
}
