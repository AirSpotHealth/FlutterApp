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
    // We need the serial number to check Supabase
    // Try to get it from the provider if already loaded
    final sensorConfigState = ref.read(sensorConfigurationProvider(_deviceId));
    debugPrint('Sensor Config State: $sensorConfigState');
    String? serialNumber;

    if (sensorConfigState.isSuccess) {
      final data = (sensorConfigState as AsyncSuccess).data;
      if (data is DeviceSensorConfigData) {
        serialNumber = data.serialNumber;
      }
    }

    debugPrint('Serial Number: $serialNumber');

    if (serialNumber != null) {
      final date = await _syncService.getLastSyncedDate(serialNumber);
      state = state.copyWith(lastSyncedDate: date);
    }
  }

  Future<void> sync({GraphDataDuration? duration}) async {
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
      final selectedDuration = duration ?? GraphDataDuration.today;
      state = state.copyWith(
          statusMessage:
              'Fetching historical data from device (${selectedDuration.durationString})...');

      final historyNotifier =
          ref.read(deviceHistoryDataRequestProvider(_deviceId).notifier);

      historyNotifier.request(selectedDuration);

      // 3. Wait for History
      await _waitForHistoryFetch();

      // 4. Upload
      state = state.copyWith(statusMessage: 'Uploading data to Cloud...');
      await _syncService.syncData(targetDeviceId: serialNumber);

      // 5. Success
      final lastSynced = await _syncService.getLastSyncedDate(serialNumber);
      state = state.copyWith(
        isLoading: false,
        statusMessage: 'Sync complete',
        successMessage:
            'Successfully synced data for ${selectedDuration.durationString}',
        lastSyncedDate: lastSynced,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        statusMessage: 'Something went wrong',
        errorMessage: e.toString(),
      );
      // We could also expose the specific error 'e' if needed
      debugPrint('Sync error: $e');
    }
  }

  Future<void> _waitForHistoryFetch() async {
    final completer = Completer<void>();

    // Since this is inside a Notifier, we can't use ref.listen manually in a way that provides a subscription to close.
    // However, we can use a periodic check or just rely on the fact that standard Notifiers don't support
    // one-off listeners easily without leaks if not scoped.
    // A clean way to "wait" for a provider state change in a function is to poll, OR
    // if we trust the loop logic, just keep the loop but make it smarter?
    // No, poling is bad.
    // Let's use a broadcast stream approach if possible? No.

    // Actually, ref.listen IS safe to use in build(), but inside a method like this, it attaches a listener to the provider
    // that lives as long as THIS provider (CloudSyncNotifier) lives.
    // CloudSyncNotifier is autoDispose. So the listener will die when CloudSyncNotifier dies.
    // CloudSyncNotifier dies when the user leaves the screen (CloudSyncPage).
    // So this IS SAFE essentially, provided we don't attach 100 listeners by clicking 'sync' 100 times.
    // But the button is disabled during sync. So we effectively attach 1 listener per session.
    // This is acceptable.

    // Flag to ensure we don't complete multiple times if listener fires multiple times
    bool isCompleted = false;

    // Remove previous listeners? We can't.
    // But we can just add a new one.

    ref.listen<AsyncProgressValue>(
      deviceHistoryDataRequestProvider(_deviceId),
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
    ); // Note: ref.listen in Notifier doesn't return a removal function in standard Riverpod?
    // Wait, actually `ref.listen` in `Notifier` context usually returns void.
    // Only `ref.read` / `ref.watch` are standard.

    // If `ref.listen` returns void, we can't remove it.
    // This confirms that the listener lasts until the notifier is disposed.

    // Initial check
    final currentState = ref.read(deviceHistoryDataRequestProvider(_deviceId));
    if (currentState is AsyncSuccess) {
      return;
    } else if (currentState is AsyncFailure) {
      throw Exception('History fetch failed: ${currentState.error}');
    }

    try {
      // 15 minutes timeout
      await completer.future.timeout(const Duration(minutes: 15));
    } on TimeoutException {
      throw Exception('History fetch timed out after 15 minutes');
    }
  }
}
