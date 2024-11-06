import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_graph/widgets/data_graph_wrapper.dart';
import 'package:airspothealth/features/device_graph/widgets/device_current_value_widget.dart';
import 'package:airspothealth/features/device_graph/widgets/device_data_aggregate_card.dart';
import 'package:airspothealth/features/device_graph/widgets/graph_settings_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceGraphPage extends ConsumerWidget {
  const DeviceGraphPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BleDevice device = ref.read(bleDeviceProvider(deviceId));

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(width: 100),
        actions: const [
          GraphSettingsWidget(),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: Text(
              device.alias ?? device.name,
              style: context.textTheme.bodyMedium?.weight600,
            ),
          ),
          const SizedBox(height: 12),
          DeviceCurrentValueWidget(deviceId: device.deviceId),
          const SizedBox(height: 12),
          DeviceDataAggregateCard(deviceId: device.deviceId),
          const SizedBox(height: 12),
          Flexible(child: DataGraphWrapper(deviceId: device.deviceId)),
        ],
      ),
    );
  }
}
