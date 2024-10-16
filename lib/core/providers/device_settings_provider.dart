import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final deviceSettingsProvider =
    NotifierProvider.family<_DeviceSettingsNotifier, DeviceSettings, String>(
        _DeviceSettingsNotifier.new);

class _DeviceSettingsNotifier extends FamilyNotifier<DeviceSettings, String> {
  final IsarService _isarService = IsarService();

  @override
  DeviceSettings build(String arg) {
    final setting = _isarService.read<DeviceSettings?>((isar) {
      return isar.deviceSettings.where().deviceIdEqualTo(arg).findFirst();
    });

    if (setting == null) {
      return DeviceSettings.empty(deviceId: arg);
    }

    return setting;
  }

  void updateSettings(DeviceSettings settings) {
    // ref.read(bleDeviceCommunicationProvider(arg).notifier).writeData();

    _isarService.write((isar) {
      isar.deviceSettings.put(settings);
    });

    state = settings;
  }

  void removeSettings() {
    _isarService.write((isar) {
      isar.deviceSettings.delete(arg);
    });
  }
}
