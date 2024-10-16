import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/widgets/airspot_bar.dart';
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
      appBar: const AirspotBar(),
      body: savedDevicesList.isEmpty
          ? const Center(child: Text('No devices connected'))
          : ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: savedDevicesList.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) =>
                  BleDeviceWidget(bleDevice: savedDevicesList[index]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Add Device'),
        icon: const Icon(Icons.add),
        onPressed: () => context.pushNamed(RouteNames.addDevice),
      ),
    );
  }
}
