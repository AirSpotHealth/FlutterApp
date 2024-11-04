import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/utils/app_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyDeviceWidget extends ConsumerWidget {
  const MyDeviceWidget({required this.device, super.key});

  final BleDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamic value =
        ref.watch(bleDeviceCommunicationProvider(device.deviceId));

    return ListTile(
      onTap: () {
        context.pushNamed(
          RouteNames.deviceGraph,
          pathParameters: {'deviceId': device.deviceId},
        );
      },
      title: Text(
        "${device.name}${device.alias != null ? '(${device.alias})' : ''}",
        textAlign: TextAlign.start,
      ),
      titleTextStyle: context.textTheme.bodyLarge?.weight600,
      subtitle: Text(device.deviceId),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      trailing: Text(
        '$value ppm',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppUtils.getDataColorFromValue(value),
        ),
      ),
    );
  }
}
