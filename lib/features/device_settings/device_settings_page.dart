import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/providers/device_forget_status_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/alarm_setting_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/auto_connect_setting_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/vibrate_setting_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DeviceSettingsPage extends ConsumerWidget {
  const DeviceSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  static final _deviceSettingsList = <SettingItem>[
    SettingItem(
      title: 'Time Settings',
      assetIcon: Assets.timeSettings,
      route: RouteNames.timeSettings,
    ),
    SettingItem(
      title: 'Power mode',
      assetIcon: Assets.powerModeSettings,
      route: RouteNames.powerModeSettings,
    ),
    SettingItem(
      title: 'CO2 PPM Settings',
      assetIcon: Assets.ppmSettings,
      route: RouteNames.ppmSettings,
      enabled: false,
    ),
    SettingItem(
      title: 'High CO2 Alert',
      assetIcon: Assets.co2Settings,
      route: RouteNames.co2Settings,
      enabled: false,
    ),
    SettingItem(
      title: 'AirSpot Device Update',
      assetIcon: Assets.deviceUpdate,
      route: RouteNames.deviceUpdate,
    ),
    SettingItem(
      title: 'Recalibrate Device',
      assetIcon: Assets.recalibrateSettings,
      route: RouteNames.recalibrateSettings,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Device Settings'),
      ),
      body: ListView(
        children: [
          AlarmSettingWidget(deviceId: deviceId),
          VibrateSettingWidget(deviceId: deviceId),
          AutoConnectSettingWidget(deviceId: deviceId),
          ..._deviceSettingsList.map((item) => SettingItemWidget(
                item: item,
                onTap: () {
                  if (!ref
                      .read(bleDeviceConnectionProvider(deviceId).notifier)
                      .isConnected) {
                    context.showSnackBar('Device not connected');

                    Navigator.of(context).pop();
                    return;
                  }

                  if (item.suffixWidget != null) return;

                  if (item.route != null) {
                    context.pushNamed(item.route!,
                        pathParameters: {'deviceId': deviceId});
                  }
                },
              )),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor),
              onPressed: () {
                ref
                    .read(bleDeviceConnectionProvider(deviceId).notifier)
                    .disconnect();
                context.pop();
              },
              child: const Text('Disconnect Device'),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ForgetDeviceWidget(deviceId: deviceId),
          ),
        ],
      ),
    );
  }
}

class ForgetDeviceWidget extends ConsumerWidget {
  const ForgetDeviceWidget({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(deviceForgetStatusProvider(deviceId), (_, forgetStatus) {
      if (forgetStatus == const AsyncValue.data(true)) {
        context.showSnackBar('Device removed successfully');
        context.pop();
      }
    });

    final AsyncValue<bool> forgetStatus =
        ref.watch(deviceForgetStatusProvider(deviceId));

    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      onPressed: () {
        if (forgetStatus == const AsyncValue.loading()) return;

        ref.read(deviceForgetStatusProvider(deviceId).notifier).forget();
      },
      child: const Text('Forget This Device'),
    );
  }
}
