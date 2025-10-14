import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:airspothealth/core/providers/notification_preferences_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/custom_bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingsPage extends ConsumerWidget {
  final String deviceId;

  const NotificationSettingsPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(notificationPreferencesProvider(deviceId));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to Defaults',
            onPressed: () async {
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
                if (context.mounted) {
                  context.showSnackBar('Settings reset to defaults');
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEnableNotificationsCard(context, ref, preferences),
          const SizedBox(height: 16),
          if (preferences.smartphoneNotificationsEnabled) ...[
            _buildNotificationOptionsCard(context, ref, preferences),
            const SizedBox(height: 16),
            _buildCooldownCard(context, ref, preferences),
            const SizedBox(height: 16),
            _buildThresholdsCard(context, ref, preferences),
          ],
        ],
      ),
    );
  }

  Widget _buildEnableNotificationsCard(BuildContext context, WidgetRef ref,
      NotificationPreferences preferences) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Enable Smartphone Notifications',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Receive alerts on your phone when CO₂ levels are high',
            ),
            value: preferences.smartphoneNotificationsEnabled,
            onChanged: (value) {
              ref
                  .read(notificationPreferencesProvider(deviceId).notifier)
                  .toggleSmartphoneNotifications(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOptionsCard(BuildContext context, WidgetRef ref,
      NotificationPreferences preferences) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Notification Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SwitchListTile(
            title: const Text('Sound'),
            subtitle: const Text('Play sound with notification'),
            value: preferences.notificationSoundEnabled,
            onChanged: (value) {
              ref
                  .read(notificationPreferencesProvider(deviceId).notifier)
                  .updatePreferences(
                    (prefs) => prefs.copyWith(notificationSoundEnabled: value),
                  );
            },
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            subtitle: const Text('Vibrate with notification'),
            value: preferences.notificationVibrationEnabled,
            onChanged: (value) {
              ref
                  .read(notificationPreferencesProvider(deviceId).notifier)
                  .updatePreferences(
                    (prefs) =>
                        prefs.copyWith(notificationVibrationEnabled: value),
                  );
            },
          ),
          SwitchListTile(
            title: const Text('Show in Foreground'),
            subtitle: const Text('Show notifications even when app is open'),
            value: preferences.showInForeground,
            onChanged: (value) {
              ref
                  .read(notificationPreferencesProvider(deviceId).notifier)
                  .updatePreferences(
                    (prefs) => prefs.copyWith(showInForeground: value),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCooldownCard(BuildContext context, WidgetRef ref,
      NotificationPreferences preferences) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Notification Cooldown'),
            subtitle: Text(
              preferences.cooldownMode == 'once'
                  ? 'Notify once per threshold crossing'
                  : 'Minimum ${preferences.cooldownMinutes} minutes between notifications',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showCooldownModePicker(context, ref, preferences);
            },
          ),
          if (preferences.cooldownMode == 'time') ...[
            const Divider(height: 1),
            ListTile(
              title: const Text('Cooldown Duration'),
              subtitle: Text('${preferences.cooldownMinutes} minutes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showCooldownPicker(context, ref, preferences);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThresholdsCard(BuildContext context, WidgetRef ref,
      NotificationPreferences preferences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.notifications_active_outlined,
                  size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'CO₂ Alert Thresholds',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Configure when to receive notifications based on CO₂ levels',
          style: context.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'CO₂ (ppm)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Enabled',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 12, endIndent: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: preferences.notificationThresholds.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 12, endIndent: 12),
                itemBuilder: (context, index) {
                  final threshold = preferences.notificationThresholds[index];
                  if (threshold.co2Threshold == 0) {
                    return const SizedBox.shrink();
                  }
                  return _buildThresholdRow(
                      context, ref, preferences, threshold, index);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThresholdRow(
    BuildContext context,
    WidgetRef ref,
    NotificationPreferences preferences,
    NotificationThreshold threshold,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _showThresholdEditor(
                  context, ref, preferences, threshold, index),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${threshold.co2Threshold}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ppm',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Switch(
              value: threshold.enabled,
              onChanged: (value) {
                ref
                    .read(notificationPreferencesProvider(deviceId).notifier)
                    .updateThreshold(
                      index,
                      threshold.copyWith(enabled: value),
                    );
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  void _showCooldownModePicker(BuildContext context, WidgetRef ref,
      NotificationPreferences preferences) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notification Cooldown Mode',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Once Per Crossing'),
              subtitle: const Text(
                'Notify only when CO₂ crosses above a threshold, then again only when it goes below and crosses above again',
              ),
              leading: Icon(
                preferences.cooldownMode == 'once'
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: preferences.cooldownMode == 'once'
                    ? Theme.of(context).primaryColor
                    : null,
              ),
              onTap: () {
                ref
                    .read(notificationPreferencesProvider(deviceId).notifier)
                    .updateCooldownMode('once');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Time-Based'),
              subtitle: const Text(
                'Notify based on time intervals between notifications',
              ),
              leading: Icon(
                preferences.cooldownMode == 'time'
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: preferences.cooldownMode == 'time'
                    ? Theme.of(context).primaryColor
                    : null,
              ),
              onTap: () {
                ref
                    .read(notificationPreferencesProvider(deviceId).notifier)
                    .updateCooldownMode('time');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCooldownPicker(BuildContext context, WidgetRef ref,
      NotificationPreferences preferences) {
    CustomBottomPicker.showNumeric(
      context: context,
      min: 1,
      max: 60,
      step: 1,
      initialValue: preferences.cooldownMinutes,
      title: 'Cooldown Period (minutes)',
      onSubmit: (value) {
        ref
            .read(notificationPreferencesProvider(deviceId).notifier)
            .updateCooldown(value);
      },
    );
  }

  void _showThresholdEditor(
    BuildContext context,
    WidgetRef ref,
    NotificationPreferences preferences,
    NotificationThreshold threshold,
    int index,
  ) {
    final messageController =
        TextEditingController(text: threshold.message ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${threshold.co2Threshold} ppm Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Custom Message',
                hintText: 'e.g., High CO₂ detected!',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(notificationPreferencesProvider(deviceId).notifier)
                  .updateThreshold(
                    index,
                    threshold.copyWith(
                      message: messageController.text.isEmpty
                          ? null
                          : messageController.text,
                    ),
                  );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
