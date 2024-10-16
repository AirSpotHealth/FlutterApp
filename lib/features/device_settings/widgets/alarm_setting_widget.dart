import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmSettingWidget extends ConsumerWidget {
  const AlarmSettingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingItemWidget(
      item: SettingItem(
        title: 'Alarm',
        assetIcon: Assets.alarmSettings,
        suffixWidget: SizedBox(
          height: 24,
          child: Switch(
            value: true,
            onChanged: (value) {},
          ),
        ),
      ),
    );
  }
}
