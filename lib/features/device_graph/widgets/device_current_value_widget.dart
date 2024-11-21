import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceCurrentValueWidget extends ConsumerWidget {
  const DeviceCurrentValueWidget({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceValue = ref.watch(bleDeviceCommunicationProvider(deviceId));
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Text(
              'Current ${Constants.co2Text} Level: ',
              style: context.textTheme.bodyMedium?.weight600,
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                text: deviceValue != null ? "$deviceValue" : '0000',
                style: context.textTheme.titleLarge?.copyWith(
                  color: deviceSettings.getValueColor(deviceValue),
                  fontWeight: FontWeight.bold,
                ),
                children: const [
                  TextSpan(
                    text: '  ppm',
                    style: TextStyle(
                      color: AppColors.neutralGrey,
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
