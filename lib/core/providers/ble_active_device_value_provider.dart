import 'package:airspothealth/core/providers/ble_active_device_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bleActiveDeviceValueProvider =
    NotifierProvider.autoDispose<_BleActiveDeviceValueNotifier, dynamic>(
  _BleActiveDeviceValueNotifier.new,
);

class _BleActiveDeviceValueNotifier extends AutoDisposeNotifier<dynamic> {
  @override
  dynamic build() {
    final activeDeviceStream =
        ref.read(bleActiveDeviceProvider.notifier).notificationStream;

    debugPrint('Active device stream: $activeDeviceStream');

    if (activeDeviceStream == null) {
      return null;
    }

    activeDeviceStream.listen((data) {
      state = data;
    });
  }
}
