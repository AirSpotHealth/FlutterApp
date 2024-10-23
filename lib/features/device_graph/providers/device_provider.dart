import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bleDeviceProvider = Provider.family<BleDevice, String>((ref, deviceId) {
  return ref
      .read(bleSavedDevicesProvider)
      .firstWhere((device) => device.deviceId == deviceId);
});
