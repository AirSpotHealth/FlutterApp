import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/devices/widgets/device_value_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BleDeviceWidget extends ConsumerWidget {
  const BleDeviceWidget({required this.bleDevice, super.key});

  final BleDevice bleDevice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BluetoothBondState deviceConnectionState =
        ref.watch(bleDeviceConnectionProvider(bleDevice.deviceId));

    final deviceConnected = deviceConnectionState == BluetoothBondState.bonded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryColorLight,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_outlined,
                color: AppColors.primaryColor,
              ),
              Text(
                bleDevice.name,
                style: context.textTheme.labelLarge,
              ),
              if (deviceConnected)
                ..._getConnectedWidgets(context)
              else if (deviceConnectionState == BluetoothBondState.bonding)
                const CircularProgressIndicator()
              else
                _buildConnectButton(ref),
            ],
          ),
          if (deviceConnected) ...[
            const Divider(),
            const SizedBox(height: 16),
            DeviceValueWidget(deviceId: bleDevice.deviceId)
          ],
        ],
      ),
    );
  }

  ElevatedButton _buildConnectButton(WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        ref
            .read(bleDeviceConnectionProvider(bleDevice.deviceId).notifier)
            .connect(BluetoothDevice.fromId(bleDevice.deviceId));
      },
      child: const Text('Connect'),
    );
  }

  List<Widget> _getConnectedWidgets(BuildContext context) {
    return [
      Text(
        'connected',
        style: context.textTheme.labelLarge
            ?.copyWith(color: AppColors.brandColorGreen),
      ),
      Flexible(
        child: IconButton(
          onPressed: () {
            context.pushNamed(
              RouteNames.deviceGraph,
              extra: bleDevice.deviceId,
            );
          },
          icon: const Icon(
            CupertinoIcons.graph_circle,
            color: Colors.green,
          ),
        ),
      ),
      Flexible(
        child: IconButton(
          onPressed: () {
            context.pushNamed(
              RouteNames.deviceSettings,
              extra: bleDevice.deviceId,
            );
          },
          icon: const Icon(
            CupertinoIcons.settings,
            color: AppColors.neutralGreyDark,
          ),
        ),
      ),
    ];
  }
}
