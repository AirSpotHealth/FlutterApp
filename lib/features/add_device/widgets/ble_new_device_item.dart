import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BleNewDeviceItem extends ConsumerWidget {
  const BleNewDeviceItem({required this.device, super.key});

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('Building device item: ${device.remoteId}');
    ref.listen<BluetoothBondState>(
        bleDeviceConnectionProvider(device.remoteId.str),
        (oldStatus, newStatus) {
      debugPrint('Device status changed: $newStatus');

      if (newStatus == BluetoothBondState.bonded && oldStatus != newStatus) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device connected successfully'),
          ),
        );

        context.pop();
      }
    });

    final BluetoothBondState deviceStatus =
        ref.watch(bleDeviceConnectionProvider(device.remoteId.str));

    debugPrint('Device status: $deviceStatus');

    return ListTile(
      dense: true,
      key: ValueKey(device.remoteId),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      tileColor: Colors.white,
      title: Text(device.platformName),
      subtitle: Text(device.advName),
      leading: const Icon(Icons.bluetooth),
      trailing: deviceStatus.when(
        cases: {
          BluetoothBondState.none: () => ElevatedButton(
                onPressed: () => ref
                    .read(bleDeviceConnectionProvider(device.remoteId.str)
                        .notifier)
                    .connect(device),
                child: const Text('Connect'),
              ),
          BluetoothBondState.bonding: () =>
              const CircularProgressIndicator.adaptive(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor)),
          BluetoothBondState.bonded: () => const Icon(
                Icons.bluetooth_connected,
                color: AppColors.primaryColor,
              ),
        },
        orElse: () => const Icon(Icons.error),
      ),
    );
  }
}
