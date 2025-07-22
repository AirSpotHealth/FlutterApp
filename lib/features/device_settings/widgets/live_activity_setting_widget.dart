import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/services/live_activity_service.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveActivitySettingWidget extends ConsumerWidget {
  const LiveActivitySettingWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSettings = ref.watch(deviceSettingsProvider(deviceId));

    return SettingItemWidget(
      onTap: () {},
      item: SettingItem(
        title: 'Live Activity',
        assetIcon: Assets.liveActivity,
        suffixWidget: SizedBox(
          height: 24,
          child: Switch(
            value: deviceSettings.showLiveActivity,
            onChanged: (value) {
              ref
                  .read(deviceSettingsProvider(deviceId).notifier)
                  .updateSettings(
                    deviceSettings.copyWith(
                        showLiveActivity: !deviceSettings.showLiveActivity),
                  );

              if (value) {
                // User toggled ON - start the live activity/notification
                // Trigger a fresh data update which will start the live activity
                ref
                    .read(bleDeviceCommunicationProvider(deviceId).notifier)
                    .sendCommand(DeviceCmdUtils
                        .getCO2()); // Get CO2 command to trigger live activity update
              } else {
                // User toggled OFF - end the live activity/notification
                LiveActivityService().endLiveActivity();
              }
            },
          ),
        ),
      ),
    );
  }
}
