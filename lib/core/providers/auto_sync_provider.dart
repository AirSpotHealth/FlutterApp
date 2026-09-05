import 'package:airspothealth/core/services/cloud_sync_access.dart';
import 'dart:async';

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/auto_sync_preference_provider.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/supabase_service.dart';
import 'package:airspothealth/core/services/sync_service.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

/// Per-device sync status shown on device cards and the sync page.
enum SyncStatus { idle, syncing, success, error }

class DeviceSyncState {
  final SyncStatus status;
  final DateTime? lastSyncTime;
  final int unsyncedCount;
  final String? errorMessage;

  const DeviceSyncState({
    this.status = SyncStatus.idle,
    this.lastSyncTime,
    this.unsyncedCount = 0,
    this.errorMessage,
  });

  DeviceSyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncTime,
    int? unsyncedCount,
    String? errorMessage,
  }) {
    return DeviceSyncState(
      status: status ?? this.status,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      unsyncedCount: unsyncedCount ?? this.unsyncedCount,
      errorMessage: errorMessage,
    );
  }
}

/// Global auto-sync state — holds per-device sync states.
class AutoSyncState {
  final Map<String, DeviceSyncState> deviceStates;

  const AutoSyncState({this.deviceStates = const {}});

  DeviceSyncState getDeviceState(String serialNumber) {
    return deviceStates[serialNumber] ?? const DeviceSyncState();
  }

  AutoSyncState copyWithDevice(
      String serialNumber, DeviceSyncState deviceState) {
    return AutoSyncState(
      deviceStates: {...deviceStates, serialNumber: deviceState},
    );
  }
}

/// Global provider for auto-sync. Lives for the lifetime of the app.
final autoSyncProvider =
    NotifierProvider<AutoSyncNotifier, AutoSyncState>(AutoSyncNotifier.new);

class AutoSyncNotifier extends Notifier<AutoSyncState> {
  final SupabaseService _supabaseService = SupabaseService();
  final SyncService _syncService = SyncService();
  final IsarService _isarService = IsarService();

  /// Cooldown timers per device to avoid hammering the API.
  final Map<String, Timer?> _debounceTimers = {};

  /// Track which devices are currently syncing.
  final Set<String> _activeSyncs = {};

  /// Cooldown duration between syncs per device.
  static const _syncCooldown = Duration(seconds: 30);

  @override
  AutoSyncState build() {
    return const AutoSyncState();
  }

  /// Called after new data is saved to Isar.
  /// [serialNumber] is the hardware serial number (cloud device_id).
  /// [deviceName] is the BLE advertised name.
  /// [deviceAlias] is the user-defined alias.
  void triggerSync({
    required String serialNumber,
    String? deviceName,
    String? deviceAlias,
  }) {
    // Gate checks
    if (_supabaseService.currentUser == null) return;
    if (!CloudSyncAccess.enabled) return;
    if (!ref.read(autoSyncPreferenceProvider)) return; // User toggle
    if (_activeSyncs.contains(serialNumber)) return;

    // Debounce: cancel existing timer and start a new one
    _debounceTimers[serialNumber]?.cancel();
    _debounceTimers[serialNumber] = Timer(_syncCooldown, () {
      if (!CloudSyncAccess.enabled || !ref.read(autoSyncPreferenceProvider)) {
        return;
      }
      _performSync(
        serialNumber: serialNumber,
        deviceName: deviceName,
        deviceAlias: deviceAlias,
      );
    });

    debugPrint(
        'AutoSync: Scheduled sync for $serialNumber in ${_syncCooldown.inSeconds}s');
  }

  /// Immediately sync a device (used by manual "Sync Now" button).
  /// When [bleDeviceId] is provided, fetches history from the BLE device
  /// day by day before uploading, to get stored data off the device.
  Future<void> syncNow({
    required String serialNumber,
    String? deviceName,
    String? deviceAlias,
    String? bleDeviceId,
    int numDays = 7,
  }) async {
    _debounceTimers[serialNumber]?.cancel();
    await _performSync(
      serialNumber: serialNumber,
      deviceName: deviceName,
      deviceAlias: deviceAlias,
      bleDeviceId: bleDeviceId,
      numDays: numDays,
    );
  }

