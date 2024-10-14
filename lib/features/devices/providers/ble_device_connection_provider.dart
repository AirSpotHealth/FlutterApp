import 'dart:async';

import 'package:airspothealth/core/providers/ble_active_device_provider.dart';
import 'package:airspothealth/core/services/ble_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bleDeviceConnectionProvider = NotifierProvider.family<
    _BleDeviceConnectionNotifier,
    BluetoothBondState,
    String>(_BleDeviceConnectionNotifier.new);

class _BleDeviceConnectionNotifier
    extends FamilyNotifier<BluetoothBondState, String> {
  final BLEService _bleService = BLEService.instance;

  StreamSubscription<BluetoothConnectionState>? _deviceSubscription;

  @override
  BluetoothBondState build(String arg) {
    return BluetoothBondState.none;
  }

  void connect(BluetoothDevice device) {
    state = BluetoothBondState.bonding;

    _deviceSubscription = device.connectionState.listen((bState) {
      state = switch (bState) {
        BluetoothConnectionState.connected => BluetoothBondState.bonded,
        _ => BluetoothBondState.none,
      };

      if (bState == BluetoothConnectionState.connected) {
        _bleService.stopScan();
        ref.read(bleActiveDeviceProvider.notifier).setActiveDevice(device);
      }
    });

    device.cancelWhenDisconnected(
      _deviceSubscription!,
      delayed: true,
      next: true,
    );

    _bleService.connect(device);
  }

  Future<void> disconnect() async {
    await _bleService.disconnect();
  }
}
