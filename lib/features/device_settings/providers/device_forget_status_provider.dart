import 'dart:async';

import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceForgetStatusProvider = AsyncNotifierProvider.family
    .autoDispose<_DeviceForgetStatusNotifier, bool, String>(
        _DeviceForgetStatusNotifier.new);

class _DeviceForgetStatusNotifier
    extends AutoDisposeFamilyAsyncNotifier<bool, String> {
  @override
  FutureOr<bool> build(String arg) {
    return false;
  }

  void forget() async {
    try {
      state = const AsyncLoading();

      await ref.read(bleDeviceConnectionProvider(arg).notifier).disconnect();

      ref.read(bleSavedDevicesProvider.notifier).removeDeviceById(arg);

      ref.invalidate(deviceHistoryDataRequestProvider);

      state = const AsyncData(true);
    } catch (e) {
      state = AsyncError(
          "An Error occured when deleting the device: $e", StackTrace.current);
    }
  }
}
