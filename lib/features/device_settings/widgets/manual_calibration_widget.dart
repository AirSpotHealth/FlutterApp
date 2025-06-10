import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/providers/recalibration_time_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/calibration_target_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManualCalibrationWidget extends ConsumerWidget {
  const ManualCalibrationWidget({
    required this.deviceId,
    required this.calibrationTarget,
    super.key,
  });

  final String deviceId;

  final int calibrationTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text('Manual Calibration',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: const Text(
              'To calibrate this AirSpot, place the device outdoors for at least 5 minutes, away from any people or CO2 sources, then tap the icon below. See full manual for details.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              ref
                  .read(recalibrationTimeProvider(deviceId).notifier)
                  .startRecalibration();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tap to start calibration',
                  style: context.textTheme.bodyMedium?.weight500,
                ),
                const SizedBox(height: 8),
                Image.asset(
                  Assets.recalibrateImage,
                  height: 80,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 12)
              ],
            ),
          ),
          const SizedBox(height: 16),
          CalibrationTargetWidget(
            deviceId: deviceId,
            calibrationTarget: calibrationTarget,
          ),
        ],
      ),
    );
  }
}
