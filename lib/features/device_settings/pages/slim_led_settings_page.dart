import 'package:airspothealth/features/device_settings/widgets/co2_ppm_range_picker_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:flutter/material.dart';

class SlimLedSettingsPage extends StatelessWidget {
  const SlimLedSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: DeviceSettingsNameWidget(
          deviceId: deviceId,
          suffixText: 'CO₂ Zone Settings',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Choose the CO₂ levels at which your Slim’s LED changes from green to amber and from amber to red. These limits are sent to the device.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Co2PpmRangePickerWidget(deviceId: deviceId, useAmberLabels: true),
        ],
      ),
    );
  }
}
