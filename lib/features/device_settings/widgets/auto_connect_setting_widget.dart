import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AutoConnectSettingWidget extends ConsumerWidget {
  const AutoConnectSettingWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSettings = ref.watch(deviceSettingsProvider(deviceId));
    return SettingItemWidget(
      onTap: () {},
      item: SettingItem(
        title: 'Auto Connect',
        assetIcon: Assets.autoConnectSettings,
        suffixWidget: SizedBox(
          height: 24,
          child: Switch(
            value: deviceSettings.autoConnect,
            onChanged: (value) {
              ref
                  .read(deviceSettingsProvider(deviceId).notifier)
                  .updateSettings(
                    deviceSettings.copyWith(autoConnect: value),
                  );
            },
          ),
        ),
      ),
    );
  }
}
