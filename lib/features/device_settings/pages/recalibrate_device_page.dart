import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/device_reset_sensor_notifier.dart';
import 'package:airspothealth/features/device_settings/providers/recalibration_time_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:flutter/cupertino.dart';
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
        // Reset the calibration status after 5 seconds
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(seconds: 5), () {
            if (context.mounted) {
              ref
                  .read(recalibrationTimeProvider(deviceId).notifier)
                  .setRecalibrationTime(null);
            }
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
          deviceId: deviceId,
          suffixText: 'Calibrate',
        ),
      ),
      body: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16.0),
          child: calibrationStatus.isNone
              ? _buildCalibrationSettings(
                  calibrationStatus, deviceSettings, ref)
              : _buildCalibrationStatusWidget(
                  calibrationStatus, deviceSettings, ref)),
    );
  }

  Widget _buildCalibrationSettings(AsyncProgressValue calibrationStatus,
      DeviceSettings deviceSettings, WidgetRef ref) {
    return ListView(
      children: [
        // Auto Calibration Toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Auto Calibration',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          value: deviceSettings.autoCalibration,
          onChanged: (bool value) {
            if (calibrationStatus.isInProgress) return;

            ref.read(deviceSettingsProvider(deviceId).notifier).updateSettings(
                deviceSettings.copyWith(autoCalibration: value));
          },
        ),
        // Additional Information
        const Text(
          'If Auto Calibration is enabled, AirSpot will calibrate itself on the assumption that it has made measurements in fresh air at least once a week. It is usually best to leave this OFF. See full manual for details.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const Text(
          'Forced Calibration',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),

        const Text(
          'To calibrate this AirSpot, place the device outdoors for atleast 5 minutes, away from any people or CO2 sources, then tap the icon below. See full manual for details.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        GestureDetector(
          onTap: () {
            ref
                .read(recalibrationTimeProvider(deviceId).notifier)
                .startRecalibration();
          },
          child: Image.asset(Assets.recalibrateImage, height: 120),
        ),
        const Divider(),
        // Reset Sensor Button
        Text(
          'Reset Sensor',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          'If you are experiencing issues with your AirSpot, you can reset the sensor to its factory settings. This will erase all calibration data and settings.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ResetSensorWidget(deviceId: deviceId),
      ],
    );
  }

  Widget _buildCalibrationStatusWidget(AsyncProgressValue calibrationStatus,
      DeviceSettings deviceSettings, WidgetRef ref) {
    if (calibrationStatus.isInProgress) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Calibrating',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              (calibrationStatus as AsyncInProgress).progress < 0
                  ? 'Initializing...'
                  : 'Remaining Time: ${calibrationStatus.progress.toInt()} seconds',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    if (calibrationStatus.isSuccess) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Calibration Completed',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Correction Value: ${(calibrationStatus as AsyncSuccess).data}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        children: [
          const Text(
            'Calibration Failed',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            'Error: ${(calibrationStatus as AsyncFailure).error}',
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class ResetSensorWidget extends ConsumerWidget {
  const ResetSensorWidget({
    required this.deviceId,
    super.key,
  });

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncProgressValue>(deviceSensorResetProvider(deviceId),
        (_, nStatus) {
      if (nStatus.isSuccess) {
        // show a success message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.showSnackBar('Sensor reset successfully');
        });
        return;
      }

      if (nStatus.isFailure) {
        // show an error message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.showSnackBar(
              'Failed to reset sensor: ${(nStatus as AsyncFailure).error}');
        });
        return;
      }
    });

    final AsyncProgressValue resetSensorStatus =
        ref.watch(deviceSensorResetProvider(deviceId));

    return Button(
      type: ButtonType.outlined,
      disabled: resetSensorStatus.isInProgress,
      onPressed: () {
        if (resetSensorStatus.isInProgress) return;

        ref.read(deviceSensorResetProvider(deviceId).notifier).resetSensor();
      },
      child: resetSensorStatus.isInProgress
          ? const CupertinoActivityIndicator()
          : const Text('Reset Sensor'),
    );
  }
}
