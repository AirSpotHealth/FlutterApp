import 'dart:async';
import 'dart:io';

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

  bool _isSlimDevice = false;
  bool _initialized = false;

  /// True if this device exposed the MCUmgr SMP service during discovery.
  /// Set after [initialize] completes; used to select the correct DFU path.
  bool get isSlimDevice => _isSlimDevice;

  bool get isInitialized => _initialized;

  final StreamController<List<int>> _dataStreamController =
      StreamController.broadcast();
  Stream<List<int>> get dataStream => _dataStreamController.stream;

  BleDeviceCommunicator({required this.deviceId});

  /// Returns true when NUS write characteristic is ready for commands.
  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }
    if (_initCompleter != null) {
      await _initCompleter!.future;
      return _initialized;
    }
    _initCompleter = Completer<void>();

    const maxAttempts = 3;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (device.isDisconnected) {
        debugPrint(
            'Device not connected, cannot initialize communicator for $deviceId');
        break;
      }
      try {
        await _prepareConnectionForGatt();

        final services = await device.discoverServices(
          timeout: Constants.gattDiscoverTimeoutSeconds,
        );

        _logDiscoveredServices(services);

        _isSlimDevice =
            services.any((s) => s.uuid == Constants.smpServiceGuid);
        debugPrint('Device $deviceId isSlim=$_isSlimDevice');

        final service = services.firstWhereOrNull(
            (s) => s.uuid == Constants.nusServiceGuid);
        if (service == null) {
          debugPrint(
              'NUS service (${Constants.nusServiceGuid.str128}) not found for $deviceId');
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }

        _writeCharacteristic = service.characteristics.firstWhereOrNull(
            (c) => c.uuid == Constants.nusWriteGuid);

        final notifyCharacteristic = service.characteristics.firstWhereOrNull(
            (c) => c.uuid == Constants.nusNotifyGuid);

        if (_writeCharacteristic == null) {
          debugPrint('NUS write characteristic not found for $deviceId');
          continue;
        }

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

        _initialized = true;
        _initCompleter?.complete();
        return true;
      } on PlatformException catch (e) {
        debugPrint(
            'Error initializing communicator (attempt ${attempt + 1}): $e');
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        debugPrint(
            'Error initializing communicator for $deviceId (attempt ${attempt + 1}): $e');
        final isTimeout = e.toString().contains('Timed out') ||
            e.toString().contains('timeout');
        if (isTimeout && attempt < maxAttempts - 1) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        break;
      }
    }

    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      _initCompleter!.complete();
    }
    return false;
  }

  Future<void> _prepareConnectionForGatt() async {
    if (!Platform.isAndroid) {
      return;
    }
    // Brief settle time after connect (autoConnect cannot request MTU during connect).
    await Future.delayed(const Duration(milliseconds: 400));
    if (device.isDisconnected) {
      return;
    }
    try {
      final mtu = await device.requestMtu(512);
      debugPrint('Requested MTU for $deviceId: $mtu');
    } catch (e) {
      debugPrint('MTU request for $deviceId failed (non-fatal): $e');
    }
  }

  void _logDiscoveredServices(List<BluetoothService> services) {
    final uuids = services.map((s) => s.uuid.str128).join(', ');
    debugPrint('GATT services for $deviceId (${services.length}): $uuids');
  }

  void reset() {
    _writeCharacteristic = null;
    _initCompleter = null;
    _isSlimDevice = false;
    _initialized = false;
    _notifySubscription?.cancel();
    _notifySubscription = null;
  }

  Future<bool> sendCommand(List<int> data) async {
    if (_writeCharacteristic == null) {
      final ok = await initialize();
      if (!ok || _writeCharacteristic == null) {
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
