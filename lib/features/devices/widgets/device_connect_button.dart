import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/tappable_widget.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceConnectButton extends ConsumerWidget {
  const DeviceConnectButton({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bleDevice = ref.watch(bleDeviceConnectionProvider(deviceId));

    return bleDevice.when(
      cases: {
        BluetoothBondState.bonded: () => const Text('Connected',
            style: TextStyle(color: AppColors.primaryColor)),
        BluetoothBondState.bonding: () => const CupertinoActivityIndicator(),
        BluetoothBondState.none: () => TappableWidget(
              onTap: () => ref
                  .read(bleDeviceConnectionProvider(deviceId).notifier)
                  .connect(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'Connect',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
      },
      orElse: () => const Text('Unknown state'),
    );
  }
}
