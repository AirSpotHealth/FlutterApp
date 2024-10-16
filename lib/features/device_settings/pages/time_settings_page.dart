import 'package:airspothealth/core/providers/device_settings_provider.dart';
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
  @override
  Widget build(BuildContext context) {
    final bool autoSyncTime =
        ref.watch(deviceSettingsProvider(widget.deviceId)).autoSyncTime;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Time Settings'),
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
                    onTimerDurationChanged: (value) {},
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: Duration(
                        hours: DateTime.now().hour,
                        minutes: DateTime.now().minute),
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
