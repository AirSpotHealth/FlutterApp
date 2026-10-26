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

  bool _forgetting = false;

  Future<bool> forget() async {
    if (_forgetting) return false;
    _forgetting = true;
    final keepAlive = ref.keepAlive();
    try {
      state = const AsyncLoading();

      await ref
          .read(bleDeviceConnectionProvider(arg).notifier)
          .disconnectForForget();

      ref.read(bleSavedDevicesProvider.notifier).removeDeviceById(arg);

      ref.invalidate(deviceHistoryDataRequestProvider(arg));

      state = const AsyncData(true);
      return true;
    } catch (e) {
      state = AsyncError(
          'Could not remove this device. Close its settings and try again.',
          StackTrace.current);
      return false;
    } finally {
      _forgetting = false;
      keepAlive.close();
    }
  }
}
