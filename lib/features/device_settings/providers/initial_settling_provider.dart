import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:airspothealth/core/services/ble_communicator_service.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import '../models/initial_settling_state.dart';

final initialSettlingProvider = NotifierProvider.autoDispose
    .family<InitialSettlingNotifier, AsyncValue<InitialSettlingState>, String>(
        InitialSettlingNotifier.new);

class InitialSettlingNotifier extends AutoDisposeFamilyNotifier<
    AsyncValue<InitialSettlingState>, String> {
  Timer? _poll, _timeout;
  StreamSubscription<List<int>>? _subscription;
  int _epoch = 0;
  bool _pending = false;
  @override
  AsyncValue<InitialSettlingState> build(String deviceId) {
    final epoch = ++_epoch;
    _poll?.cancel();
    _timeout?.cancel();
    _subscription?.cancel();
    _pending = false;
    ref.onDispose(() {
      ++_epoch;
      _poll?.cancel();
      _timeout?.cancel();
      _subscription?.cancel();
    });
    final connected = ref.watch(bleDeviceConnectionProvider(deviceId)) ==
        BluetoothBondState.bonded;
    final version = ref.watch(bleDeviceProvider(deviceId)).firmwareVersion;
    if (!connected || !InitialSettlingState.supported(version)) {
      return AsyncError(
          'Connect to a Slim running firmware 0.22.4 or later to check settling progress.',
          StackTrace.current);
    }
    _subscription = BleCommunicatorService.instance
        .communicator(deviceId)
        .dataStream
        .listen((frame) {
      if (epoch != _epoch || frame.length < 3 || frame[2] != 0x3e) return;
      _timeout?.cancel();
      _pending = false;
      try {
        final status = InitialSettlingState.fromFrame(frame);
        state = AsyncData(status);
        if (!status.active && status.remainingSeconds == 0) _poll?.cancel();
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    }, onError: (Object e, StackTrace st) {
      if (epoch == _epoch) {
        _pending = false;
        state = AsyncError(e, st);
      }
    });
    Future.microtask(() {
      if (epoch == _epoch) refresh();
    });
    _poll = Timer.periodic(const Duration(seconds: 30), (_) {
      if (epoch == _epoch && !_pending) refresh();
    });
    return const AsyncLoading();
  }

  Future<void> refresh() => _send(InitialSettlingState.request);
  Future<void> _send(List<int> command) async {
    if (_pending) return;
    final epoch = _epoch;
    _pending = true;
    // Keep the last device snapshot visible during a routine poll. Actions and
    // failed/disconnected reads still replace it with explicit pending/error UI.
    if (command[3] != 0 || state.asData == null) {
      state = const AsyncLoading();
    }
    _timeout?.cancel();
    _timeout = Timer(const Duration(seconds: 8), () {
      if (epoch == _epoch) {
        _pending = false;
        state = AsyncError(
            'Progress unavailable. Reconnect and retry; elapsed phone time is not counted.',
            StackTrace.current);
      }
    });
    try {
      final sent = await ref
          .read(bleDeviceCommunicationProvider(arg).notifier)
          .sendCommand(command);
      if (!sent) throw StateError('Connect to the device to check progress.');
    } catch (e, st) {
      if (epoch == _epoch) {
        _timeout?.cancel();
        _pending = false;
        state = AsyncError(e, st);
      }
    }
  }
}
