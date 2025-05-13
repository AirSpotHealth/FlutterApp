import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/advanced_alarm_settings/providers/advanced_alarm_settings_provider.dart';
import 'package:airspothealth/features/advanced_alarm_settings/widgets/alarm_level_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdvancedAlarmSettingsPage extends ConsumerStatefulWidget {
  final String deviceId;
  const AdvancedAlarmSettingsPage({super.key, required this.deviceId});

  @override
  ConsumerState<AdvancedAlarmSettingsPage> createState() =>
      _AdvancedAlarmSettingsPageState();
}

class _AdvancedAlarmSettingsPageState
    extends ConsumerState<AdvancedAlarmSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final alarmSettings =
        ref.watch(advancedAlarmSettingsProvider(widget.deviceId));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Advanced Alarm Settings'), actions: [
        IconButton(
          icon: const Icon(Icons.restore),
          tooltip: 'Reset to Defaults',
          onPressed: () {
            ref
                .read(advancedAlarmSettingsProvider(widget.deviceId).notifier)
                .resetToDefaults();

            context.showSnackBar('Alarm settings reset to defaults');
          },
        )
      ]),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildScreenOnAlarmSetting(alarmSettings.screenOnAlarm),
          const SizedBox(height: 12),
          _buildAlarmOnCo2FallSetting(alarmSettings.alarmOnCo2Fall),
          const SizedBox(height: 12),
          _buildAlarmLevelsSection(alarmSettings.alarmLevels, false),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildScreenOnAlarmSetting(bool enabled) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            title: const Text(
              'Screen Illumination',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Turn on screen when alarm triggers',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            trailing: Switch(
              value: enabled,
              onChanged: (value) {
                ref
                    .read(
                        advancedAlarmSettingsProvider(widget.deviceId).notifier)
                    .setScreenOnAlarm(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmOnCo2FallSetting(bool enabled) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            title: const Text(
              'Alarm on CO2 Fall',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Trigger alarm on co2 fall',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            trailing: Switch(
              value: enabled,
              onChanged: (value) {
                ref
                    .read(
                        advancedAlarmSettingsProvider(widget.deviceId).notifier)
                    .setAlarmOnCo2Fall(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmLevelsSection(
      List<AlarmLevel> alarmLevels, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.notifications_active_outlined,
                  size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text('Alarm Levels',
                  style: context.textTheme.bodyMedium?.weight600),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "You can set the number of times the device beeps and/or vibrates when a certain co2 level is reached. You can also set the co2 level at which the alarm triggers.",
          style: context.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text('CO2 (ppm)',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.grey.shade700))),
                    Expanded(
                        child: Text('Repeats',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.grey.shade700))),
                    Expanded(
                        child: Text('Enabled',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.grey.shade700))),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListView.separated(
                shrinkWrap: true,
                itemCount: alarmLevels.length,
                physics: ClampingScrollPhysics(),
                separatorBuilder: (context, index) {
                  return const Divider(height: 1, indent: 12, endIndent: 12);
                },
                itemBuilder: (context, index) {
                  final alarm = alarmLevels[index];
                  return AlarmLevelRow(
                    alarm: alarm,
                    index: index,
                    deviceId: widget.deviceId,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
