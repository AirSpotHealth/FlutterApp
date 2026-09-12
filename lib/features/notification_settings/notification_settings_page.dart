import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/providers/notification_preferences_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/services/notification_service.dart';
import 'package:airspothealth/core/services/ventilation_action_handler.dart';
import 'package:airspothealth/core/services/ventilation_notification_coordinator.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/app_setup/providers/dev_mode_provider.dart';
import 'package:airspothealth/features/notification_settings/widgets/notification_settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Smart notification settings for one device (Screen or Slim).
class NotificationSettingsPage extends ConsumerWidget {
  final String deviceId;

  const NotificationSettingsPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPreferencesProvider(deviceId));
    final notifier = ref.read(notificationPreferencesProvider(deviceId).notifier);
    final powerMode = ref.watch(deviceSettingsProvider(deviceId)).powerMode;
    final devMode = ref.watch(devModeProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to Defaults',
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const SettingsSectionHeader('Air notifications'),
          SettingsCard(children: [
            SettingsSwitchRow(
              title: VentilationCopy.smartNotificationsTitle,
              subtitle: VentilationCopy.smartNotificationsSubtitle,
              value: prefs.smartNotificationsEnabled,
              activeColor: AppColors.ventGreen,
              onChanged: (v) {
                notifier.setSmartNotifications(v);
                if (!v) {
                  ref
                      .read(ventilationCoordinatorProvider)
                      .onNotificationsDisabled(deviceId);
                }
              },
            ),
          ]),
          if (powerMode == PowerMode.onDemand && prefs.smartNotificationsEnabled)
            _ReadingRateHint(deviceId: deviceId),
          if (prefs.smartNotificationsEnabled) ...[
            const SettingsSectionHeader('Notify me when'),
            SettingsCard(children: [
              SettingsSwitchRow(
                title: 'Air is getting stuffy',
                subtitle:
                    'CO₂ remains above ${VentilationCopy.ppm(prefs.stuffyThreshold)} ppm',
                value: prefs.notifyStuffy,
                activeColor: VentilationLevel.stuffy.color,
                onChanged: notifier.setNotifyStuffy,
              ),
              SettingsSwitchRow(
                title: 'Ventilation is poor',
                subtitle:
                    'CO₂ remains above ${VentilationCopy.ppm(prefs.poorThreshold)} ppm',
                value: prefs.notifyPoor,
                activeColor: VentilationLevel.poor.color,
                onChanged: notifier.setNotifyPoor,
              ),
              SettingsSwitchRow(
                title: 'Air improves again',
                subtitle: 'See when your action appears to have worked',
                value: prefs.notifyImproved,
                activeColor: VentilationLevel.none.color,
                onChanged: notifier.setNotifyImproved,
              ),
            ]),
            const SettingsSectionHeader('Notification behaviour'),
            SettingsCard(children: [
              SettingsSwitchRow(
                title: 'Vibration',
                subtitle: 'Vibrate with notifications',
                value: prefs.vibrationEnabled,
                activeColor: AppColors.ventGreen,
                onChanged: notifier.setVibration,
              ),
              SettingsSwitchRow(
                title: 'Show while using AirSpot',
                subtitle: 'Show notifications when the app is open',
                value: prefs.showInForeground,
                activeColor: AppColors.ventGreen,
                onChanged: notifier.setShowInForeground,
              ),
              SettingsSwitchRow(
                title: 'Reminders',
                subtitle:
                    'Remind me after ${prefs.reminderMinutes} minutes if conditions have not improved',
                value: prefs.remindersEnabled,
                activeColor: AppColors.ventGreen,
                onChanged: notifier.setReminders,
              ),
            ]),
            const SettingsSectionHeader('More control'),
            SettingsCard(children: [
              SettingsLinkRow(
                title: 'Advanced settings',
                subtitle: 'Thresholds, timing, quiet hours',
                onTap: () => context.pushNamed(
                  RouteNames.notificationAdvancedSettings,
                  pathParameters: {'deviceId': deviceId},
                ),
              ),
              SettingsLinkRow(
                title: 'Notification history',
                subtitle: 'Review alerts, actions and improvements',
                onTap: () => context.pushNamed(
                  RouteNames.notificationHistory,
                  pathParameters: {'deviceId': deviceId},
                ),
              ),
            ]),
          ] else ...[
            const SettingsSectionHeader('More control'),
            SettingsCard(children: [
              SettingsLinkRow(
                title: 'Notification history',
                subtitle: 'Review alerts, actions and improvements',
                onTap: () => context.pushNamed(
                  RouteNames.notificationHistory,
                  pathParameters: {'deviceId': deviceId},
                ),
              ),
            ]),
          ],
          if (devMode) ...[
            const SettingsSectionHeader('Dev'),
            SettingsCard(children: [
              for (final level in VentilationLevel.values)
                SettingsLinkRow(
                  title: level == VentilationLevel.none
                      ? 'Test: ${VentilationCopy.recoveryTitle}'
                      : 'Test: ${level.title}',
                  subtitle:
                      'Sends a system notification with buttons (no engine state)',
                  onTap: () => _sendTestNotification(prefs, level),
                ),
            ]),
          ],
        ],
      ),
    );
  }

  /// Dev only: exercise the notification pipeline without waiting for the
  /// persistence timers. Actions on it are harmless (no active event).
  Future<void> _sendTestNotification(
      NotificationPreferences prefs, VentilationLevel level) {
    final isRecovery = level == VentilationLevel.none;
    final kind = isRecovery
        ? VentilationNotificationKind.recovery
        : VentilationNotificationKind.alert;
    final title = isRecovery ? VentilationCopy.recoveryTitle : level.title;
    final body = isRecovery
        ? VentilationCopy.recoveryBody(
            peakValue: 1420,
            currentValue: 760,
            elapsed: const Duration(minutes: 12))
        : VentilationCopy.body(
            level: level,
            currentValue: 840,
            betterThreshold: prefs.betterThreshold,
            betterPersistMinutes: prefs.betterPersistMinutes,
            poorThreshold: prefs.poorThreshold);
    return NotificationService.showVentilationNotification(
      deviceId: deviceId,
      deviceName: 'Test',
      level: level,
      kind: kind,
      title: title,
      body: body,
      reminderMinutes: VentilationCopy.reminderMinutesFor(level,
          reminderMinutes: prefs.reminderMinutes,
          highPriorityReminderMinutes: prefs.highPriorityReminderMinutes),
      remindersEnabled: prefs.remindersEnabled,
      payload: VentilationPayload(
              deviceId: deviceId, eventId: 'test', level: level, kind: kind)
          .encode(),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
            'Are you sure you want to reset all notification settings to defaults?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref
          .read(notificationPreferencesProvider(deviceId).notifier)
          .resetToDefaults();
      await ref
          .read(ventilationCoordinatorProvider)
          .onNotificationsDisabled(deviceId);
      if (context.mounted) context.showSnackBar('Settings reset to defaults');
    }
  }
}

/// Persistence needs a steady stream of readings; the "Now" reading rate only
/// sends a value on request, for Screen and Slim alike.
class _ReadingRateHint extends StatelessWidget {
  const _ReadingRateHint({required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.ventAmberPale,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.ventAmber.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.ventAmber, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'This device only sends a reading when asked. Set the CO₂ reading rate to 1 min or faster so AirSpot can tell when air stays stuffy.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: () => context.pushNamed(
              RouteNames.powerModeSettings,
              pathParameters: {'deviceId': deviceId},
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}
