import 'dart:async';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_connected_devices_provider.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/services/ble_service.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
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
    debugPrint('bleDeviceConnectionProvider build $arg');
    return _bleService
                .connectedDevices()
                .firstWhereOrNull((device) => device.remoteId.str == arg)
                ?.isConnected ==
            true
        ? BluetoothBondState.bonded
        : BluetoothBondState.none;
  }

  void connect(BluetoothDevice device) {
    state = BluetoothBondState.bonding;

    debugPrint('Connecting to device: ${device.advName}');

    _deviceSubscription = device.connectionState.listen((bState) {
      debugPrint('Device connection state: $bState');

      state = switch (bState) {
        BluetoothConnectionState.connected => BluetoothBondState.bonded,
        _ => BluetoothBondState.none,
      };

      if (bState == BluetoothConnectionState.connected) {
        ref.read(bleConnectedDevicesProvider.notifier).refresh();
        ref.read(bleSavedDevicesProvider.notifier).addDevice(BleDevice(
              deviceId: device.remoteId.str,
              name: device.advName,
              platform: device.platformName,
              address: device.remoteId.str,
            ));
      }

      if (bState == BluetoothConnectionState.disconnected) {
        state = BluetoothBondState.none;
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
