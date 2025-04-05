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
          backgroundColor: AppColors.primaryColor,
          title: const Padding(
              padding: EdgeInsets.only(top: 12), child: AppLogo()),
          centerTitle: true,
          actions: [
            if (savedDevicesList.length > 3)
              GestureDetector(
                onTap: () => context.pushNamed(RouteNames.addDevice),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 20),
                    const SizedBox(width: 2),
                    const Text(
                      'Add Device',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    )
                  ],
                ),
              ),
            const SizedBox(width: 16),
          ],
        ),
        body: savedDevicesList.isEmpty
            ? const Center(child: Text('No devices connected'))
            : ListView.separated(
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemCount: savedDevicesList.length,
                padding: const EdgeInsets.all(16),
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) =>
                    BleDeviceWidget(bleDevice: savedDevicesList[index]),
              ),
        floatingActionButton: savedDevicesList.length < 4
            ? _buildAddDeviceButton(context)
            : null);
  }

  FloatingActionButton _buildAddDeviceButton(BuildContext context) =>
      FloatingActionButton.extended(
        label: const Text('Add Device'),
        icon: const Icon(Icons.add),
        onPressed: () => context.pushNamed(RouteNames.addDevice),
      );
}
