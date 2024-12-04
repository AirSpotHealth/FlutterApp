import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/utils/permission_utils.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
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
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          ref.read(bluetoothSearchResultsProvider.notifier).startScan();

          return Future.value();
        },
        child: ListView(
          children: [
            if (isScanning)
              const Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: CupertinoActivityIndicator(),
                ),
              ),
            if (devices.isEmpty && !isScanning)
              Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'No devices found, swipe down to refresh',
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: devices.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    BleNewDeviceItem(device: devices[index]),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: devices.length > 1 &&
              devices.every((dev) => !dev.isConnected)
          ? FloatingActionButton.extended(
              backgroundColor: Colors.blueGrey,
              label: const Text('Connect All'),
              onPressed: () {
                if (isScanning) {
                  ref.read(bluetoothSearchResultsProvider.notifier).stopScan();
                }

                _connectAllDevices(devices);
              },
              icon: const Icon(Icons.bluetooth_searching),
            )
          : null,
    );
  }

  void _connectAllDevices(List<BluetoothDevice> devices) {
    for (final device in devices) {
      ref
          .read(bleDeviceConnectionProvider(device.remoteId.str).notifier)
          .connect();
    }
  }
}
