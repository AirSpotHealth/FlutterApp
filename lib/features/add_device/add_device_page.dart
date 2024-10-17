import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/utils/permission_utils.dart';
import 'package:airspothealth/features/add_device/providers/ble_search_results_provider.dart';
import 'package:airspothealth/features/add_device/widgets/ble_new_device_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddDevicePage extends ConsumerStatefulWidget {
  const AddDevicePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends ConsumerState<AddDevicePage> {
  @override
  void initState() {
    super.initState();
    PermissionUtils.requestPermissions().then((granted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!granted) {
          context.showSnackBar(
              'Our app needs location and bluetooth permission to scan for devices');
          return;
        }
        ref.read(bluetoothSearchResultsProvider.notifier).startScan();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final (bool isScanning, List<BluetoothDevice> devices) =
        ref.watch(bluetoothSearchResultsProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Device'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isScanning)
              const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CupertinoActivityIndicator())),
            devices.isEmpty
                ? const Align(
                    alignment: Alignment.center,
                    child: Text('No devices found'))
                : Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (var device in devices) _buildDevice(device),
                      ],
                    ),
                  ),
          ],
        ));
  }

  Widget _buildDevice(BluetoothDevice device) =>
      BleNewDeviceItem(device: device);
}
