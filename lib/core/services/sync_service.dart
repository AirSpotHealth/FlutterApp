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
  bool _isSyncing = false;

  // Trigger sync
  Future<void> syncData({String? targetDeviceId}) async {
    CloudSyncAccess.requireEnabled();
    if (_supabaseService.currentUser == null) return;

    if (_isSyncing) {
      debugPrint('Sync already in progress.');
      return;
    }

    _isSyncing = true;
    debugPrint('Starting Cloud Sync...');

    try {
      await _uploadUnsyncedData(targetDeviceId: targetDeviceId);
    } catch (e) {
      debugPrint('Sync failed: $e');
      rethrow; // Rethrow to let the caller know it failed
    } finally {
      _isSyncing = false;
      debugPrint('Cloud Sync finished.');
    }
  }

  /// Immediately upload a single reading (for real-time dashboard updates)
  Future<void> uploadImmediateReading(DeviceData reading,
      {String? targetDeviceId}) async {
    if (!CloudSyncAccess.enabled) return;
    // Basic checks
    if (_supabaseService.currentUser == null) return;

    try {
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

  Future<void> _uploadUnsyncedData({String? targetDeviceId}) async {
    // 1. Get unsynced data from Isar
    // We need to query for synced == false.
    // Note: We need to update DeviceData model first to include 'synced' field.
    // Assuming the field exists and is indexed.

    const int batchSize = 500;
    bool hasMore = true;

    // Safety check for timestamps (Year >= 2024)
    final minDate = DateTime(2024, 1, 1);

    while (hasMore) {
      CloudSyncAccess.requireEnabled();
      List<DeviceData> batch = [];

      batch = await _isarService.readAsync((isar) {
        return isar.deviceDatas
            .where()
            .syncedEqualTo(false)
            .isLiveCo2EqualTo(false)
            .dateTimeBetween(
                minDate, DateTime.now().add(const Duration(days: 1)))
            .findAll(limit: batchSize);
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
        // Stop on error to retry later
        hasMore = false;
      }
    }
  }

  Future<DateTime?> getLastSyncedDate(String deviceId) async {
    return _supabaseService.getLastSyncedDate(deviceId);
  }
}
