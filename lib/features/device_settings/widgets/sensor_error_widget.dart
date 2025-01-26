import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/widgets/icon_bg_widget.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SensorErrorWidget extends ConsumerStatefulWidget {
  const SensorErrorWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SensorErrorWidgetState();
}

class _SensorErrorWidgetState extends ConsumerState<SensorErrorWidget> {
  bool _sensorError = false;

  @override
  Widget build(BuildContext context) {
    return SettingItemWidget(
        item: SettingItem(
          title: 'Test Sensor Error',
          leadingWidget: IconBgWidget(
            backgroundColor: Colors.teal,
            child: FaIcon(
              Icons.warning_amber,
              size: 22,
              color: Colors.black,
            ),
          ),
          suffixWidget: SizedBox(
            height: 24,
            child: Switch(
              value: _sensorError,
              onChanged: (value) {
                setState(() {
                  _sensorError = value;
                });

                ref
                    .read(bleDeviceCommunicationProvider(widget.deviceId)
                        .notifier)
                    .sendCommand(DeviceCmdUtils.setSensorError(_sensorError));
              },
            ),
          ),
          enabled: true,
        ),
        onTap: () {});
  }
}
