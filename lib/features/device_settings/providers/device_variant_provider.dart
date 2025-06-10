import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DeviceVariant {
  scd40,
  scd41,
  unknown;

  static DeviceVariant fromValue(int value) {
    debugPrint('DeviceVariant: $value');
    switch (value) {
      case 0:
        return DeviceVariant.scd40;
      case 1:
        return DeviceVariant.scd41;
      default:
        return DeviceVariant.unknown;
    }
  }

  String get name {
    switch (this) {
      case DeviceVariant.scd40:
        return 'SCD40';
      case DeviceVariant.scd41:
        return 'SCD41';
      default:
        return 'Unknown';
    }
  }
}

final deviceVariantProvider = NotifierProvider.family<_DeviceVariantNotifier,
    AsyncProgressValue<DeviceVariant>, String>(
  _DeviceVariantNotifier.new,
);

class _DeviceVariantNotifier
    extends FamilyNotifier<AsyncProgressValue<DeviceVariant>, String> {
  @override
  AsyncProgressValue<DeviceVariant> build(String deviceId) {
    return AsyncNone<DeviceVariant>();
  }

  void setDeviceVariant(DeviceVariant deviceVariant) {
    state = AsyncSuccess<DeviceVariant>(deviceVariant);
  }

  void getDeviceVariant() {
    state =
        AsyncInProgress<DeviceVariant>(0.5, message: 'Getting device variant');
    ref
        .read(bleDeviceCommunicationProvider(arg).notifier)
        .sendCommand(DeviceCmdUtils.getDeviceVariant());

    /// add a 30 second timeout
    Future.delayed(const Duration(seconds: 30), () {
      if (state is AsyncInProgress) {
        state = AsyncFailure<DeviceVariant>('Failed to get device variant');
      }
    });
  }

  void resetDeviceVariant() {
    state = AsyncNone<DeviceVariant>();
  }
}
