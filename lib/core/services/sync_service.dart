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

  // Trigger sync
  Future<void> syncData() async {
    if (_isSyncing) return;
    if (_supabaseService.currentUser == null) return;

    _isSyncing = true;
    debugPrint('Starting Cloud Sync...');

    try {
      await _uploadUnsyncedData();
    } catch (e) {
      debugPrint('Sync failed: $e');
    } finally {
      _isSyncing = false;
      debugPrint('Cloud Sync finished.');
    }
  }

  Future<void> _uploadUnsyncedData() async {
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

      await _isarService.readAsync((isar) async {
        batch = isar.deviceDatas
            .where()
            .syncedEqualTo(false)
            .dateTimeGreaterThan(minDate)
            .findAll(limit: batchSize);
      });

      if (batch.isEmpty) {
        hasMore = false;
        break;
      }

      // 2. Upload to Supabase
      try {
        await _supabaseService.uploadReadings(batch);

        // 3. Mark as synced locally
        await _isarService.writeAsync((isar) async {
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
}
