import 'package:airspothealth/core/providers/bluetooth_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BluetoothStateWidget extends ConsumerWidget {
  const BluetoothStateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool bluetoothOff =
        ref.watch(bluetoothStateProvider) == BluetoothAdapterState.off;

    if (bluetoothOff) {
      return const Padding(
        padding: EdgeInsets.only(right: 16),
        child: Icon(
          Icons.bluetooth_disabled,
          color: Colors.white,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
