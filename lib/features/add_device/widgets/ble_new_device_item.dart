import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/services/ble_service.dart';
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

    final bool isSlim =
        BLEService.instance.deviceModelFromScan(device.remoteId.str) ==
        DeviceModel.airspotSlim;

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
      title: Row(
        children: [
          Text(device.platformName),
          if (isSlim) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFFE9A23), width: 0.8),
              ),
              child: const Text(
                'Slim',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFE9A23),
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(device.advName),
      leading: const Icon(Icons.bluetooth, color: AppColors.primaryColor),
      trailing: DeviceConnectButton(deviceId: device.remoteId.str),
    );
  }
}
