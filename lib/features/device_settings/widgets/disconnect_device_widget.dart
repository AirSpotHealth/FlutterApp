import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DisconnectDeviceWidget extends ConsumerWidget {
  const DisconnectDeviceWidget({required this.device, super.key});

  final BleDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingItemWidget(
      item: SettingItem(
        title: 'Disconnect Device',
        assetIcon: Assets.airGraph,
        leadingWidget: Image.asset(
          Assets.disconnectIcon,
          width: 32,
        ),
        suffixWidget: const SizedBox(),
      ),
      onTap: () {
        ref
            .read(bleDeviceConnectionProvider(device.deviceId).notifier)
            .disconnect();
      },
    );
  }
}
