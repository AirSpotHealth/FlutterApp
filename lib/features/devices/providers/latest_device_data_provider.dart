import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

/// Provider that returns the latest DeviceData entry for a device
/// This includes CO2, temperature, and humidity when available
final latestDeviceDataProvider =
    Provider.family<DeviceData?, String>((ref, deviceId) {
  return ref.read(isarServiceProvider).read<DeviceData?>((isar) {
    final latestData = isar.deviceDatas
        .where()
        .deviceIdEqualTo(deviceId)
        .typeEqualTo(DeviceDataType.co2.index)
        .sortByDateTimeDesc()
        .findFirst();
    return latestData;
  });
});
