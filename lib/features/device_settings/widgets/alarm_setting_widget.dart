import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AlarmSettingWidget extends ConsumerWidget {
  const AlarmSettingWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSettings = ref.watch(deviceSettingsProvider(deviceId));
    return SettingItemWidget(
      onTap: () {},
      item: SettingItem(
        title: 'Alarm',
        assetIcon: Assets.alarmSettings,
        suffixWidget: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            RichText(
              text: TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    context.pushNamed(
                      RouteNames.advancedAlarmSettings,
                      pathParameters: {'deviceId': deviceId},
                    );
                  },
                text: 'Advanced',
                style: TextStyle(
                  color: context.textTheme.bodyMedium?.color,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 24,
              child: Switch(
                value: deviceSettings.alarmEnabled,
                onChanged: (value) {
                  if (!ref
                      .read(bleDeviceConnectionProvider(deviceId).notifier)
                      .isConnected) {
                    context.showSnackBar('Device is not connected');
                    Navigator.of(context).pop();
                    return;
                  }

                  ref
                      .read(deviceSettingsProvider(deviceId).notifier)
                      .updateSettings(
                        deviceSettings.copyWith(
                            alarmEnabled: !deviceSettings.alarmEnabled),
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
