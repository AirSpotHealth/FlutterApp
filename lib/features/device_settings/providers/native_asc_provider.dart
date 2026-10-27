import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_settings/models/native_asc_state.dart';

final nativeAscProvider = NotifierProvider.family<NativeAscNotifier,
    AsyncValue<NativeAscState>, String>(NativeAscNotifier.new);

class NativeAscNotifier
    extends FamilyNotifier<AsyncValue<NativeAscState>, String> {
  Timer? _timeout;
  int _generation = 0;
  bool _disposed = false;

  @override
  AsyncValue<NativeAscState> build(String deviceId) {
    _disposed = false;
    _timeout?.cancel();
    final generation = ++_generation;
    ref.onDispose(() {
      _disposed = true;
      _timeout?.cancel();
    });
    final version = ref.watch(bleDeviceProvider(deviceId)).firmwareVersion;
    final connected = ref.watch(bleDeviceConnectionProvider(deviceId)) ==
        BluetoothBondState.bonded;
    if (!connected || !NativeAscState.supported(version)) {
      return AsyncError('Connect a Slim running firmware 0.18.0 or later.',
          StackTrace.current);
    }
    Future.microtask(() {
      if (!_disposed && generation == _generation) refresh();
    });
    return const AsyncLoading();
  }

  Future<void> refresh() => _send(DeviceCmdUtils.getNativeAsc());
  Future<void> _send(List<int> command) async {
    if (ref.read(bleDeviceConnectionProvider(arg)) !=
        BluetoothBondState.bonded) {
      state = AsyncError('Connect to the device first.', StackTrace.current);
      return;
    }
    _timeout?.cancel();
    final generation = ++_generation;
    state = const AsyncLoading(); // Never publish an optimistic preference.
    _timeout = Timer(const Duration(seconds: 15), () {
      if (!_disposed && generation == _generation) {
        state = AsyncError(
            'No confirmation from the sensor. Tap Retry.', StackTrace.current);
      }
    });
    final sent = await ref
        .read(bleDeviceCommunicationProvider(arg).notifier)
        .sendCommand(command);
    if (!sent && !_disposed && generation == _generation && state.isLoading) {
      _timeout?.cancel();
      state = AsyncError(
          'Could not reach the device. Tap Retry.', StackTrace.current);
    }
  }

  void receive(List<int> frame) {
    _timeout?.cancel();
    try {
      final value = NativeAscState.fromFrame(frame);
      if (value.error != 0 || !value.verified) {
        state = AsyncError(
            'Sensor did not confirm the setting (error ${value.error}). Tap Retry.',
            StackTrace.current);
      } else {
        state = AsyncData(value);
      }
    } catch (error, stack) {
      state = AsyncError(error, stack);
    }
  }
}
