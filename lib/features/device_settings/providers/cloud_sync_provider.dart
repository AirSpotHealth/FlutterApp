import 'dart:async';

import 'package:airspothealth/core/services/supabase_service.dart';
import 'package:airspothealth/core/services/sync_service.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:airspothealth/features/device_settings/models/device_sensor_config_data.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/sensor_configuration_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CloudSyncState {
  final bool isLoading;
  final String? statusMessage;
  final String? errorMessage;
  final String? successMessage;
  final DateTime? lastSyncedDate;

  const CloudSyncState({
    this.isLoading = false,
    this.statusMessage,
    this.errorMessage,
    this.successMessage,
    this.lastSyncedDate,
  });

  CloudSyncState copyWith({
    bool? isLoading,
    String? statusMessage,
    String? errorMessage,
    String? successMessage,
    DateTime? lastSyncedDate,
  }) {
    return CloudSyncState(
      isLoading: isLoading ?? this.isLoading,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      lastSyncedDate: lastSyncedDate ?? this.lastSyncedDate,
    );
  }
}

/// Provider for managing the Cloud Sync state.
final cloudSyncProvider = NotifierProvider.family
    .autoDispose<CloudSyncNotifier, CloudSyncState, String>(
  CloudSyncNotifier.new,
);

class CloudSyncNotifier
    extends AutoDisposeFamilyNotifier<CloudSyncState, String> {
  late final String _deviceId;
  final SyncService _syncService = SyncService();

  @override
  CloudSyncState build(String arg) {
    _deviceId = arg;
    _fetchLastSyncedDate();
    return const CloudSyncState();
  }

  Future<void> _fetchLastSyncedDate() async {
    final date = await _syncService.getLastSyncedDate(_deviceId);
    state = state.copyWith(lastSyncedDate: date);
  }

  Future<void> sync() async {
    // Reset state
    state = state.copyWith(
      isLoading: true,
      statusMessage: 'Starting sync...',
      errorMessage: null,
      successMessage: null,
    );

    try {
      // 1. Get Serial Number
      state = state.copyWith(statusMessage: 'Fetching device configuration...');
      final sensorConfigState =
          ref.read(sensorConfigurationProvider(_deviceId));

      String? serialNumber;
      if (sensorConfigState.isSuccess) {
        final data = (sensorConfigState as AsyncSuccess).data;
        if (data is DeviceSensorConfigData) {
          serialNumber = data.serialNumber;
        }
      }

      if (serialNumber == null) {
        // Try to fetch it if missing?
        // For now, assume it should be there if page is loaded
        throw Exception(
            'Could not get device Serial Number. Please wait for sensor config to load.');
      }

      // 1.5 Claim Device (Ensure ownership for RLS)
      state = state.copyWith(statusMessage: 'Registering device...');
      await SupabaseService().claimDevice(serialNumber);

      // 2. Request History
      // 2. Request History
      state = state.copyWith(
          statusMessage:
              'Fetching historical data from device (Today only)...');
      // Limit to today for testing
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = now;
      final duration =
          GraphDataDuration.custom(DateTimeRange(start: start, end: end));

      final historyNotifier =
          ref.read(deviceHistoryDataRequestProvider(_deviceId).notifier);

      historyNotifier.request(duration);

      // 3. Wait for History
      await _waitForHistoryFetch();

      // 4. Upload
      state = state.copyWith(statusMessage: 'Uploading data to Cloud...');
      await _syncService.syncData(targetDeviceId: serialNumber);

      // 5. Success
      final lastSynced = await _syncService.getLastSyncedDate(_deviceId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Sync Completed Successfully!',
        lastSyncedDate: lastSynced,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sync Failed',
      );
      // We could also expose the specific error 'e' if needed
      debugPrint('Sync error: $e');
    }
  }

  Future<void> _waitForHistoryFetch() async {
    // Poll until history fetch is done
    int retries = 0;
    while (retries < 60) {
      // 60 seconds timeout
      final state = ref.read(deviceHistoryDataRequestProvider(_deviceId));
      if (state is AsyncSuccess) {
        return;
      }
      if (state is AsyncFailure) {
        throw Exception('History fetch failed: ${state.error}');
      }
      await Future.delayed(const Duration(seconds: 1));
      retries++;
    }
    throw Exception('History fetch timed out');
  }
}
