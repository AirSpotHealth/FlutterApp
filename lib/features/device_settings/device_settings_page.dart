import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/auto_connect_setting_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/disconnect_device_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/forget_device_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
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
      title: 'CO${Constants.subscript2} reading rate',
      assetIcon: Assets.powerModeSettings,
      route: RouteNames.powerModeSettings,
    ),
    SettingItem(
      title: 'High CO${Constants.subscript2} Alert',
      assetIcon: Assets.co2Settings,
      route: RouteNames.co2Settings,
      enabled: true,
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
    SettingItem(
      title: 'Locate my Airspot',
      assetIcon: Assets.findMyDevice,
      route: RouteNames.findMyDevice,
    )
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BleDevice? device = ref.read(bleDeviceProvider(deviceId));

    if (device == null) {
      ref.context.showSnackBar('Device with id $deviceId not found');
      context.pop();
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: DeviceSettingsNameWidget(deviceId: deviceId),
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          AutoConnectSettingWidget(deviceId: deviceId),
          ..._buildSettingsList(ref),
          DisconnectDeviceWidget(device: device),
          ForgetDeviceWidget(deviceId: deviceId),
        ],
      ),
    );
  }

  Iterable<Widget> _buildSettingsList(WidgetRef ref) {
    return _deviceSettingsList.map((item) => SettingItemWidget(
          item: item,
          onTap: () {
            if (!ref
                .read(bleDeviceConnectionProvider(deviceId).notifier)
                .isConnected) {
              ref.context.showSnackBar('Device not connected');

              Navigator.of(ref.context).pop();
              return;
            }

            if (item.suffixWidget != null) return;

            if (item.route != null) {
              ref.context.pushNamed(item.route!,
                  pathParameters: {'deviceId': deviceId});
            }
          },
        ));
  }
}
