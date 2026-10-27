import 'dart:async';
import 'package:isar_plus/isar_plus.dart';
import 'package:airspothealth/core/services/ble_communicator_service.dart';
import 'package:flutter/foundation.dart';

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
    var stage = 'stopping the Bluetooth connection';
    try {
      state = const AsyncLoading();

      await ref
          .read(bleDeviceConnectionProvider(arg).notifier)
          .disconnectForForget();

      BleCommunicatorService.instance.communicator(arg).reset();
      stage = 'removing saved device data';
      await ref.read(bleSavedDevicesProvider.notifier).removeDeviceById(arg);

      stage = 'clearing history state';
      ref.invalidate(deviceHistoryDataRequestProvider(arg));

      state = const AsyncData(true);
      return true;
    } catch (error, stack) {
      debugPrint('Forget device failed while $stage: $error');
      debugPrintStack(stackTrace: stack);
      state = AsyncError(error, stack);
      return false;
    } finally {
      _forgetting = false;
      keepAlive.close();
    }
  }
}

String forgetDeviceErrorMessage(Object? error) {
  if (error is DatabaseFullError) {
    return 'AirSpot’s local data storage is full. Close and reopen the app, then try removing this device again. If it still fails, contact support.';
  }
  return 'Could not finish removing this device. Please try again.';
}
