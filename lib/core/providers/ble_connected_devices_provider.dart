import 'package:airspothealth/core/services/ble_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bleConnectedDevicesProvider =
    NotifierProvider<_BleConnectedDevicesNotifier, List<BluetoothDevice>>(
        _BleConnectedDevicesNotifier.new);

class _BleConnectedDevicesNotifier extends Notifier<List<BluetoothDevice>> {
  final BLEService _bleService = BLEService.instance;

  @override
  List<BluetoothDevice> build() => _bleService.connectedDevices();

  void refresh() {
    state = _bleService.connectedDevices();
  }
}
