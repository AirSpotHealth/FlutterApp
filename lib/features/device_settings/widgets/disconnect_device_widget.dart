import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DisconnectDeviceWidget extends ConsumerWidget {
  const DisconnectDeviceWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingItemWidget(
      item: SettingItem(
        title: 'Disconnect Device',
        assetIcon: Assets.airGraph,
        leadingWidget: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryColorDark.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.bluetooth_disabled,
            color: AppColors.primaryColorDark,
          ),
        ),
        suffixWidget: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
      onTap: () =>
          ref.read(bleDeviceConnectionProvider(deviceId).notifier).disconnect(),
    );
  }
}
