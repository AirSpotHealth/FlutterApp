import 'package:airspothealth/core/utils/permission_utils.dart';
import 'package:airspothealth/features/add_device/providers/ble_scan_results_provider.dart';
import 'package:airspothealth/features/add_device/widgets/ble_new_device_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddDevicePage extends ConsumerStatefulWidget {
  const AddDevicePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<AddDevicePage> {
  @override
  void initState() {
    PermissionUtils.requestPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Device'),
      ),
      body: StreamBuilder<List<BluetoothDevice>>(
          stream: ref.read(bleScanResultsProvider.stream),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (snapshot.data!.isEmpty) {
              return const Center(child: Text('No devices found'));
            }

            debugPrint('Devices found: ${snapshot.data!.length}');

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (var device in snapshot.data!) _buildDevice(device),
              ],
            );
          }),
    );
  }

  Widget _buildDevice(BluetoothDevice device) =>
      BleNewDeviceItem(device: device);
}
