import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/ble_connected_devices_provider.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/ble_data_utils.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final bleDeviceCommunicationProvider =
    NotifierProvider.family<_BleDeviceCommunicationNotifier, dynamic, String>(
  _BleDeviceCommunicationNotifier.new,
);

class _BleDeviceCommunicationNotifier extends FamilyNotifier<dynamic, String> {
  Stream<List<int>>? _notificationStream;

  BluetoothCharacteristic? _writeCharacteristic;

  final IsarService _isarService = IsarService();

  BluetoothDevice? get device => ref
      .read(bleConnectedDevicesProvider)
      .firstWhereOrNull((device) => device.remoteId.str == arg);

  @override
  dynamic build(String arg) {
    // check the last value of the device from the database
    final dynamic value = _isarService.read<dynamic>((isar) {
      final deviceData = isar.deviceDatas
          .where()
          .deviceIdEqualTo(arg)
          .sortByDateTimeDesc()
          .findFirst();

      return deviceData?.value;
    });

    // if the device is connected, start listening to notifications

    // if the device is connected, start listening to notifications
    if (device?.isConnected == true) {
      setConnected();
    }
    return value;
  }

  void setConnected() {
    _notificationStream = null;
    _writeCharacteristic = null;

    startListeningToNotifications();
  }

  void setDisconnected() {
    state = false;
    _notificationStream = null;
    _writeCharacteristic = null;
  }

  Future<void> startListeningToNotifications() async {
    if (device == null) {
      debugPrint('Device not found');
      return;
    }

    if (device!.isConnected == false) {
      debugPrint('Device not connected');
      return;
    }

    // Discover services and characteristics
    List<BluetoothService> services = await device!.discoverServices();

    // Find the service with the matching UUID
    final BluetoothService? service = services.firstWhereOrNull(
        (s) => s.uuid.toString().toUpperCase() == Constants.serviceUuid);

    if (service == null) {
      debugPrint('Service not found');
      return;
    }

    // Find the characteristics with the matching UUIDs
    final BluetoothCharacteristic? notifyCharacteristic =
        service.characteristics.firstWhereOrNull(
      (c) => c.uuid.toString().toUpperCase() == Constants.notifyUuid,
    );

    if (notifyCharacteristic == null) {
      debugPrint('Notify characteristic not found');
      return;
    }

    // Subscribe to notifications if the characteristic is found
    await notifyCharacteristic.setNotifyValue(true);
    _notificationStream = notifyCharacteristic.lastValueStream;

    _notificationStream!.listen((data) {
      debugPrint('Data received: $arg, ${BleDataUtils.bytesToHexStr(data)}');
      final value = BleDataUtils.parse(data);

      debugPrint('Parsed value: $value');
      state = value;
      _isarService.write((isar) {
        isar.deviceDatas.put(DeviceData(
          deviceId: device!.remoteId.str,
          value: value,
          dateTime: DateTime.now(),
        ));
      });

      state = BleDataUtils.parse(data);
    });

    final BluetoothCharacteristic? writeCharacteristic =
        service.characteristics.firstWhereOrNull(
      (c) =>
          c.uuid.toString().toUpperCase() == Constants.writeUuid.toUpperCase(),
    );

    // Set the write characteristic if found
    _writeCharacteristic = writeCharacteristic;
  }

  // Write data to the BLE device
  Future<bool> sendCommand(List<int> data) async {
    try {
      await _write(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _write(List<int> data) async {
    if (device == null) {
      debugPrint('Device not found');
      return;
    }

    if (device!.isConnected == false) {
      debugPrint('Device not connected');
      return;
    }

    if (_writeCharacteristic == null) {
      debugPrint('Write characteristic not found');
      return;
    }

    await _writeCharacteristic!.write(data);
  }
}
