import 'dart:async';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:isar_plus/isar_plus.dart';

/// A service class related to Bluetooth.
/// This class provides methods to interact with Bluetooth.
/// This class is a singleton class. This class uses flutter_blue_plus package to interact with Bluetooth.
class BLEService {
  /// Private constructor to restrict the instantiation of this class.
  BLEService._();

  /// Singleton instance of this class.
  static final BLEService instance = BLEService._();

  // Keyed by remoteId — updated on every scan result batch.
  final Map<String, ScanResult> _scanResultCache = {};

  /// Returns the [DeviceModel] detected from advertisement data for [deviceId],
  /// A missing SMP UUID is inconclusive: resolve it using connected GATT services.
  DeviceModel? deviceModelFromScan(String deviceId) {
    final result = _scanResultCache[deviceId];
    if (result == null) return null;
    final hasSlimUuid = result.advertisementData.serviceUuids
        .any((uuid) => uuid == Constants.smpServiceGuid);
    return hasSlimUuid ? DeviceModel.airspotSlim : null;
  }

  /// Detects [DeviceModel] via GATT service discovery on an already-connected
  /// device. Use as a fallback when [deviceModelFromScan] returns null (e.g.,
  /// auto-reconnect with an empty scan cache).
  Future<DeviceModel> deviceModelFromGatt(BluetoothDevice device) async {
    final fromScan = deviceModelFromScan(device.remoteId.str);
    if (fromScan != null) {
      return fromScan;
    }

    final services = await device.discoverServices(
      timeout: Constants.gattDiscoverTimeoutSeconds,
    );
    final hasSlimService =
        services.any((s) => s.uuid == Constants.smpServiceGuid);
    return hasSlimService ? DeviceModel.airspotSlim : DeviceModel.airspotScreen;
  }

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

  /// Direct connection for user-initiated connect (faster than [connectBackground]).
  Future<void> connectDirect(BluetoothDevice device) async =>
      device.connect(license: License.nonprofit, autoConnect: false);

  /// Background reconnection when the app resumes or Bluetooth turns on.
  Future<void> connectBackground(BluetoothDevice device) async =>
      device.connect(license: License.nonprofit, autoConnect: true, mtu: null);

  @Deprecated('Use connectDirect or connectBackground')
  Future<void> connect(BluetoothDevice device) => connectDirect(device);

  /// Method to disconnect from a Bluetooth device.
  Future<void> disconnect(BluetoothDevice device) => device.disconnect();

  /// Get the stream of isScanning.
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  /// get is scanning now
  bool get isScanningNow => FlutterBluePlus.isScanningNow;

  /// Get the stream of Bluetooth devices.
  Stream<List<BluetoothDevice>> scanResults({bool distinct = true}) {
    if (!distinct) {
      return FlutterBluePlus.scanResults.map(
        (List<ScanResult> scanResults) {
          for (final r in scanResults) {
            _scanResultCache[r.device.remoteId.str] = r;
          }
          return scanResults.map((r) => r.device).toList();
        },
      );
    }

    final IsarService isarService = IsarService();

    final List<BleDevice> connectedDevices = isarService.read<List<BleDevice>>(
        (Isar isar) => isar.bleDevices.where().findAll());

    return FlutterBluePlus.scanResults.asyncMap(
      (List<ScanResult> scanResults) {
        for (final r in scanResults) {
          _scanResultCache[r.device.remoteId.str] = r;
        }
        return scanResults
            .map((r) => r.device)
            .where((BluetoothDevice bd) => !connectedDevices.any(
                (BleDevice bleDevice) => bleDevice.deviceId == bd.remoteId.str))
            .toList();
      },
    );
  }
}
