import 'package:airspothealth/core/widgets/icon_bg_widget.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/providers/device_variant_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceVariantWidget extends ConsumerWidget {
  const DeviceVariantWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceVariant = ref.watch(deviceVariantProvider(deviceId));

    return SettingItemWidget(
      item: SettingItem(
        title: 'Device Variant',
        suffixWidget: deviceVariant.when(
          none: () => const SizedBox(),
          inProgress: (progress, message) =>
              CircularProgressIndicator.adaptive(),
          success: (data) => Text(data.name),
          failure: (error) => Text(error.toString()),
        ),
        leadingWidget: IconBgWidget(
            backgroundColor: Colors.teal,
            child: Icon(Icons.developer_board, color: Colors.white)),
      ),
      onTap: () {
        if (deviceVariant is AsyncInProgress) return;

        ref.read(deviceVariantProvider(deviceId).notifier).getDeviceVariant();
      },
    );
  }
}
