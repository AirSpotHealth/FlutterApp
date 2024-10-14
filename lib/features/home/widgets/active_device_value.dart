import 'package:airspothealth/core/providers/ble_active_device_value_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveDeviceValueWidget extends ConsumerWidget {
  const ActiveDeviceValueWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamic value = ref.watch(bleActiveDeviceValueProvider);

    return Text(
      value != null ? value.toString() : 'N/A',
      style: context.textTheme.titleLarge?.weight700,
    );
  }
}
