import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/core/models/sensor_error_state.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

/// Provider for tracking sensor error state per device
/// Returns null when no error, SensorErrorState when sensor has failed
final sensorErrorProvider =
    NotifierProvider.family<SensorErrorNotifier, SensorErrorState?, String>(
  SensorErrorNotifier.new,
);

class SensorErrorNotifier extends FamilyNotifier<SensorErrorState?, String> {
  final IsarService _isarService = IsarService();

  @override
  SensorErrorState? build(String arg) {
    // Check database for recent sensor error state
    return _checkForStoredError();
  }

  String get deviceId => arg;

  /// Check if the most recent data for this device is a sensor error
  SensorErrorState? _checkForStoredError() {
    try {
      final collection = _isarService.deviceDatas;

      final recentError = collection
          .where()
          .deviceIdEqualTo(deviceId)
          .typeEqualTo(DeviceDataType.sensorError.index)
          .sortByDateTimeDesc()
          .findFirst();

      if (recentError == null) return null;

      // Check if this error is newer than the most recent CO2 reading
      final recentCo2 = collection
          .where()
          .deviceIdEqualTo(deviceId)
          .typeEqualTo(DeviceDataType.co2.index)
          .sortByDateTimeDesc()
          .findFirst();

      // If the error is more recent than the last CO2 reading, show error
      if (recentCo2 == null ||
          recentError.dateTime.isAfter(recentCo2.dateTime)) {
        debugPrint(
            'Found stored sensor error for $deviceId, errorCode: ${recentError.value}');
        return SensorErrorState(
          errorCode: recentError.value,
          recoveryAttempts: 3, // Assume exhausted if stored
          timestamp: recentError.dateTime,
          deviceId: deviceId,
        );
      }

      return null;
    } catch (e) {
      debugPrint('Error checking for stored sensor error: $e');
      return null;
    }
  }

  /// Set error state when CO2 = 0xFFFF is received
  void setError({
    required int errorCode,
    required int recoveryAttempts,
  }) {
    state = SensorErrorState(
      errorCode: errorCode,
      recoveryAttempts: recoveryAttempts,
      timestamp: DateTime.now(),
      deviceId: deviceId,
    );
  }

  /// Clear error state when valid CO2 reading is received
  void clearError() {
    state = null;
  }

  /// Check if device is currently in error state
  bool get hasError => state != null;
}
