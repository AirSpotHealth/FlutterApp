import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/features/device_settings/widgets/device_version_update_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceUpdatePage extends ConsumerWidget {
  const DeviceUpdatePage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AirSpot Device Update'),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 64, child: AppLogo()),
        const SizedBox(height: 16),
        CurrentDeviceVersionWidget(
          version: deviceSettings.version,
        ),
        const SizedBox(height: 16),
        DeviceVersionUpdateWidget(deviceId: deviceId),
      ]),
    );
  }
}

class CurrentDeviceVersionWidget extends StatelessWidget {
  const CurrentDeviceVersionWidget({required this.version, super.key});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('Current Version: '),
          const Spacer(),
          Text(version.isEmpty ? 'N/A' : version),
        ],
      ),
    );
  }
}
