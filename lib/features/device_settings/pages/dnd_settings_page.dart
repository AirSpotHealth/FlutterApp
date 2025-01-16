import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DndSettingsPage extends ConsumerWidget {
  const DndSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: DeviceSettingsNameWidget(
            deviceId: deviceId, suffixText: 'Do not disturb Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildDndModeTile(context, ref, deviceSettings),
            if (deviceSettings.dndEnabled)
              _buildStartTimeTile(context, ref, deviceSettings),
            if (deviceSettings.dndEnabled)
              _buildEndTimeTile(context, ref, deviceSettings),
          ],
        ),
      ),
    );
  }

  Widget _buildDndModeTile(
      BuildContext context, WidgetRef ref, DeviceSettings deviceSettings) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      title: const Text(
        'Do not disturb',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      title: const Text(
        'Start time',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: deviceSettings.dndStartTime == null
          ? const Text(
              'Not set',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            )
          : Text(
              '${deviceSettings.dndStartTime!.hour.toString().padLeft(2, '0')}:${deviceSettings.dndStartTime!.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      title: const Text(
        'End time',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: deviceSettings.dndEndTime == null
          ? const Text(
              'Not set',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            )
          : Text(
              '${deviceSettings.dndEndTime!.hour.toString().padLeft(2, '0')}:${deviceSettings.dndEndTime!.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
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
