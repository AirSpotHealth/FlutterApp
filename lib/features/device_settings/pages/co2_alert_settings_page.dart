import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/widgets/amber_alert_setting_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/co2_ppm_range_picker_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/red_alert_setting_widget.dart';
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
          _buildLabel(context, 'THRESHOLD LEVELS'),
          const SizedBox(height: 24),
          Co2PpmRangePickerWidget(deviceId: deviceId),
          const SizedBox(height: 16),
          _buildInfoText(context,
              'Set the range of CO2 ppm levels that will be considered as amber and red alert levels.'),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLabel(context, 'NOTIFICATIONS'),
              const SizedBox(width: 4),
              const Icon(
                Icons.phone_android_outlined,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
          AmberAlertSettingWidget(deviceId: deviceId),
          RedAlertSettingWidget(deviceId: deviceId),
          const SizedBox(height: 16),
          _buildInfoText(context,
              'When turned on respective Co2 alert notifications will appear on this device.'),
        ],
      ),
    );
  }

  Text _buildInfoText(BuildContext context, String text) {
    return Text(text,
        style: context.textTheme.bodySmall?.copyWith(color: Colors.black54));
  }

  Text _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: context.textTheme.bodyMedium?.weight500?.copyWith(
        color: Colors.grey.shade600,
      ),
    );
  }
}
