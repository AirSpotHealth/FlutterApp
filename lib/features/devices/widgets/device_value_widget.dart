import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/app_utils.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/devices/providers/latest_device_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceValueWidget extends ConsumerWidget {
  const DeviceValueWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceValue = ref.watch(bleDeviceCommunicationProvider(deviceId));
    final latestData = ref.watch(latestDeviceDataProvider(deviceId));
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    // Use temperature and humidity from latest data if available
    final temperature = latestData?.temperature;
    final humidity = latestData?.humidity;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // CO2 - Primary value
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${Constants.co2Text} ",
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: deviceSettings.getValueColor(deviceValue),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                deviceValue != null
                    ? "${AppUtils.getDisplayCO2Value(deviceValue!)} ppm"
                    : '------',
                key: ValueKey<String>(deviceValue?.toString() ?? '------'),
                style: context.textTheme.titleLarge?.copyWith(
                  color: deviceSettings.getValueColor(deviceValue),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        // Temperature and Humidity - Secondary values
        if (temperature != null || humidity != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (temperature != null) ...[
                Text(
                  '${temperature.toStringAsFixed(1)}°C',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (humidity != null) ...[
                  Text(
                    ' • ',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
              if (humidity != null)
                Text(
                  '${humidity.toStringAsFixed(1)}%',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
