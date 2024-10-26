import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_graph/providers/device_historical_data_provider.dart';
import 'package:airspothealth/features/device_graph/widgets/data_graph_wrapper.dart';
import 'package:airspothealth/features/device_graph/widgets/device_current_value_widget.dart';
import 'package:airspothealth/features/device_graph/widgets/device_data_aggregate_card.dart';
import 'package:airspothealth/features/device_graph/widgets/history_range_selector.dart';
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
        title: const Text('Air Graph'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: AppColors.primaryColor,
            alignment: Alignment.center,
            child: const AppLogo(width: 100),
          ),
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    device.name,
                    style: context.textTheme.bodyMedium?.weight600,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Carbon dioxide',
                      style: context.textTheme.labelLarge?.weight600),
                ),
                const SizedBox(height: 6),
                DeviceCurrentValueWidget(deviceId: device.deviceId),
                const SizedBox(height: 16),
                DeviceDataAggregateCard(deviceId: device.deviceId),
                const SizedBox(height: 16),
                HistoryRangeSelector(
                  onRangeSelected: (value) => ref
                      .read(deviceHistoricalDataProvider(deviceId).notifier)
                      .setDuration(value),
                ),
                DataGraphWrapper(deviceId: device.deviceId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
