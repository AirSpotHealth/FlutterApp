// ignore_for_file: use_build_context_synchronously

import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/button.dart';
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
    // Watch individual providers
    final alarmLevelsState =
        ref.watch(advancedAlarmSettingsProvider(widget.deviceId));
    final screenIlluminationEnabled =
        ref.watch(screenIlluminationSettingsProvider(widget.deviceId));
    final alarmOnCo2FallEnabled =
        ref.watch(alarmOnCo2FallSettingProvider(widget.deviceId));

    // Read notifiers
    final alarmLevelsNotifier =
        ref.read(advancedAlarmSettingsProvider(widget.deviceId).notifier);
    final screenIlluminationNotifier =
        ref.read(screenIlluminationSettingsProvider(widget.deviceId).notifier);
    final alarmOnCo2FallNotifier =
        ref.read(alarmOnCo2FallSettingProvider(widget.deviceId).notifier);

    // Global save button now only depends on alarm levels changes
    final bool hasUnsavedChanges = alarmLevelsNotifier.hasUnsavedChanges;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Advanced Alarm Settings',
            style: TextStyle(fontSize: 18)), // Slightly smaller title
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to Defaults',
            onPressed: () async {
              // Only call the main reset method on alarmLevelsNotifier
              await alarmLevelsNotifier.resetAlarmLevelsToDefaults();
              // screenIlluminationNotifier.resetToDefault(); // No longer called from here
              // alarmOnCo2FallNotifier.resetToDefault(); // No longer called from here

              if (mounted) {
                context.showSnackBar('All advanced settings reset to defaults');
              }
            },
          )
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
                12, 12, 12, 70), // Reduced bottom padding
            children: [
              _buildScreenOnAlarmSetting(
                  screenIlluminationEnabled, screenIlluminationNotifier),
              const SizedBox(height: 10), // Reduced spacing
              _buildAlarmOnCo2FallSetting(
                  alarmOnCo2FallEnabled, alarmOnCo2FallNotifier),
              const SizedBox(height: 10), // Reduced spacing
              _buildAlarmLevelsSection(alarmLevelsState.alarmLevels, false),
            ],
          ),
          // Use AnimatedSwitcher for the Save Changes button
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.0, 0.5), // Start slightly below
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ));
                final fadeAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                );
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: child,
                  ),
                );
              },
              child: hasUnsavedChanges
                  ? Padding(
                      key: const ValueKey(
                          'saveButton'), // Important for AnimatedSwitcher
                      padding: const EdgeInsets.all(16.0),
                      child: Button(
                        label: 'Update Alarm Levels',
                        prefixIcon: const Icon(Icons.save, color: Colors.white),
                        backgroundColor: context.theme.primaryColor,
                        onPressed: () async {
                          bool anyError = false;
                          try {
                            // Only save alarm levels here
                            if (alarmLevelsNotifier.hasUnsavedChanges) {
                              await alarmLevelsNotifier.saveAllAlarmLevels();
                            }
                            // Screen illumination and CO2 fall are saved immediately on toggle
                          } catch (e) {
                            anyError = true;
                            debugPrint("Error saving alarm level settings: $e");
                          }

                          if (!mounted) return;
                          if (anyError) {
                            context.showSnackBar(
                                'Failed to save alarm level settings. Please try again.');
                          } else {
                            context.showSnackBar('Alarm level changes saved');
                          }
                        },
                      ),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey(
                          'emptySpace')), // Show empty space when no changes
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenOnAlarmSetting(
      bool enabled, ScreenIlluminationSettingNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6, // Reduced blur
            offset: const Offset(0, 1), // Reduced offset
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 0), // Reduced vertical padding
        title: const Text(
          'Screen Illumination',
          style: TextStyle(
            fontSize: 14, // Reduced font size
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: const Text(
          'Turn on screen when alarm triggers',
          style: TextStyle(
            fontSize: 11, // Reduced font size
            color: Colors.grey,
          ),
        ),
        trailing: Switch(
          value: enabled,
          onChanged: (value) {
            notifier.setEnabled(value);
          },
          materialTapTargetSize:
              MaterialTapTargetSize.shrinkWrap, // Compress switch
        ),
      ),
    );
  }

  Widget _buildAlarmOnCo2FallSetting(
      bool enabled, AlarmOnCo2FallSettingNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 6, // Reduced blur
            offset: const Offset(0, 1), // Reduced offset
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 0), // Reduced vertical padding
        title: const Text(
          'Alarm on CO₂ Fall', // Used subscript
          style: TextStyle(
            fontSize: 14, // Reduced font size
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: const Text(
          'Trigger alarm on CO₂ fall', // Used subscript
          style: TextStyle(
            fontSize: 11, // Reduced font size
            color: Colors.grey,
          ),
        ),
        trailing: Switch(
          value: enabled,
          onChanged: (value) {
            notifier.setEnabled(value);
          },
          materialTapTargetSize:
              MaterialTapTargetSize.shrinkWrap, // Compress switch
        ),
      ),
    );
  }

  Widget _buildAlarmLevelsSection(
      List<AlarmLevel> alarmLevels, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 2, vertical: 6), // Reduced vertical padding
          child: Row(
            children: [
              const Icon(Icons.notifications_active_outlined,
                  size: 18, color: Colors.grey), // Reduced icon size
              const SizedBox(width: 6), // Reduced spacing
              Text('Alarm Levels',
                  style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14)), // Reduced font size
            ],
          ),
        ),
        const SizedBox(height: 6), // Reduced spacing
        Text(
          "Set beeps/vibrations and CO₂ levels for alarms.", // More concise text
          style: context.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontSize: 11, // Reduced font size
          ),
        ),
        const SizedBox(height: 10), // Reduced spacing
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 6, // Reduced blur
                offset: const Offset(0, 1), // Reduced offset
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 6.0), // Reduced padding
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text('CO₂ (ppm)', // Used subscript
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12, // Reduced font size
                                color: Colors.grey.shade700))),
                    Expanded(
                        child: Text('Repeats',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12, // Reduced font size
                                color: Colors.grey.shade700))),
                    Expanded(
                        child: Text('Enabled',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12, // Reduced font size
                                color: Colors.grey.shade700))),
                  ],
                ),
              ),
              const Divider(
                  height: 1, indent: 12, endIndent: 12), // Reduced indents
              ListView.separated(
                shrinkWrap: true,
                itemCount: alarmLevels.length,
                physics: const ClampingScrollPhysics(),
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
