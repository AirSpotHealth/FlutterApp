import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
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
      body: devices.deviceModel == DeviceModel.airspotSlim
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 64),
                    const SizedBox(height: 24),
                    const Text(
                      'While connected, flash Slim’s white LED for 5 seconds to help find it.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Flash Slim LED'),
                      onPressed: () async {
                        final sent = await ref
                            .read(bleDeviceCommunicationProvider(deviceId)
                                .notifier)
                            .sendCommand(DeviceCmdUtils.findDevice());
                        if (context.mounted && !sent) {
                          context.showSnackBar(
                              'Connect to Slim to flash its LED.');
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          : Column(
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
