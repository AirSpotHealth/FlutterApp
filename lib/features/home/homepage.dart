import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/providers/bluetooth_state_provider.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/widgets/airspot_bar.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/home/widgets/menu_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    _listenToBluetoothState();
    _connectToDevices();
    _setAppGroupId();
    super.initState();
  }

  void _setAppGroupId() => HomeWidget.setAppGroupId(Constants.appGroupId);

  void _connectToDevices() {
    final List<BleDevice> savedDevicesList = ref.read(bleSavedDevicesProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final device in savedDevicesList) {
        ref
            .read(bleDeviceConnectionProvider(device.deviceId).notifier)
            .connect();
      }
    });
  }

  void _listenToBluetoothState() => ref.read(bluetoothStateProvider);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AirspotBar(),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: MenuItems.items.length,
        itemBuilder: (context, index) =>
            MenuItemWidget(menuItem: MenuItems.items[index]),
      ),
    );
  }
}
