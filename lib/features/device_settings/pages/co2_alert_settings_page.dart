import 'package:airspothealth/features/device_settings/widgets/co2_ppm_range_picker_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
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
        suffixText: 'Graph Zones',
      )),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Co2PpmRangePickerWidget(deviceId: deviceId),
      ),
    );
  }
}
