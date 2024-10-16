import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/services/ble_service.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bluetoothStateProvider =
    NotifierProvider<_BluetoothStateNotifier, BluetoothAdapterState>(
        _BluetoothStateNotifier.new);

class _BluetoothStateNotifier extends Notifier<BluetoothAdapterState> {
  final BLEService _bleService = BLEService.instance;

  @override
  BluetoothAdapterState build() {
    _bleService.adapterState.listen((newState) {
      debugPrint('Bluetooth state: $newState');
      if (newState == BluetoothAdapterState.on &&
          state != BluetoothAdapterState.on) {
        debugPrint('Bluetooth is on');
        _connectToDevices();
      }

      state = newState;
    });

    return _bleService.adapterStateNow;
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
}
