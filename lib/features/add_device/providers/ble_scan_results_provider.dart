import 'package:airspothealth/core/services/ble_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bleScanResultsProvider =
    StreamProvider.autoDispose<List<BluetoothDevice>>(
        (_) => BLEService.instance.scanResults);
