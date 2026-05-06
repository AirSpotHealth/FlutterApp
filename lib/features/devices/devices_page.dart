import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/features/devices/widgets/ble_device_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DevicesPage extends ConsumerWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BleDevice> savedDevicesList = ref.watch(bleSavedDevicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(),
        actions: [
          if (savedDevicesList.length > 3)
            TextButton.icon(
              onPressed: () => context.pushNamed(RouteNames.addDevice),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Device'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: savedDevicesList.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bluetooth_searching,
                      size: 64, color: AppColors.textDisabled),
                  const SizedBox(height: 16),
                  Text('No devices yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Tap Add Device to get started',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView.separated(
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
              itemCount: savedDevicesList.length,
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) =>
                  BleDeviceWidget(bleDevice: savedDevicesList[index]),
            ),
      floatingActionButton: savedDevicesList.length < 4
          ? FloatingActionButton.extended(
              label: const Text('Add Device'),
              icon: const Icon(Icons.add),
              onPressed: () => context.pushNamed(RouteNames.addDevice),
            )
          : null,
    );
  }
}
