import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/features/airgraph/widgets/my_device_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AirgraphPage extends ConsumerWidget {
  const AirgraphPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<BleDevice> savedDevices = ref.watch(bleSavedDevicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AirGraph'),
      ),
      body: savedDevices.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No devices saved, please add a device and try again',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedDevices.length,
              itemBuilder: (context, index) =>
                  MyDeviceWidget(device: savedDevices[index]),
            ),
    );
  }
}
