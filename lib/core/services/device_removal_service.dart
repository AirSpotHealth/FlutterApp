import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/models/history_coverage.dart';
import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/models/ventilation_event.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:isar_plus/isar_plus.dart';

/// Purges only the device the user chose to forget. Large histories are deleted
/// in bounded transactions to reduce peak copy-on-write working space.
class DeviceRemovalService {
  DeviceRemovalService(this.database);
  final IsarService database;
  static const batchSize = 256;

  Future<void> remove(String deviceId) async {
    await _deleteBatches((isar) => isar.deviceDatas
        .where()
        .deviceIdEqualTo(deviceId)
        .deleteAll(limit: batchSize));
    await _deleteBatches((isar) => isar.ventilationEvents
        .where()
        .deviceIdEqualTo(deviceId)
        .deleteAll(limit: batchSize));
    await _deleteBatches((isar) => isar.historyCoverages
        .where()
        .deviceIdEqualTo(deviceId)
        .deleteAll(limit: batchSize));
    // Keep the saved device until the purge finishes. An interrupted purge can
    // be retried; don't claim the history is intact after partial progress.
    database.write((isar) {
      isar.deviceSettings.where().deviceIdEqualTo(deviceId).deleteAll();
      isar.notificationPreferences.delete(deviceId);
      isar.bleDevices.delete(deviceId);
    });
  }

  Future<void> _deleteBatches(int Function(Isar) removeBatch) async {
    while (true) {
      var deleted = 0;
      database.write((isar) {
        deleted = removeBatch(isar);
      });
      if (deleted < batchSize) return;
      // Keep the interface responsive while clearing a large device history.
      await Future<void>.delayed(Duration.zero);
    }
  }
}
