import 'dart:async';

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

  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(seconds: 5);

  // Trigger sync
  Future<void> syncData({String? targetDeviceId}) async {
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
      List<DeviceData> batch = [];

      batch = await _isarService.readAsync((isar) {
        return isar.deviceDatas
            .where()
            .syncedEqualTo(false)
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
