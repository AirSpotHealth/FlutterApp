import 'package:airspothealth/core/services/ble_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bluetoothStateProvider =
    NotifierProvider<_BluetoothStateNotifier, BluetoothAdapterState>(
        _BluetoothStateNotifier.new);

class _BluetoothStateNotifier extends Notifier<BluetoothAdapterState> {
  final BLEService _bleService = BLEService.instance;

  @override
  BluetoothAdapterState build() {
    _bleService.adapterState.listen((state) {
      state = state;
    });

    return _bleService.adapterStateNow;
  }
}