  Future<void> _performSync({
    required String serialNumber,
    String? deviceName,
    String? deviceAlias,
    String? bleDeviceId,
    int numDays = 1,
  }) async {
    if (!CloudSyncAccess.enabled) return;
    if (_activeSyncs.contains(serialNumber)) return;
    _activeSyncs.add(serialNumber);

    // Update state: syncing
    state = state.copyWithDevice(
      serialNumber,
      state.getDeviceState(serialNumber).copyWith(
            status: SyncStatus.syncing,
            errorMessage: null,
          ),
    );

    try {
      // 1. Claim device with name/alias
      await _supabaseService.claimDevice(
        serialNumber,
        deviceName: deviceName,
        deviceAlias: deviceAlias,
      );

      // 2. If bleDeviceId is provided, fetch BLE history day by day
      if (bleDeviceId != null && numDays > 0) {
        await _fetchHistoryChunked(
          bleDeviceId: bleDeviceId,
          serialNumber: serialNumber,
          numDays: numDays,
        );
      }

      // 3. Upload all remaining unsynced data (catch-all)
      await _syncService.syncData(targetDeviceId: serialNumber);

      // 4. Get last sync time
      final lastSync = await _syncService.getLastSyncedDate(serialNumber);

      // 5. Get remaining unsynced count
      final unsyncedCount = await _getUnsyncedCount(serialNumber);

      // 6. Update state: success
      state = state.copyWithDevice(
        serialNumber,
        DeviceSyncState(
          status: SyncStatus.success,
          lastSyncTime: lastSync,
          unsyncedCount: unsyncedCount,
        ),
      );

      debugPrint('AutoSync: Completed sync for $serialNumber');
    } catch (e) {
      // Update state: error
      state = state.copyWithDevice(
        serialNumber,
        state.getDeviceState(serialNumber).copyWith(
              status: SyncStatus.error,
              errorMessage: e.toString(),
            ),
      );
      debugPrint('AutoSync: Failed sync for $serialNumber: $e');
    } finally {
      _activeSyncs.remove(serialNumber);
    }
  }

  /// Fetch BLE history day by day, waiting for each day to complete
  /// before moving to the next. This avoids memory crashes from
  /// requesting too many pages at once.
  Future<void> _fetchHistoryChunked({
    required String bleDeviceId,
    required String serialNumber,
    required int numDays,
  }) async {
    final now = DateTime.now();

    for (int i = 0; i < numDays; i++) {
      if (!CloudSyncAccess.enabled) return;
      final dayDate = now.subtract(Duration(days: i));
      final dayStart = DateTime(dayDate.year, dayDate.month, dayDate.day);
      final dayEnd = i == 0
          ? now
          : DateTime(dayDate.year, dayDate.month, dayDate.day, 23, 59, 59);

      final dayDuration = GraphDataDuration.custom(
        DateTimeRange(start: dayStart, end: dayEnd),
      );

      final dayLabel = i == 0
          ? 'Today'
          : i == 1
              ? 'Yesterday'
              : '${dayDate.day}/${dayDate.month}';

      debugPrint('ChunkedSync: Fetching $dayLabel (${i + 1}/$numDays)');

      try {
        // Request history for this single day
        final historyNotifier =
            ref.read(deviceHistoryDataRequestProvider(bleDeviceId).notifier);
        historyNotifier.request(dayDuration);

        // Wait for the BLE fetch to complete
        await _waitForHistoryFetch(bleDeviceId);

        // Upload the data fetched so far
        await _syncService.syncData(targetDeviceId: serialNumber);

        debugPrint('ChunkedSync: $dayLabel complete');
      } catch (e) {
        debugPrint('ChunkedSync: $dayLabel failed: $e');
        // Continue to next day instead of aborting
      }
    }
  }

  /// Wait for the deviceHistoryDataRequestProvider to emit
  /// AsyncSuccess or AsyncFailure.
  Future<void> _waitForHistoryFetch(String bleDeviceId) async {
    final completer = Completer<void>();
    bool isCompleted = false;

    ref.listen<AsyncProgressValue>(
      deviceHistoryDataRequestProvider(bleDeviceId),
      (previous, next) {
        if (isCompleted) return;
        if (next is AsyncSuccess) {
          isCompleted = true;
          completer.complete();
        } else if (next is AsyncFailure) {
          isCompleted = true;
          completer.completeError('History fetch failed: ${next.error}');
        }
      },
    );

    // Check current state immediately
    final currentState =
        ref.read(deviceHistoryDataRequestProvider(bleDeviceId));
    if (currentState is AsyncSuccess) return;
    if (currentState is AsyncFailure) {
      throw Exception('History fetch failed: ${currentState.error}');
    }

    // 5 minute timeout per day
    await completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        throw Exception('History fetch timed out');
      },
    );
  }

  Future<int> _getUnsyncedCount(String serialNumber) async {
    try {
      return await _isarService.readAsync((isar) {
        return isar.deviceDatas.where().syncedEqualTo(false).findAll().length;
      });
    } catch (e) {
      return 0;
    }
  }

  /// Get device state for a specific serial number.
  /// Used by UI widgets.
  DeviceSyncState getDeviceState(String serialNumber) {
    return state.getDeviceState(serialNumber);
  }
}

/// Convenience provider that returns the sync state for a specific device.
final deviceSyncStateProvider =
    Provider.family<DeviceSyncState, String>((ref, serialNumber) {
  return ref.watch(autoSyncProvider).getDeviceState(serialNumber);
});
