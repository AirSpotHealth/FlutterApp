import 'dart:async';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:isar/isar.dart';

/// A service class related to Bluetooth.
/// This class provides methods to interact with Bluetooth.
/// This class is a singleton class. This class uses flutter_blue_plus package to interact with Bluetooth.
class BLEService {
  /// Private constructor to restrict the instantiation of this class.
  BLEService._();

  /// Singleton instance of this class.
  static final BLEService instance = BLEService._();

  /// Method to check if Bluetooth is available on the device.
  Future<bool> isAvailable() async => FlutterBluePlus.isSupported;

  /// Method to check if Bluetooth is enabled on the device.
  BluetoothAdapterState get adapterStateNow => FlutterBluePlus.adapterStateNow;

  /// Method to enable Bluetooth on the device.
  Future<void> enable() async {
    // handle bluetooth on & off
    final adapterState = FlutterBluePlus.adapterStateNow;
    if (adapterState == BluetoothAdapterState.off) {
      await FlutterBluePlus.turnOn();
    }
  }

  /// Bluetooth adapter state listener.
  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  /// Method to start scanning for Bluetooth devices.
  void startScan() => FlutterBluePlus.startScan(
        withKeywords: [
          'AirSpot-',
        ],
        androidUsesFineLocation: true,
        timeout: const Duration(seconds: 10),
      );

  /// Method to stop scanning for Bluetooth devices.
  Future<void> stopScan() async => FlutterBluePlus.stopScan();

  /// Method to get the list of connected devices.
  List<BluetoothDevice> connectedDevices() => FlutterBluePlus.connectedDevices;

  /// Bonded devices getter.
  Future<List<BluetoothDevice>> get bondedDevices =>
      FlutterBluePlus.bondedDevices;

  /// Method to connect to a Bluetooth device.
  Future<void> connect(BluetoothDevice device) async =>
      device.connect(autoConnect: true, mtu: null);

  /// Method to disconnect from a Bluetooth device.
  Future<void> disconnect(BluetoothDevice device) async => device.disconnect();

  /// Get the stream of isScanning.
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  /// get is scanning now
  bool get isScanningNow => FlutterBluePlus.isScanningNow;

  /// Get the stream of Bluetooth devices.
  Stream<List<BluetoothDevice>> scanResults({bool distinct = true}) {
    if (!distinct) {
      return FlutterBluePlus.scanResults.map(
        (List<ScanResult> scanResults) => scanResults
            .map((ScanResult scanResult) => scanResult.device)
            .toList(),
      );
    }

    final IsarService isarService = IsarService();

    final List<BleDevice> connectedDevices = isarService.read<List<BleDevice>>(
        (Isar isar) => isar.bleDevices.where().findAll());

    return FlutterBluePlus.scanResults.asyncMap(
      (List<ScanResult> scanResults) => scanResults
          .map((ScanResult scanResult) => scanResult.device)
          .where((BluetoothDevice bd) => !connectedDevices.any(
              (BleDevice bleDevice) => bleDevice.deviceId == bd.remoteId.str))
          .toList(),
    );
  }
}
