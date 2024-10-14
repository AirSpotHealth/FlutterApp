import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/app_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceValueWidget extends ConsumerWidget {
  const DeviceValueWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceValue = ref.watch(bleDeviceCommunicationProvider(deviceId));

    return Text(
      deviceValue != null ? "CO2 $deviceValue ppm" : 'N/A',
      style: context.textTheme.titleLarge?.copyWith(
        color: AppUtils.getDataColorFromValue(deviceValue),
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
