import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/widgets/icon_bg_widget.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DeviceSensorErrorsWidget extends ConsumerWidget {
  const DeviceSensorErrorsWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingItemWidget(
        item: SettingItem(
          title: 'Get Sensor Errors',
          leadingWidget: IconBgWidget(
            backgroundColor: Colors.teal,
            child: FaIcon(
              Icons.error_outline,
              size: 22,
              color: Colors.teal,
            ),
          ),
          enabled: true,
          suffixWidget: Icon(
            FontAwesomeIcons.arrowRotateRight,
            size: 16,
            color: Colors.teal,
          ),
        ),
        onTap: () {
          ref
              .read(bleDeviceCommunicationProvider(deviceId).notifier)
              .sendCommand(DeviceCmdUtils.getSensorErrors());
        });
  }
}
