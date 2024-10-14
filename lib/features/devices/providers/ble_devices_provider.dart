import 'package:airspothealth/core/services/ble_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bleDevicesProvider =
    StreamProvider<List<BluetoothDevice>>((_) => BLEService.instance.devices);
