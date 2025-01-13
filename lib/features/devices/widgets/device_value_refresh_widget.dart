import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceValueRefreshWidget extends ConsumerWidget {
  const DeviceValueRefreshWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        ref
            .read(bleDeviceCommunicationProvider(deviceId).notifier)
            .sendCommand(DeviceCmdUtils.refreshCO2());
      },
    );
  }
}
