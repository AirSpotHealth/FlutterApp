import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/devices/widgets/device_connect_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BleNewDeviceItem extends ConsumerWidget {
  const BleNewDeviceItem({required this.device, super.key});

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<BluetoothBondState>(
        bleDeviceConnectionProvider(device.remoteId.str),
        (oldStatus, newStatus) {
      if (newStatus == BluetoothBondState.bonded && oldStatus != newStatus) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device connected successfully'),
          ),
        );
      }
    });

    final BluetoothBondState deviceStatus =
        ref.watch(bleDeviceConnectionProvider(device.remoteId.str));

    return ListTile(
      dense: true,
      key: ValueKey(device.remoteId),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        side: deviceStatus == BluetoothBondState.bonded
            ? const BorderSide(color: AppColors.primaryColor, width: 1)
            : BorderSide.none,
      ),
      tileColor: Colors.white,
      title: Text(device.platformName),
      subtitle: Text(device.advName),
      leading: const Icon(Icons.bluetooth, color: AppColors.primaryColor),
      trailing: DeviceConnectButton(deviceId: device.remoteId.str),
    );
  }
}
