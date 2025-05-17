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
        message: 'Loading Sensor Config...');
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

      await Future.delayed(const Duration(seconds: 2));
      final dummyBytes = <int>[
        0x04,
        0x00,
        0x00,
        0x01,
        0x86,
        0xA0,
        0x00,
        0x01,
        0xF4
      ];
      final configData = DeviceSensorConfigData.fromBytes(dummyBytes);
      state = AsyncSuccess<DeviceSensorConfigData?>(configData);
    } catch (e, stackTrace) {
      debugPrint(
          'Error fetching sensor configuration for $deviceId: $e\n$stackTrace');
      state = AsyncFailure<DeviceSensorConfigData?>(e);
    }
  }

  Future<void> refresh() async {
    final deviceId = arg;
    await _fetchConfiguration(deviceId, isRefresh: true);
  }
}
