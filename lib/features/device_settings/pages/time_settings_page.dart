import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimeSettingsPage extends ConsumerStatefulWidget {
  const TimeSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TimeSettingsPageState();
}

class _TimeSettingsPageState extends ConsumerState<TimeSettingsPage> {
  int _selectedHour = DateTime.now().hour;

  int _selectedMinute = DateTime.now().minute;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(deviceSettingsProvider(widget.deviceId)).autoSyncTime) {
        _syncTime();
      }
    });
  }

  void _syncTime() {
    ref
        .read(bleDeviceCommunicationProvider(widget.deviceId).notifier)
        .sendCommand(DeviceCmdUtils.setTime());
  }

  @override
  Widget build(BuildContext context) {
    final bool autoSyncTime =
        ref.watch(deviceSettingsProvider(widget.deviceId)).autoSyncTime;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: DeviceSettingsNameWidget(
            deviceId: widget.deviceId, suffixText: 'Time Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sync with mobile device'),
            value: autoSyncTime,
            onChanged: (value) {
              ref
                  .read(deviceSettingsProvider(widget.deviceId).notifier)
                  .updateSettings(
                    ref
                        .watch(deviceSettingsProvider(widget.deviceId))
                        .copyWith(autoSyncTime: !autoSyncTime),
                  );
            },
          ),
          if (!autoSyncTime) ...[
            const Divider(),
            Row(
              children: [
                const Text('Set Manually'),
                const SizedBox(width: 16),
                Expanded(
                  child: CupertinoTimerPicker(
                    onTimerDurationChanged: (value) {
                      _selectedHour = value.inHours;
                      _selectedMinute = value.inMinutes.remainder(60);
                    },
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: Duration(
                      hours: _selectedHour,
                      minutes: _selectedMinute,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Confirm'),
            ),
          ]
        ],
      ),
    );
  }
}
