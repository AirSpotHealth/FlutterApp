import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/features/find_my_device/widgets/my_device_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FindMyDevicePage extends ConsumerWidget {
  const FindMyDevicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(bleSavedDevicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find My Device'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return MyDeviceWidget(device: device);
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Tap on a device to find it. It will deliver a 5-second alarm to your Bluetooth-linked device.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
