import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceAscDayProvider =
    AsyncNotifierProvider.family<DeviceAscDayCountNotifier, DateTime?, String>(
  () => DeviceAscDayCountNotifier(),
);

class DeviceAscDayCountNotifier extends FamilyAsyncNotifier<DateTime?, String> {
  @override
  DateTime? build(String deviceId) {
    return null;
  }

  Future<void> getAscDayCount() async {
    state = const AsyncValue.loading();
    await ref
        .read(bleDeviceCommunicationProvider(arg).notifier)
        .sendCommand(DeviceCmdUtils.getAscDayCount());
  }

  /// ASC happens when day == 7. find the next ASC day from dayCount.
  ///
  /// Example:
  /// - dayCount = 1
  /// - Next ASC date = current date + 6 days (23:59:59)
  /// -
  void setNextAscDate(int dayCount) {
    debugPrint('dayCount: $dayCount');
    final now = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59);
    final nextAscDate = now.add(Duration(days: 6 - dayCount));
    state = AsyncData(nextAscDate);
  }
}
