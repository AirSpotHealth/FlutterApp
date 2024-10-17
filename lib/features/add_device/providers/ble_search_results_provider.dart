import 'package:airspothealth/core/services/ble_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bluetoothSearchResultsProvider = NotifierProvider.autoDispose<
    _BleScanResultsNotifier,
    (bool, List<BluetoothDevice>)>(_BleScanResultsNotifier.new);

class _BleScanResultsNotifier
    extends AutoDisposeNotifier<(bool, List<BluetoothDevice>)> {
  final BLEService _bleService = BLEService.instance;

  get devices => state.$2;

  get isScanning => state.$1;

  @override
  (bool, List<BluetoothDevice>) build() {
    _bleService.scanResults.listen((event) {
      debugPrint('Scan results: $event');
      state = (isScanning, event);
    });

    _bleService.isScanning.listen((event) {
      debugPrint('Is scanning: $event');
      state = (event, devices);
    });

    return (false, <BluetoothDevice>[]);
  }

  void startScan() {
    if (isScanning) {
      return;
    }

    if (_bleService.isScanningNow) {
      return;
    }

    _bleService.startScan();
  }
}
