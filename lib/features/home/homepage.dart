import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/providers/bluetooth_state_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    _connectToDevices();
    _listenToBluetoothState();
    super.initState();
  }

  void _listenToBluetoothState() {
    ref.listenManual<BluetoothAdapterState>(
      bluetoothStateProvider,
      (oldState, newState) {
        debugPrint('BluetoothAdapterState: $newState');
        if (newState == BluetoothAdapterState.on &&
            oldState != BluetoothAdapterState.on) {
          _connectToDevices();
        }
      },
    );
  }

  void _connectToDevices() {
    final List<BleDevice> savedDevicesList = ref.read(bleSavedDevicesProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final device in savedDevicesList) {
        debugPrint('Connecting to device: ${device.name}');
        ref
            .read(bleDeviceConnectionProvider(device.deviceId).notifier)
            .connect(BluetoothDevice.fromId(device.deviceId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const AppLogo(),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            dense: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            tileColor: Colors.white,
            title:
                Text('Devices', style: context.textTheme.labelLarge?.weight600),
            subtitle: const Text('Manage your devices'),
            leading: Image.asset(Assets.icDevice, width: 24),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => context.pushNamed(RouteNames.devices),
          ),
        ],
      ),
    );
  }
}
