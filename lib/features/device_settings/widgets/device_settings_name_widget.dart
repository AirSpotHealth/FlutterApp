import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceSettingsNameWidget extends ConsumerWidget {
  const DeviceSettingsNameWidget(
      {required this.deviceId, this.suffixText, super.key});

  final String deviceId;

  final String? suffixText;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BleDevice device = ref.read(bleDeviceProvider(deviceId));
    return Text(
        '${device.alias ?? device.name} ${suffixText ?? t.deviceSettings.settings}');
  }
}
