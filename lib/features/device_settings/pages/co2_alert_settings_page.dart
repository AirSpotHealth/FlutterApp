import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/widgets/alarm_setting_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/amber_alert_setting_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/red_alert_setting_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/vibrate_setting_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Co2AlertSettingsPage extends ConsumerWidget {
  const Co2AlertSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: DeviceSettingsNameWidget(
        deviceId: deviceId,
        suffixText: 'High CO${Constants.subscript2} alert Settings',
      )),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'ALARM LEVELS',
            style: context.textTheme.bodyMedium?.weight500?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          RangeSlider(
            values: const RangeValues(800, 1000),
            onChanged: (value) {},
            min: 0,
            max: 2000,
            divisions: 40,
            labels: const RangeLabels('800', '1000'),
          ),
          const SizedBox(height: 16),
          Text(
            'Set the range of CO2 ppm levels that will be considered as amber and red alert levels.',
            style: context.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Text(
            'AIRSPOT ALERTS',
            style: context.textTheme.bodyMedium?.weight500?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          AlarmSettingWidget(deviceId: deviceId),
          VibrateSettingWidget(deviceId: deviceId),
          const SizedBox(height: 16),
          Text(
            'NOTIFICATIONS',
            style: context.textTheme.bodyMedium?.weight500?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          AmberAlertSettingWidget(deviceId: deviceId),
          RedAlertSettingWidget(deviceId: deviceId),
          const SizedBox(height: 16),
          Text(
            'When turned on respective Co2 alert notifications will appear on this device.',
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
