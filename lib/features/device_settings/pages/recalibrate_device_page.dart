import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/device_reset_sensor_provider.dart';
import 'package:airspothealth/features/device_settings/providers/recalibration_time_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/altitude_pressure_scaling_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/manual_calibration_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/next_calibration_date_widget.dart';
import 'package:airspothealth/i18n/strings.g.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            t.autoCalibration,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            t.autoCalibrationDescription,
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          value: deviceSettings.autoCalibration,
          onChanged: calibrationStatus.isInProgress
              ? null
              : (value) {
                  ref
                      .read(deviceSettingsProvider(deviceId).notifier)
                      .updateSettings(
                          deviceSettings.copyWith(autoCalibration: value));
                },
        ),
        const SizedBox(height: 4),
        Text(
          t.autoCalibrationWarning,
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
        if (deviceSettings.autoCalibration)
          NextCalibrationDateWidget(deviceId: deviceId),
        const SizedBox(height: 8),
        const Divider(),
        ManualCalibrationWidget(
          deviceId: deviceId,
          calibrationTarget: deviceSettings.recalibrationTarget,
        ),
        const Divider(),
        AltitudePressureScalingWidget(deviceId: deviceId),
        const SizedBox(height: 8),
        const Divider(),
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
            Text(
              t.calibratingStatus,
              style: TextStyle(fontSize: 14),
            ),
            Text(
              (calibrationStatus as AsyncInProgress).progress < 0
                  ? t.initialisingStatus
                  : t.remainingTime(
                      seconds: calibrationStatus.progress.toInt()),
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
            Text(
              t.calibrationCompleted,
              style: TextStyle(fontSize: 14),
            ),
            Text(
              t.correctionValue(
                  value: (calibrationStatus as AsyncSuccess).data.toString()),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        children: [
          Text(
            t.calibrationFailed,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            t.errorLabel(error: (calibrationStatus as AsyncFailure).error),
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
          context.showSnackBar(t.sensorResetSuccessfully);
        });
        return;
      }

      if (nStatus.isFailure) {
        // show an error message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.showSnackBar(
              t.failedToResetSensor(error: (nStatus as AsyncFailure).error));
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
        ListTile(
          title: Text(
            t.resetSensor,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            t.resetSensorDescription,
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        Button(
          disabled: resetSensorStatus.isInProgress,
          backgroundColor: AppColors.brandColorRed,
          onPressed: () {
            if (resetSensorStatus.isInProgress) return;

            ref
                .read(deviceSensorResetProvider(deviceId).notifier)
                .resetSensor();
          },
          child: resetSensorStatus.isInProgress
              ? const CupertinoActivityIndicator()
              : Text(t.resetSensor),
        ),
      ],
    );
  }
}
