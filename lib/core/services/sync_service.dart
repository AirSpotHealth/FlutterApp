import 'package:airspothealth/core/services/cloud_device_identity.dart';
import 'package:airspothealth/core/services/cloud_sync_access.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:isar_plus/isar_plus.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final IsarService _isarService = IsarService();
  final SupabaseService _supabaseService = SupabaseService();
  final Set<String> _activeDevices = {};

  // Trigger sync
  Future<void> syncData(
      {required String targetDeviceId, required String sourceDeviceId}) async {
    requireUniqueCloudIdentity(targetDeviceId);
    CloudSyncAccess.requireEnabled();
    if (_supabaseService.currentUser == null) return;

    if (!_activeDevices.add(sourceDeviceId)) {
      throw StateError('This device is already syncing.');
    }
    debugPrint('Starting Cloud Sync...');

    try {
      await _uploadUnsyncedData(
          targetDeviceId: targetDeviceId, sourceDeviceId: sourceDeviceId);
    } catch (e) {
      debugPrint('Sync failed: $e');
      rethrow; // Rethrow to let the caller know it failed
    } finally {
      _activeDevices.remove(sourceDeviceId);
      debugPrint('Cloud Sync finished.');
    }
  }

  /// Immediately upload a single reading (for real-time dashboard updates)
  Future<void> uploadImmediateReading(DeviceData reading,
      {required String targetDeviceId}) async {
    if (!CloudSyncAccess.enabled) return;
    // Basic checks
    if (_supabaseService.currentUser == null) return;

    try {
      requireUniqueCloudIdentity(targetDeviceId);
      // 1. Upload to Supabase
      await _supabaseService
          .uploadReadings([reading], targetDeviceId: targetDeviceId);

      // 2. Mark as synced locally
      // We need to re-read the object from Isar to ensure we have the latest version/id if needed,
      // but since we just saved it in the provider, we can likely just update it.
      // However, to be safe and use Isar correctly:
      await _isarService.writeAsync((isar) {
        // We find the specific record by deviceId + timestamp + type
        // Or if we have the ID, use that. DeviceData has an ID.
        // But the reading passed in might not have the ID set if it was just created?
        // Wait, DeviceData in the provider was just saved.
        // Let's look at how it's saved in provider.
        // It calls isar.deviceDatas.put(co2Data).
        // So the object passed here should be the one we want to update.
        // Let's query it by composite key to be sure.
        final readingToUpdate = isar.deviceDatas
            .where()
            .deviceIdEqualTo(reading.deviceId)
            .dateTimeEqualTo(reading.dateTime)
            .typeEqualTo(reading.type)
            .findFirst();

        if (readingToUpdate != null) {
          readingToUpdate.synced = true;
          isar.deviceDatas.put(readingToUpdate);
        }
      });

      debugPrint(
          'Real-time upload success for ${reading.deviceId} at ${reading.dateTime}');
    } catch (e) {
      // If it fails, we just log it. The background sync will pick it up later.
      debugPrint('Real-time upload failed (will retry in background): $e');
    }
  }

  Future<void> _uploadUnsyncedData(
      {required String targetDeviceId, required String sourceDeviceId}) async {
    // 1. Get unsynced data from Isar
    // We need to query for synced == false.
    // Note: We need to update DeviceData model first to include 'synced' field.
    // Assuming the field exists and is indexed.

    const int batchSize = 500;
    bool hasMore = true;

    while (hasMore) {
      CloudSyncAccess.requireEnabled();
      List<DeviceData> batch = [];

      batch = await _isarService.readAsync((isar) {
        return pendingReadings(isar,
            sourceDeviceId: sourceDeviceId,
            now: DateTime.now(),
            limit: batchSize);
      });

      if (batch.isEmpty) {
        hasMore = false;
        break;
      }

      // 2. Upload to Supabase
      try {
        await _supabaseService.uploadReadings(batch,
            targetDeviceId: targetDeviceId);

        // 3. Mark as synced locally
        await _isarService.writeAsync((isar) {
          for (var item in batch) {
            item.synced = true;
            isar.deviceDatas.put(item);
          }
        });

        debugPrint('Synced batch of ${batch.length} records.');
      } catch (e) {
        debugPrint('Failed to upload batch: $e');
        rethrow; // Preserve unsynced records and report failure to the caller.
      }
    }
  }

  /// Select only this physical device's history before mapping to a cloud ID.
  static List<DeviceData> pendingReadings(
    Isar isar, {
    required String sourceDeviceId,
    required DateTime now,
    int limit = 500,
  }) =>
      isar.deviceDatas
          .where()
          .deviceIdEqualTo(sourceDeviceId)
          .syncedEqualTo(false)
          .isLiveCo2EqualTo(false)
          .dateTimeBetween(
              DateTime(2024, 1, 1), now.add(const Duration(days: 1)))
          .findAll(limit: limit);

  Future<DateTime?> getLastSyncedDate(String deviceId) async {
    return _supabaseService.getLastSyncedDate(deviceId);
  }
}
