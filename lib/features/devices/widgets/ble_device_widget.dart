import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/devices/widgets/device_connect_button.dart';
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

    debugPrint(
        'bleDeviceConnectionProvider build ${bleDevice.deviceId}, $deviceConnectionState');

    final bool deviceConnected =
        deviceConnectionState == BluetoothBondState.bonded;

    return GestureDetector(
      onLongPress: () {
        if (deviceConnected) {
          ref
              .read(bleDeviceConnectionProvider(bleDevice.deviceId).notifier)
              .disconnect();
          return;
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: deviceConnected
                ? AppColors.primaryColor
                : AppColors.neutralGrey,
            width: 1,
          ),
          boxShadow: [
            if (deviceConnected)
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (deviceConnected)
                  ..._getConnectedWidgets(ref)
                else if (deviceConnectionState == BluetoothBondState.bonding)
                  const CupertinoActivityIndicator()
                else
                  Expanded(child: _buildConnectButton(ref)),
              ],
            ),
            Text(
              bleDevice.name,
              style: context.textTheme.labelLarge,
            ),
            if (deviceConnected) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: DeviceValueWidget(deviceId: bleDevice.deviceId),
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectButton(WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Not Connected/Unavailable',
          style: TextStyle(color: AppColors.neutralGrey),
        ),
        DeviceConnectButton(deviceId: bleDevice.deviceId),
      ],
    );
  }

  List<Widget> _getConnectedWidgets(WidgetRef ref) {
    return [
      GestureDetector(
        onTap: () {
          _showDeviceAliasDialog(ref, bleDevice.deviceId, bleDevice.alias);
        },
        child: const Icon(
          Icons.edit_outlined,
          color: AppColors.primaryColor,
          size: 24,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        bleDevice.alias ?? 'Airspot',
        style: ref.context.textTheme.labelLarge,
      ),
      const Spacer(),
      Text(
        'connected',
        style: ref.context.textTheme.labelLarge
            ?.copyWith(color: AppColors.brandColorGreen),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: () {
          ref.context.pushNamed(
            RouteNames.deviceGraph,
            pathParameters: {'deviceId': bleDevice.deviceId},
          );
        },
        child: Image.asset(
          Assets.deviceGraph,
          width: 28,
        ),
      ),
      const SizedBox(width: 12),
      GestureDetector(
        onTap: () {
          ref.context.pushNamed(
            RouteNames.deviceSettings,
            pathParameters: {'deviceId': bleDevice.deviceId},
          );
        },
        child: Image.asset(
          Assets.deviceSettings,
          width: 28,
        ),
      ),
      const SizedBox(width: 8),
    ];
  }

  void _showDeviceAliasDialog(WidgetRef ref, String deviceId, String? alias) {
    showAdaptiveDialog(
        context: ref.context,
        barrierDismissible: true,
        builder: (context) {
          final TextEditingController controller =
              TextEditingController(text: alias);
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Change Device Nickname',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter device alias',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryColor)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryColor)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primaryColor)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(bleSavedDevicesProvider.notifier)
                      .updateDeviceAlias(deviceId, controller.text);
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
  }
}
