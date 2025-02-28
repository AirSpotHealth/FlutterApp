import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceGraphModeWidget extends ConsumerWidget {
  const DeviceGraphModeWidget({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSettings = ref.watch(deviceSettingsProvider(deviceId));

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Graph Mode',
                style: context.textTheme.bodyMedium?.weight600,
              ),
            ),
            Switch(
              value: deviceSettings.graphMode,
              onChanged: (value) => ref
                  .read(deviceSettingsProvider(deviceId).notifier)
                  .updateSettings(deviceSettings.copyWith(graphMode: value)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Graph mode will display a bar graph of the last 28 ${Constants.co2Text} readings on the device. The top of the graph represents 4,000ppm.',
          style: context.textTheme.bodySmall?.weight500?.copyWith(
            color: context.textTheme.bodySmall?.color?.withValues(alpha: .7),
          ),
        ),
      ],
    );
  }
}
