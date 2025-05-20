import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/icon_bg_widget.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/app_setup/providers/dev_mode_provider.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/alarm_setting_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/auto_connect_setting_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_data_dump_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_variant_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/disconnect_device_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/erase_device_record_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/factory_reset_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/forget_device_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/populate_fake_data_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/power_off_device_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/sensor_error_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/vibrate_setting_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar/isar.dart';

class DeviceSettingsPage extends ConsumerWidget {
  const DeviceSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  static final _deviceSettingsList = <SettingItem>[
    // SettingItem(
    //   title: 'High ${Constants.co2Text} Alert',
    //   assetIcon: Assets.co2Settings,
    //   route: RouteNames.co2Settings,
    //   enabled: true,
    // ),
    SettingItem(
      title: 'Device Screen Settings',
      assetIcon: Assets.screenSettings,
      route: RouteNames.screenSettings,
    ),
    SettingItem(
      title: 'Do Not Disturb',
      assetIcon: Assets.doNotDisturbSettings,
      route: RouteNames.doNotDisturbSettings,
    ),
    SettingItem(
      title: 'AirSpot Device Update',
      assetIcon: Assets.deviceUpdate,
      route: RouteNames.deviceUpdate,
    ),
    SettingItem(
      title: 'Calibrate Device',
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

    final bool devMode = ref.watch(devModeProvider);

    if (device == null) {
      ref.context.showSnackBar('Device with id $deviceId not found');
      context.pop();
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: DeviceSettingsNameWidget(deviceId: deviceId),
        actions: [
          if (devMode)
            IconButton(
              icon: Icon(Icons.data_array),
              onPressed: () {
                context.pushNamed(RouteNames.dataLog,
                    pathParameters: {'deviceId': deviceId});
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          AlarmSettingWidget(deviceId: deviceId),
          VibrateSettingWidget(deviceId: deviceId),
          AutoConnectSettingWidget(deviceId: deviceId),
          _buildTimeSettingWidget(ref),
          PowerModeSettingWidget(deviceId: deviceId),
          ..._buildSettingsList(ref),
          // DeviceDataDownloadSettingWidget(deviceId: deviceId),
          DisconnectDeviceWidget(device: device),
          ForgetDeviceWidget(deviceId: deviceId),
          PowerOffDeviceWidget(deviceId: deviceId),
          EraseDeviceRecordWidget(deviceId: deviceId),
          FactoryResetWidget(deviceId: deviceId),
          if (devMode) ...[
            const SizedBox(height: 16),
            Text(
              'Dev Settings',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SettingItemWidget(
              item: SettingItem(
                title: 'Sensor Configuration',
                assetIcon: Assets.recalibrateSettings,
                route: RouteNames.sensorConfiguration,
              ),
              onTap: () {
                ref.context.pushNamed(RouteNames.sensorConfiguration,
                    pathParameters: {'deviceId': deviceId});
              },
            ),
            SensorErrorWidget(deviceId: deviceId),
            PopulateFakeDataWidget(deviceId: deviceId),
            TurnOffBluetoothWidget(deviceId: deviceId),
            DeleteLocalCacheWidget(deviceId: deviceId),
            DeviceDataDumpWidget(deviceId: deviceId),
            // ImportCsvDataWidget(deviceId: deviceId),
            SetAscDurationWidget(deviceId: deviceId),
            DeviceVariantWidget(deviceId: deviceId),
            //RestartDeviceWidget(deviceId: deviceId),
          ],
        ],
      ),
    );
  }

  SettingItemWidget _buildTimeSettingWidget(WidgetRef ref) {
    return SettingItemWidget(
      item: SettingItem(
        title: 'Time Settings',
        assetIcon: Assets.timeSettings,
        route: RouteNames.timeSettings,
      ),
      onTap: () {
        if (!ref
            .read(bleDeviceConnectionProvider(deviceId).notifier)
            .isConnected) {
          ref.context.showSnackBar('Device not connected');

          Navigator.of(ref.context).pop();
          return;
        }

        ref.context.pushNamed(RouteNames.timeSettings,
            pathParameters: {'deviceId': deviceId});
      },
    );
  }

  Iterable<Widget> _buildSettingsList(WidgetRef ref) {
    return _deviceSettingsList.map(
      (item) => SettingItemWidget(
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
            ref.context
                .pushNamed(item.route!, pathParameters: {'deviceId': deviceId});
          }
        },
      ),
    );
  }
}

class PowerModeSettingWidget extends ConsumerWidget {
  const PowerModeSettingWidget({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PowerMode powerMode =
        ref.watch(deviceSettingsProvider(deviceId)).powerMode;

    return SettingItemWidget(
      item: SettingItem(
        title: '${Constants.co2Text} reading rate',
        assetIcon: powerMode.assetIcon,
        route: RouteNames.powerModeSettings,
      ),
      onTap: () {
        if (!ref
            .read(bleDeviceConnectionProvider(deviceId).notifier)
            .isConnected) {
          ref.context.showSnackBar('Device not connected');

          Navigator.of(ref.context).pop();
          return;
        }

        ref.context.pushNamed(RouteNames.powerModeSettings,
            pathParameters: {'deviceId': deviceId});
      },
    );
  }
}

class TurnOffBluetoothWidget extends ConsumerWidget {
  const TurnOffBluetoothWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingItemWidget(
      item: SettingItem(
        title: 'Turn off Device BT',
        assetIcon: Assets.autoConnectSettings,
        suffixWidget: const SizedBox(),
        leadingWidget: IconBgWidget(
            backgroundColor: Colors.deepPurpleAccent,
            child: Icon(Icons.bluetooth_disabled, color: Colors.black)),
      ),
      onTap: () {
        ref
            .read(bleDeviceCommunicationProvider(deviceId).notifier)
            .sendCommand(DeviceCmdUtils.turnOffBluetooth());
      },
    );
  }
}

class DeleteLocalCacheWidget extends ConsumerWidget {
  const DeleteLocalCacheWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingItemWidget(
      item: SettingItem(
        title: 'Delete Local Cache',
        assetIcon: Assets.autoConnectSettings,
        suffixWidget: const SizedBox(),
        leadingWidget: IconBgWidget(
            backgroundColor: Colors.deepOrange,
            child: Icon(Icons.delete, color: Colors.black)),
      ),
      onTap: () {
        ref.read(isarServiceProvider).write((isar) {
          isar.deviceDatas.where().deviceIdEqualTo(deviceId).deleteAll();
        });
        // remove last fetched date from the cache
        ref
            .read(bleSavedDevicesProvider.notifier)
            .resetDeviceFetchTime(deviceId);

        ref.invalidate(deviceHistoryDataRequestProvider(deviceId));

        ref.context.showSnackBar('Local cache deleted');
      },
    );
  }
}

