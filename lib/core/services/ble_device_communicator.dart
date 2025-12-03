import 'dart:async';

import 'package:airspothealth/core/services/ble_data_service.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleDeviceCommunicator {
  final String deviceId;
  BluetoothDevice get device => BluetoothDevice.fromId(deviceId);

  BluetoothCharacteristic? _writeCharacteristic;
  StreamSubscription<List<int>>? _notifySubscription;
  Completer<void>? _initCompleter;

  final StreamController<List<int>> _dataStreamController =
      StreamController.broadcast();
  Stream<List<int>> get dataStream => _dataStreamController.stream;

  BleDeviceCommunicator({required this.deviceId});

  Future<void> initialize() async {
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }
    _initCompleter = Completer<void>();

    for (var i = 0; i < 3; i++) {
      if (device.isDisconnected) {
        debugPrint(
            'Device not connected, cannot initialize communicator for $deviceId');
        break;
      }
      try {
        final services = await device.discoverServices();
        final service = services.firstWhereOrNull(
            (s) => s.uuid.toString().toUpperCase() == Constants.serviceUuid);
        if (service == null) {
          debugPrint('Service not found for $deviceId');
          break;
        }

        _writeCharacteristic = service.characteristics.firstWhereOrNull(
            (c) => c.uuid.toString().toUpperCase() == Constants.writeUuid);

        final notifyCharacteristic = service.characteristics.firstWhereOrNull(
            (c) => c.uuid.toString().toUpperCase() == Constants.notifyUuid);

        if (notifyCharacteristic != null) {
          if (device.isDisconnected) {
            break;
          }
          await notifyCharacteristic.setNotifyValue(true);
          _notifySubscription?.cancel();
          _notifySubscription =
              notifyCharacteristic.lastValueStream.listen((data) {
            _dataStreamController.add(data);
          });
          debugPrint('Subscribed to notifications for $deviceId');
        }
        _initCompleter?.complete();

        return; // Success
      } on PlatformException catch (e) {
        debugPrint('Error initializing communicator (attempt ${i + 1}): $e');
        if (e.message?.contains(Constants.serviceUuid.toLowerCase()) ?? false) {
          await Future.delayed(const Duration(seconds: 1));
          continue; // Retry
        }
        break;
      } catch (e) {
        debugPrint('Error initializing communicator for $deviceId: $e');
        break;
      }
    }

    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      _initCompleter!.complete();
    }
  }

  void reset() {
    _writeCharacteristic = null;
    _initCompleter = null;
    _notifySubscription?.cancel();
    _notifySubscription = null;
  }

  Future<bool> sendCommand(List<int> data) async {
    if (_writeCharacteristic == null) {
      await initialize();
      if (_writeCharacteristic == null) {
        debugPrint(
            'Write characteristic not found for $deviceId, cannot send command.');
        return false;
      }
    }

    if (device.isDisconnected) {
      debugPrint('Device $deviceId not connected, cannot send command');
      return false;
    }

    try {
      await _writeCharacteristic!.write(data);
      debugPrint(
          'Command sent to $deviceId: ${BleDataService.bytesToHexStr(data)}');
      return true;
    } catch (e) {
      debugPrint('Error sending command to $deviceId: $e');
      return false;
    }
  }

  void dispose() {
    _notifySubscription?.cancel();
    _dataStreamController.close();
  }
}
