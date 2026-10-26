import 'package:airspothealth/features/device_settings/models/slim_settling_state.dart';
import 'package:airspothealth/features/device_settings/widgets/slim_settling_card.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
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
import 'package:airspothealth/features/device_settings/widgets/native_asc_setting_widget.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
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
      if (nStatus is AsyncFailure) {
        context.showSnackBar(
            'Calibration could not be completed. Keep the device powered and nearby, reconnect, and try again.');
      }
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
    final bool isSlim = ref
            .read(bleSavedDevicesProvider.notifier)
            .getDeviceById(deviceId)
            ?.deviceModel ==
        DeviceModel.airspotSlim;

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
          ? _buildCalibrationSettings(calibrationStatus, deviceSettings, ref,
              isSlim: isSlim)
          : _buildCalibrationStatusWidget(
              calibrationStatus, deviceSettings, ref),
    );
  }

  Widget _buildCalibrationSettings(
    AsyncProgressValue calibrationStatus,
    DeviceSettings deviceSettings,
    WidgetRef ref, {
    required bool isSlim,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        if (!isSlim) ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto Calibration',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: const Text(
              'Automatically calibrate the sensor based on the lowest CO₂ reading in the previous 7 days.',
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
            'If Auto Calibration is enabled, AirSpot will calibrate itself on the assumption that it has made measurements in fresh air at least once a week. It is usually best to leave this OFF unless you are sure AirSpot will be measuring fresh air at least every few days. See full manual for details.',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
          if (deviceSettings.autoCalibration)
            NextCalibrationDateWidget(deviceId: deviceId),
          const SizedBox(height: 8),
          const Divider(),
        ],
        if (isSlim &&
            SlimSettlingState.continuousRecoverySupported(
                ref.watch(bleDeviceProvider(deviceId)).firmwareVersion))
          SlimSettlingCard(deviceId: deviceId, showInactive: true)
        else if (isSlim)
          NativeAscSettingWidget(
              deviceId: deviceId,
              firmwareVersion:
                  ref.watch(bleDeviceProvider(deviceId)).firmwareVersion,
              manualControls: ManualCalibrationWidget(
                  deviceId: deviceId,
                  calibrationTarget: deviceSettings.recalibrationTarget))
        else
          ManualCalibrationWidget(
            deviceId: deviceId,
            calibrationTarget: deviceSettings.recalibrationTarget,
          ),
        if (!isSlim) ...[
          const Divider(),
          AltitudePressureScalingWidget(deviceId: deviceId),
          const SizedBox(height: 8),
        ],
        // Reset remains visible in both manual and auto-calibration modes.
        const Divider(),
        if (!isSlim ||
            !SlimSettlingState.continuousRecoverySupported(
                ref.watch(bleDeviceProvider(deviceId)).firmwareVersion))
          ResetSensorWidget(deviceId: deviceId),
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
            'Calibration could not be confirmed. Keep the device powered, reconnect, and check its readings before trying again.',
            style: const TextStyle(color: AppColors.textSecondary),
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
          context.showSnackBar('Sensor operation confirmed.');
        });
        return;
      }

      if (nStatus.isFailure) {
        // show an error message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.showSnackBar(
              'Could not confirm the sensor restart. Reconnect and check your readings before trying again.');
        });
        return;
      }
    });

    final AsyncProgressValue resetSensorStatus =
        ref.watch(deviceSensorResetProvider(deviceId));

    final device = ref.watch(bleDeviceProvider(deviceId));
    final isSlim = device.deviceModel == DeviceModel.airspotSlim;
    final resetUnavailable = isSlim &&
            !SlimSettlingState.supported(device.firmwareVersion)
        ? 'Update firmware to 0.19.0 or later for separate restart and calibration erase actions.'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(
            isSlim ? 'Restart Sensor' : 'Reset Sensor',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            isSlim
                ? resetUnavailable ??
                    'Restart measurements while keeping all calibration history and manual correction.'
                : "Reset the sensor to its factory settings. This erases calibration data and settings.",
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        Button(
          disabled: resetSensorStatus.isInProgress || resetUnavailable != null,
          backgroundColor: AppColors.brandColorRed,
          onPressed: () {
            if (resetSensorStatus.isInProgress) return;

            ref
                .read(deviceSensorResetProvider(deviceId).notifier)
                .resetSensor();
          },
          child: resetSensorStatus.isInProgress
              ? const CupertinoActivityIndicator()
              : Text(isSlim ? 'Restart Sensor' : 'Reset Sensor'),
        ),
        if (isSlim) ...[
          const SizedBox(height: 16),
          SlimSettlingCard(deviceId: deviceId, showInactive: true),
          const SizedBox(height: 16),
          const Text('Erase sensor calibration',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const Text(
              'Recovery option: erase learned calibration and manual correction. Readings may be inaccurate while the sensor settles.'),
          const SizedBox(height: 16),
          Button(
              type: ButtonType.outlined,
              textColor: AppColors.brandColorRed,
              onPressed: resetSensorStatus.isInProgress ||
                      resetUnavailable != null
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                                  title:
                                      const Text('Erase sensor calibration?'),
                                  content: const Text(
                                      'This cannot be undone. Readings may be inaccurate while the sensor settles. Native auto-calibration and five-second mode will be enabled. Saved readings are kept.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                            'Erase sensor calibration'))
                                  ]));
                      if (confirmed == true && context.mounted) {
                        ref
                            .read(deviceSensorResetProvider(deviceId).notifier)
                            .resetSensor(eraseCalibration: true);
                      }
                    },
              label: 'Erase sensor calibration'),
        ],
      ],
    );
  }
}
