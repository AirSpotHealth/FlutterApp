import 'dart:async';

import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/models/device_sensor_config_data.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sensorConfigurationProvider = NotifierProvider.autoDispose.family<
    SensorConfigurationNotifier,
    AsyncProgressValue<DeviceSensorConfigData?>,
    String>(
  SensorConfigurationNotifier.new,
);

class SensorConfigurationNotifier extends AutoDisposeFamilyNotifier<
    AsyncProgressValue<DeviceSensorConfigData?>, String> {
  @override
  AsyncProgressValue<DeviceSensorConfigData?> build(String deviceId) {
    _fetchConfiguration(deviceId);
    return const AsyncInProgress<DeviceSensorConfigData?>(0,
        message: 'Fetching Sensor Config...');
  }

  Future<void> _fetchConfiguration(String deviceId,
      {bool isRefresh = false}) async {
    if (isRefresh) {
      state = const AsyncInProgress<DeviceSensorConfigData?>(0,
          message: 'Refreshing Sensor Config...');
    }

    try {
      ref
          .read(bleDeviceCommunicationProvider(deviceId).notifier)
          .sendCommand(DeviceCmdUtils.getDeviceSensorConfig());
    } catch (e, stackTrace) {
      debugPrint(
          'Error sending command to fetch sensor configuration for $deviceId: $e\n$stackTrace');
      state = AsyncFailure<DeviceSensorConfigData?>(e);
    }
  }

  /// Called by BleDataService when new sensor configuration data is parsed.
  void updateSensorConfigData(DeviceSensorConfigData configData) {
    state = AsyncSuccess<DeviceSensorConfigData?>(configData);
  }

  Future<void> refresh() async {
    final deviceId = arg;
    await _fetchConfiguration(deviceId, isRefresh: true);
  }
}
