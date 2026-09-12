import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:airspothealth/core/providers/notification_preferences_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/utils/local_date_format.dart';
import 'package:airspothealth/core/widgets/custom_bottom_picker.dart';
import 'package:airspothealth/features/device_settings/widgets/device_time_picker_submit_button.dart';
import 'package:airspothealth/features/notification_settings/widgets/notification_settings_widgets.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thresholds, timing and quiet hours for smart notifications.
class NotificationAdvancedSettingsPage extends ConsumerWidget {
  const NotificationAdvancedSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  static const _defaultQuietStartHour = 22;
  static const _defaultQuietEndHour = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPreferencesProvider(deviceId));
    final notifier =
        ref.read(notificationPreferencesProvider(deviceId).notifier);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Advanced settings', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset thresholds and timing',
            onPressed: () async {
              await notifier.setThresholds(
                stuffy: NotificationPreferences.defaultStuffyThreshold,
                better: NotificationPreferences.defaultBetterThreshold,
                poor: NotificationPreferences.defaultPoorThreshold,
              );
              await notifier.setTiming(
                stuffyPersistMinutes:
                    NotificationPreferences.defaultStuffyPersistMinutes,
                betterPersistMinutes:
                    NotificationPreferences.defaultBetterPersistMinutes,
                poorPersistMinutes:
                    NotificationPreferences.defaultPoorPersistMinutes,
                reminderMinutes: NotificationPreferences.defaultReminderMinutes,
                highPriorityReminderMinutes: NotificationPreferences
                    .defaultHighPriorityReminderMinutes,
                recoveryMinutes: NotificationPreferences.defaultRecoveryMinutes,
              );
              await notifier.setQuietHours(enabled: false);
              if (context.mounted) {
                context.showSnackBar('Advanced settings reset to defaults');
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const SettingsSectionHeader('Thresholds'),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Each state must stay above its threshold for the time below before AirSpot notifies you. Levels must increase from stuffy to poor.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          SettingsCard(children: [
            _thresholdRow(
              context,
              level: VentilationLevel.stuffy,
              title: 'Air is getting stuffy',
              value: prefs.stuffyThreshold,
              onPick: (v) {
                if (v >= prefs.betterThreshold) {
                  context.showSnackBar(
                      'Must be below the ${VentilationCopy.ppm(prefs.betterThreshold)} ppm level');
                  return;
                }
                notifier.setThresholds(stuffy: v);
              },
            ),
            _thresholdRow(
              context,
              level: VentilationLevel.better,
              title: 'Ventilation could be better',
              value: prefs.betterThreshold,
              onPick: (v) {
                if (v <= prefs.stuffyThreshold || v >= prefs.poorThreshold) {
                  context.showSnackBar(
                      'Must be between the stuffy and poor levels');
                  return;
                }
                notifier.setThresholds(better: v);
              },
            ),
            _thresholdRow(
              context,
              level: VentilationLevel.poor,
              title: 'Poor ventilation',
              value: prefs.poorThreshold,
              onPick: (v) {
                if (v <= prefs.betterThreshold) {
                  context.showSnackBar(
                      'Must be above the ${VentilationCopy.ppm(prefs.betterThreshold)} ppm level');
                  return;
                }
                notifier.setThresholds(poor: v);
              },
            ),
          ]),
          const SettingsSectionHeader('Timing'),
          SettingsCard(children: [
            _minutesRow(context,
                title: 'Stuffy air must persist for',
                value: prefs.stuffyPersistMinutes,
                min: 1,
                max: 60,
                onPick: (v) => notifier.setTiming(stuffyPersistMinutes: v)),
            _minutesRow(context,
                title: 'Ventilation could be better after',
                value: prefs.betterPersistMinutes,
                min: 1,
                max: 60,
                onPick: (v) => notifier.setTiming(betterPersistMinutes: v)),
            _minutesRow(context,
                title: 'Poor ventilation after',
                value: prefs.poorPersistMinutes,
                min: 1,
                max: 60,
                onPick: (v) => notifier.setTiming(poorPersistMinutes: v)),
            _minutesRow(context,
                title: 'Reminder interval',
                value: prefs.reminderMinutes,
                min: 1,
                max: 60,
                onPick: (v) => notifier.setTiming(reminderMinutes: v)),
            _minutesRow(context,
                title: 'Reminder interval for poor ventilation',
                value: prefs.highPriorityReminderMinutes,
                min: 1,
                max: 60,
                onPick: (v) =>
                    notifier.setTiming(highPriorityReminderMinutes: v)),
            _minutesRow(context,
                title: 'Air counts as improved after',
                subtitle: 'Time below the stuffy level',
                value: prefs.recoveryMinutes,
                min: 1,
                max: 30,
                onPick: (v) => notifier.setTiming(recoveryMinutes: v)),
          ]),
          const SettingsSectionHeader('Quiet hours'),
          SettingsCard(children: [
            SettingsSwitchRow(
              title: 'Quiet hours',
              subtitle: 'Pause notifications during these hours',
              value: prefs.quietHoursEnabled,
              activeColor: AppColors.ventGreen,
              onChanged: (v) => notifier.setQuietHours(
                enabled: v,
                start: prefs.quietHoursStart ??
                    DateTime.now().copyWith(
                        hour: _defaultQuietStartHour, minute: 0),
                end: prefs.quietHoursEnd ??
                    DateTime.now()
                        .copyWith(hour: _defaultQuietEndHour, minute: 0),
              ),
            ),
            if (prefs.quietHoursEnabled) ...[
              _timeRow(context, ref,
                  title: 'Start time',
                  time: prefs.quietHoursStart,
                  defaultHour: _defaultQuietStartHour,
                  onPick: (t) => notifier.setQuietHours(start: t)),
              _timeRow(context, ref,
                  title: 'End time',
                  time: prefs.quietHoursEnd,
                  defaultHour: _defaultQuietEndHour,
                  onPick: (t) => notifier.setQuietHours(end: t)),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _thresholdRow(
    BuildContext context, {
    required VentilationLevel level,
    required String title,
    required int value,
    required ValueChanged<int> onPick,
  }) {
    return SettingsValueRow(
      title: title,
      value: '${VentilationCopy.ppm(value)} ppm',
      leading: Icon(level.icon, color: level.color),
      onTap: () => CustomBottomPicker.showNumeric(
        context: context,
        min: 400,
        max: 3000,
        step: 50,
        initialValue: value,
        title: title,
        suffix: 'ppm',
        onSubmit: onPick,
      ),
    );
  }

  Widget _minutesRow(
    BuildContext context, {
    required String title,
    String? subtitle,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onPick,
  }) {
    return SettingsValueRow(
      title: title,
      subtitle: subtitle,
      value: '$value min',
      onTap: () => CustomBottomPicker.showNumeric(
        context: context,
        min: min,
        max: max,
        initialValue: value,
        title: title,
        suffix: 'min',
        onSubmit: onPick,
      ),
    );
  }

  Widget _timeRow(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required DateTime? time,
    required int defaultHour,
    required ValueChanged<DateTime> onPick,
  }) {
    final bool is12Hour =
        LocalDateFormat.instance.systemTimeFormat.pattern!.contains('a');
    final label = time == null
        ? 'Not set'
        : is12Hour
            ? time.format12Hour()
            : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return SettingsValueRow(
      title: title,
      value: label,
      onTap: () {
        BottomPicker.time(
          headerBuilder: (context) => Text('Select ${title.toLowerCase()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          initialTime: Time(
            hours: time?.hour ?? defaultHour,
            minutes: time?.minute ?? 0,
          ),
          dismissable: true,
          use24hFormat: !is12Hour,
          buttonBuilder: (instance, context) => DeviceTimePickerSubmitButton(
            picker: instance,
            onTimeSelected: (picked) => onPick(DateTime.now()
                .copyWith(hour: picked.hour, minute: picked.minute)),
          ),
        ).show(context);
      },
    );
  }
}