class RestartDeviceWidget extends ConsumerWidget {
  const RestartDeviceWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingItemWidget(
      item: SettingItem(
        title: 'Restart Device',
        assetIcon: Assets.autoConnectSettings,
        leadingWidget: IconBgWidget(
          backgroundColor: Colors.deepPurpleAccent,
          child: Icon(Icons.restart_alt, color: Colors.black),
        ),
        suffixWidget: const SizedBox(),
      ),
      onTap: () {
        ref
            .read(bleDeviceCommunicationProvider(deviceId).notifier)
            .sendCommand(DeviceCmdUtils.restartDevice());
      },
    );
  }
}

class SetAscDurationWidget extends ConsumerWidget {
  const SetAscDurationWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(children: [
      IconBgWidget(
        backgroundColor: Colors.deepPurpleAccent,
        child: Icon(Icons.timer_outlined, color: Colors.black),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: TextFormField(
          onTapOutside: (value) {
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            isDense: true,
            labelText: 'ASC Duration (seconds)',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Duration is required';

            final int? duration = int.tryParse(value);

            if (duration == null) return 'Invalid duration';

            if (duration < 30) return 'Duration must be at least 30 seconds';

            return null;
          },
          onFieldSubmitted: (value) => _onDurationSubmitted(value, ref),
        ),
      ),
    ]);
  }

  void _onDurationSubmitted(String value, WidgetRef ref) {
    if (value.isEmpty) return;

    final int? duration = int.tryParse(value);

    if (duration == null) return;

    if (duration < 30) return;

    ref
        .read(bleDeviceCommunicationProvider(deviceId).notifier)
        .sendCommand(DeviceCmdUtils.setAscDuration(duration));
  }
}
