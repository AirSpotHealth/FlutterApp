import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/app_utils.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceValueWidget extends ConsumerWidget {
  const DeviceValueWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceValue = ref.watch(bleDeviceCommunicationProvider(deviceId));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "CO${Constants.subscript2} ",
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppUtils.getDataColorFromValue(deviceValue),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            deviceValue != null ? "$deviceValue ppm" : '------',
            key: ValueKey<String>(deviceValue?.toString() ?? '------'),
            style: context.textTheme.titleLarge?.copyWith(
              color: AppUtils.getDataColorFromValue(deviceValue),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
