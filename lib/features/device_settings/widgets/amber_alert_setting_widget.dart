import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AmberAlertSettingWidget extends ConsumerWidget {
  const AmberAlertSettingWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSettings = ref.watch(deviceSettingsProvider(deviceId));
    return SettingItemWidget(
        onTap: () {},
        item: SettingItem(
          title: t.deviceSettings.amberAlert,
          leadingWidget: const Icon(
            CupertinoIcons.bell,
            color: AppColors.brandColorAmber,
          ),
          suffixWidget: SizedBox(
            height: 24,
            child: Switch(
              value: deviceSettings.co2MedAlertEnabled,
              onChanged: (value) {
                ref
                    .read(deviceSettingsProvider(deviceId).notifier)
                    .updateSettings(
                        deviceSettings.copyWith(co2MedAlertEnabled: value));
              },
            ),
          ),
        ));
  }
}
