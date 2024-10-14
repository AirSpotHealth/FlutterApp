import 'package:airspothealth/core/providers/ble_active_device_value_provider.dart';
import 'package:airspothealth/core/services/ble_service.dart';
import 'package:airspothealth/core/utils/ble_data_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bleActiveDeviceProvider =
    NotifierProvider<_BleActiveDeviceNotifier, BluetoothDevice?>(
  _BleActiveDeviceNotifier.new,
);

class _BleActiveDeviceNotifier extends Notifier<BluetoothDevice?> {
  final BLEService _bleService = BLEService.instance;
  Stream<List<int>>? _notificationStream;

  // UUIDs for the service and characteristics
  final String _serviceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  final String _notifyUuid = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
  final String _writeUuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";

  BluetoothCharacteristic? _writeCharacteristic;

  @override
  BluetoothDevice? build() {
    if (connectedDevices.isNotEmpty) {
      return connectedDevices.first;
    }
    return null;
  }

  List<BluetoothDevice> get connectedDevices => _bleService.connectedDevices;

  void setActiveDevice(BluetoothDevice device) {
    state = device;
    _notificationStream = null;
    _writeCharacteristic = null;

    startListeningToNotifications();
  }

  void clearActiveDevice() {
    state = null;
    _notificationStream = null;
    _writeCharacteristic = null;
  }

  Future<void> startListeningToNotifications() async {
    if (state == null) {
      debugPrint('Device not available');
      return;
    }

    final device = state!;

    // Cache UUIDs in uppercase
    final serviceUuidUpper = _serviceUuid.toUpperCase();
    final notifyUuidUpper = _notifyUuid.toUpperCase();
    final writeUuidUpper = _writeUuid.toUpperCase();

    // Discover services and characteristics
    List<BluetoothService> services = await device.discoverServices();

    // Find the service with the matching UUID
    final BluetoothService? service = services.firstWhereOrNull(
        (s) => s.uuid.toString().toUpperCase() == serviceUuidUpper);

    if (service == null) {
      debugPrint('Service not found');
      return;
    }

    // Find the characteristics with the matching UUIDs
    final BluetoothCharacteristic? notifyCharacteristic =
        service.characteristics.firstWhereOrNull(
      (c) => c.uuid.toString().toUpperCase() == notifyUuidUpper,
    );

    if (notifyCharacteristic == null) {
      debugPrint('Notify characteristic not found');
      return;
    }

    // Subscribe to notifications if the characteristic is found
    await notifyCharacteristic.setNotifyValue(true);
    _notificationStream = notifyCharacteristic.lastValueStream;

    final BluetoothCharacteristic? writeCharacteristic =
        service.characteristics.firstWhereOrNull(
      (c) => c.uuid.toString().toUpperCase() == writeUuidUpper,
    );

    // Set the write characteristic if found
    _writeCharacteristic = writeCharacteristic;

    ref.read(bleActiveDeviceValueProvider.notifier).build();
  }

  // Expose the notification stream to the rest of the app
  Stream<dynamic>? get notificationStream => _notificationStream?.map(
        (event) => BleDataUtils.parse(event),
      );

  // Write data to the BLE device
  Future<void> writeData(List<int> data) async {
    if (_writeCharacteristic != null) {
      await _writeCharacteristic!.write(data);
      debugPrint('Data written: $data');
    } else {
      debugPrint('Write characteristic not available');
    }
  }
}
