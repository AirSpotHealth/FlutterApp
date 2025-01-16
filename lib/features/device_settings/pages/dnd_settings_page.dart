import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DndSettingsPage extends ConsumerWidget {
  const DndSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    final BleDevice bleDevice = ref.watch(bleDeviceProvider(deviceId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            '${bleDevice.alias ?? bleDevice.name} ${Constants.co2Text} DND settings'),
      ),
      body: Column(
        children: [
          _buildDndModeTile(context, ref, deviceSettings),
          _buildStartTimeTile(context, ref, deviceSettings),
          _buildEndTimeTile(context, ref, deviceSettings),
        ],
      ),
    );
  }

  Widget _buildDndModeTile(
      BuildContext context, WidgetRef ref, DeviceSettings deviceSettings) {
    return ListTile(
      title: const Text('DND mode'),
      subtitle: const Text('Turn on DND mode'),
      trailing: Switch(
        value: deviceSettings.dndEnabled,
        onChanged: (value) {
          ref.read(deviceSettingsProvider(deviceId).notifier).updateSettings(
              deviceSettings.copyWith(
                  dndEnabled: value,
                  dndStartTime: deviceSettings.dndStartTime ??
                      deviceSettings.defaultDndStartTime,
                  dndEndTime: deviceSettings.dndEndTime ??
                      deviceSettings.defaultDndEndTime));
        },
      ),
    );
  }

  Widget _buildStartTimeTile(
      BuildContext context, WidgetRef ref, DeviceSettings deviceSettings) {
    return ListTile(
      title: const Text('Start time'),
      subtitle: deviceSettings.dndStartTime == null
          ? const Text('Not set')
          : Text(
              '${deviceSettings.dndStartTime!.hour}:${deviceSettings.dndStartTime!.minute}'),
      onTap: () async {
        final TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: deviceSettings.dndStartTime?.timeOfDay ??
              const TimeOfDay(hour: 22, minute: 0),
        );

        if (selectedTime != null) {
          ref.read(deviceSettingsProvider(deviceId).notifier).updateSettings(
                deviceSettings.copyWith(
                  dndStartTime: DateTime.now().copyWith(
                    hour: selectedTime.hour,
                    minute: selectedTime.minute,
                  ),
                ),
              );
        }
      },
    );
  }

  Widget _buildEndTimeTile(
      BuildContext context, WidgetRef ref, DeviceSettings deviceSettings) {
    return ListTile(
      title: const Text('End time'),
      subtitle: deviceSettings.dndEndTime == null
          ? const Text('Not set')
          : Text(
              '${deviceSettings.dndEndTime!.hour}:${deviceSettings.dndEndTime!.minute}'),
      onTap: () async {
        final TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: deviceSettings.dndEndTime?.timeOfDay ??
              const TimeOfDay(hour: 6, minute: 0),
        );

        if (selectedTime != null) {
          ref.read(deviceSettingsProvider(deviceId).notifier).updateSettings(
              deviceSettings.copyWith(
                  dndEndTime: DateTime.now().copyWith(
                      hour: selectedTime.hour, minute: selectedTime.minute)));
        }
      },
    );
  }
}
