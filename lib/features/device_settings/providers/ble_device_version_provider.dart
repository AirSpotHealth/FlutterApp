import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final bleDeviceVersionProvider =
    Provider.family.autoDispose<String?, String>((ref, deviceId) {
  return ref.read(isarServiceProvider).read((isar) {
    final device =
        isar.bleDevices.where().deviceIdEqualTo(deviceId).findFirst();

    return device?.firmwareVersion;
  });
});
