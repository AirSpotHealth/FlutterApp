import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DeviceBatteryLevelWidget extends ConsumerWidget {
  const DeviceBatteryLevelWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? batteryLevel = ref.watch(
        deviceSettingsProvider(deviceId).select((value) => value.batteryLevel));

    if (batteryLevel == null) {
      return FaIcon(
        FontAwesomeIcons.batteryEmpty,
      );
    }

    if (batteryLevel > 75) {
      return FaIcon(
        FontAwesomeIcons.batteryFull,
        color: Colors.green,
      );
    }

    if (batteryLevel > 50) {
      return FaIcon(
        FontAwesomeIcons.batteryThreeQuarters,
        color: Colors.green,
      );
    }

    if (batteryLevel > 25) {
      return FaIcon(
        FontAwesomeIcons.batteryHalf,
        color: Colors.yellow,
      );
    }

    return FaIcon(
      FontAwesomeIcons.batteryQuarter,
      color: Colors.red,
    );
  }
}
