import 'package:airspothealth/core/services/ble_device_communicator.dart';

class BleCommunicatorService {
  BleCommunicatorService._();
  static final instance = BleCommunicatorService._();

  final _communicators = <String, BleDeviceCommunicator>{};

  BleDeviceCommunicator communicator(String deviceId) {
    return _communicators.putIfAbsent(
        deviceId, () => BleDeviceCommunicator(deviceId: deviceId));
  }

  void disposeCommunicator(String deviceId) {
    _communicators[deviceId]?.dispose();
    _communicators.remove(deviceId);
  }

  void disposeAll() {
    for (final communicator in _communicators.values) {
      communicator.dispose();
    }
    _communicators.clear();
  }
}
