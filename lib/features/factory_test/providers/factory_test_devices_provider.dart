import 'package:airspothealth/core/services/ble_service.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FactoryTestDevicesState {
  final List<FactoryTestDevice> devices;
  final List<FactoryTestDevice> scannedDevices;
  final bool isScanning;
  final String? error;

  FactoryTestDevicesState({
    required this.devices,
    required this.scannedDevices,
    this.isScanning = false,
    this.error,
  });

  FactoryTestDevicesState copyWith({
    List<FactoryTestDevice>? devices,
    List<FactoryTestDevice>? scannedDevices,
    bool? isScanning,
    String? error,
  }) {
    return FactoryTestDevicesState(
      devices: devices ?? this.devices,
      scannedDevices: scannedDevices ?? this.scannedDevices,
      isScanning: isScanning ?? this.isScanning,
      error: error ?? this.error,
    );
  }
}

final factoryTestDevicesProvider = NotifierProvider.autoDispose<
    FactoryTestDevicesNotifier,
    FactoryTestDevicesState>(FactoryTestDevicesNotifier.new);

class FactoryTestDevicesNotifier
    extends AutoDisposeNotifier<FactoryTestDevicesState> {
  final BLEService _bleService = BLEService.instance;

  @override
  FactoryTestDevicesState build() {
    _bleService.startScan();

    FlutterBluePlus.isScanning.listen((isScanning) {
      state = state.copyWith(isScanning: isScanning);
    });

    return FactoryTestDevicesState(devices: [], scannedDevices: []);
  }

  /// Start device scanning
  void startScanning() {
    if (state.isScanning) return;
    final devices = state.devices;

    state = state.copyWith(
      isScanning: true,
      error: null, // Clear any previous errors
      devices: devices,
      scannedDevices: [],
    );

    _bleService.startScan();

    // Use scan results with ScanResult to get RSSI
    FlutterBluePlus.scanResults.listen(
      (scanResults) {
        final factoryTestDevices = scanResults
            .where((scanResult) =>
                scanResult.device.advName.startsWith('AirSpot-'))
            .map((scanResult) => FactoryTestDevice(
                  deviceId: scanResult.device.remoteId.str,
                  name: scanResult.device.advName,
                  rssi: scanResult.rssi,
                  bluetoothDevice: scanResult.device,
                ))
            .toList();

        // Sort by RSSI (strongest signal first)
        factoryTestDevices.sort((a, b) => b.rssi.compareTo(a.rssi));

        state = state.copyWith(
          scannedDevices: factoryTestDevices
              .where((device) =>
                  !state.devices.any((d) => d.deviceId == device.deviceId))
              .toList(),
        );
      },
      onError: (error) {
        debugPrint('Scan error: $error');
        state = state.copyWith(
          isScanning: false,
          error: 'Scan error: $error',
        );
      },
    );
  }

  /// Stop device scanning
  void stopScanning({bool clearDevices = false}) {
    if (!state.isScanning) return;

    _bleService.stopScan();

    state = state.copyWith(
      isScanning: false,
      devices: clearDevices ? [] : state.devices,
      scannedDevices: [],
    );
  }

  void addDevice(String deviceId) {
    final device = state.scannedDevices
        .firstWhereOrNull((device) => device.deviceId == deviceId);

    if (device == null) {
      return;
    }

    // Check if device is already added
    if (state.devices.any((d) => d.deviceId == deviceId)) {
      return;
    }

    state = state.copyWith(devices: [...state.devices, device]);

    ref
        .read(factoryTestProvider(deviceId).notifier)
        .connectToDeviceAndStartFactoryTest();
  }

  void removeDevice(String deviceId) {
    if (!state.devices.any((d) => d.deviceId == deviceId)) {
      return;
    }

    // Reset the factory test for this device
    ref.read(factoryTestProvider(deviceId).notifier).resetFactoryTest();

    state = state.copyWith(
      devices:
          state.devices.where((device) => device.deviceId != deviceId).toList(),
    );
  }
}
