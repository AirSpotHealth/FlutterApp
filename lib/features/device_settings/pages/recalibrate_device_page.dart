import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/device_reset_sensor_provider.dart';
import 'package:airspothealth/features/device_settings/providers/recalibration_time_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/altitude_pressure_scaling_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/manual_calibration_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/next_calibration_date_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_card.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_tile.dart';
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

    debugPrint("CALIB TARGET: ${deviceSettings.recalibrationTarget}");

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: DeviceSettingsNameWidget(
          deviceId: deviceId,
          suffixText: 'Calibrate',
        ),
      ),
      body: calibrationStatus.isNone
          ? _buildCalibrationSettings(calibrationStatus, deviceSettings, ref)
          : _buildCalibrationStatusWidget(
              calibrationStatus, deviceSettings, ref),
    );
  }

  Widget _buildCalibrationSettings(
    AsyncProgressValue calibrationStatus,
    DeviceSettings deviceSettings,
    WidgetRef ref,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        SettingsCard(
          children: [
            SettingsTile(
              assetPath: Assets.recalibrateSettings,
              iconBgColor: AppColors.brandColorGreen.withValues(alpha: 0.1),
              title: 'Auto Calibration',
              subtitle:
                  'Automatically calibrate the sensor based on the lowest CO₂ reading in the previous 7 days.',
              isLast: !deviceSettings.autoCalibration,
              action: Switch.adaptive(
                value: deviceSettings.autoCalibration,
                activeThumbColor: AppColors.primaryColor,
                onChanged: calibrationStatus.isInProgress
                    ? null
                    : (value) {
                        ref
                            .read(deviceSettingsProvider(deviceId).notifier)
                            .updateSettings(deviceSettings.copyWith(
                                autoCalibration: value));
                      },
              ),
            ),
            if (deviceSettings.autoCalibration)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: NextCalibrationDateWidget(deviceId: deviceId),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'If Auto Calibration is enabled, AirSpot will calibrate itself on the assumption that it has made measurements in fresh air at least once a week. It is usually best to leave this OFF unless you are sure AirSpot will be measuring fresh air at least every few days. See full manual for details.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 24),
        SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ManualCalibrationWidget(
                deviceId: deviceId,
                calibrationTarget: deviceSettings.recalibrationTarget,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AltitudePressureScalingWidget(deviceId: deviceId),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ResetSensorWidget(deviceId: deviceId),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCalibrationStatusWidget(AsyncProgressValue calibrationStatus,
      DeviceSettings deviceSettings, WidgetRef ref) {
    if (calibrationStatus.isInProgress) {
      final progress = calibrationStatus as AsyncInProgress;
      String displayText;

      if (progress.message?.isNotEmpty == true) {
        displayText = progress.message!;
      } else if (progress.progress < 0) {
        displayText = 'Initialising...';
      } else {
        displayText = 'Remaining Time: ${progress.progress.toInt()} seconds';
      }

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
              displayText,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Reset Sensor',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        const Text(
          "If you are experiencing issues with your AirSpot's accuracy, you can reset the sensor to its factory settings. This will erase all calibration data and settings.",
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Button(
            disabled: resetSensorStatus.isInProgress,
            backgroundColor: AppColors.brandColorRed,
            onPressed: () {
              if (resetSensorStatus.isInProgress) return;

              ref
                  .read(deviceSensorResetProvider(deviceId).notifier)
                  .resetSensor();
            },
            child: resetSensorStatus.isInProgress
                ? const CupertinoActivityIndicator(color: Colors.white)
                : const Text('Reset Sensor'),
          ),
        ),
      ],
    );
  }
}
