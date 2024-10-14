import 'package:airspothealth/core/providers/ble_active_device_provider.dart';
import 'package:airspothealth/core/services/ble_service.dart';
import 'package:airspothealth/features/devices/providers/ble_devices_provider.dart';
import 'package:airspothealth/features/devices/widgets/ble_device_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage> {
  static const _permissionList = [
    Permission.locationWhenInUse,
    Permission.bluetoothConnect,
    Permission.bluetoothScan
  ];

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    _checkAndRequestPermissions();
    _checkPreviousConnections();
  }

  // Check and request permissions
  void _checkAndRequestPermissions() {
    _permissionList.request().then((statuses) {
      debugPrint('Permissions: $statuses');
      if (statuses.containsValue(PermissionStatus.denied)) {
        debugPrint('Permissions denied');
      }

      if (statuses.values
          .every((element) => element == PermissionStatus.granted)) {
        debugPrint('Permissions granted');
        BLEService.instance.enable().then((_) {
          BLEService.instance.startScan();
        });
      }
    });
  }

  void _checkPreviousConnections() {
    final connectedDevices =
        ref.read(bleActiveDeviceProvider.notifier).connectedDevices;

    debugPrint('Connected devices: $connectedDevices');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
      ),
      body: StreamBuilder<List<BluetoothDevice>>(
          stream: ref.read(bleDevicesProvider.stream),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (snapshot.data!.isEmpty) {
              return const Center(child: Text('No devices found'));
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (var device in snapshot.data!) _buildDevice(device),
              ],
            );
          }),
    );
  }

  Widget _buildDevice(BluetoothDevice device) => BleDeviceItem(device: device);
}
