import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/find_my_device/widgets/device_mock_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FindMyDevicePage extends ConsumerWidget {
  const FindMyDevicePage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BleDevice? devices =
        ref.read(bleSavedDevicesProvider.notifier).getDeviceById(deviceId);

    if (devices == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Locate My Airspot'),
        ),
        body: const Center(
          child: Text('Device not found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            DeviceSettingsNameWidget(deviceId: deviceId, suffixText: 'Locate'),
      ),
      body: Column(
        children: [
          Flexible(child: DeviceMockWidget(device: devices)),
          const SizedBox(height: 32),
          const Text(
            'Tap on the device to find it. It will deliver a 5-second alarm to your Bluetooth-linked device.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
