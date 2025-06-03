import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/custom_bottom_picker.dart';
import 'package:airspothealth/features/advanced_alarm_settings/providers/advanced_alarm_settings_provider.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlarmLevelRow extends ConsumerStatefulWidget {
  final AlarmLevel alarm;
  final int index;
  final String deviceId;

  const AlarmLevelRow({
    super.key,
    required this.alarm,
    required this.index,
    required this.deviceId,
  });

  @override
  ConsumerState<AlarmLevelRow> createState() => _AlarmLevelRowState();
}

class _AlarmLevelRowState extends ConsumerState<AlarmLevelRow> {
  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      print(
          'AlarmLevelRow initialized for index ${widget.index} with CO2: ${widget.alarm.co2Threshold}');
    }
  }

  @override
  void didUpdateWidget(AlarmLevelRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (kDebugMode) {
      if (oldWidget.alarm != widget.alarm) {
        print(
            'AlarmLevelRow for index ${widget.index} updated: ${oldWidget.alarm.co2Threshold} -> ${widget.alarm.co2Threshold}');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Update the value in the provider
  void _updateAlarmLevel({int? co2Threshold, int? repeatCount, bool? enabled}) {
    if (kDebugMode) {
      print(
          'Updating alarm level for index ${widget.index}: CO2=$co2Threshold, repeats=$repeatCount, enabled=$enabled');
    }

    // Get current alarm from the provider to check if we're actually changing anything
    final currentAlarmFromProvider = ref
        .read(advancedAlarmSettingsProvider(widget.deviceId))
        .alarmLevels[widget.index];

    final willChange = (co2Threshold != null &&
            co2Threshold != currentAlarmFromProvider.co2Threshold) ||
        (repeatCount != null &&
            repeatCount != currentAlarmFromProvider.repeatCount) ||
        (enabled != null && enabled != currentAlarmFromProvider.enabled);

    if (!willChange) {
      if (kDebugMode) {
        print(
            'No actual change in values, skipping update for index ${widget.index}');
      }
      return;
    }

    ref
        .read(advancedAlarmSettingsProvider(widget.deviceId).notifier)
        .updateLocalAlarmLevel(
          widget.index,
          co2Threshold: co2Threshold,
          repeatCount: repeatCount,
          enabled: enabled,
        );
  }

  void _showCo2Picker(BuildContext context) {
    final currentAlarm = ref
        .read(advancedAlarmSettingsProvider(widget.deviceId))
        .alarmLevels[widget.index];

    CustomBottomPicker.showNumeric(
      context: context,
      min: 100,
      max: 5000,
      step: 100,
      initialValue: currentAlarm.co2Threshold,
      title: t.selectCo2Level,
      suffix: t.units.ppm,
      submitButtonText: t.done,
      selectedTextColor: context.theme.primaryColor,
      onSubmit: (newValue) {
        if (newValue > 0) {
          _updateAlarmLevel(co2Threshold: newValue);
        }
      },
    );
  }

  void _showRepeatsPicker(BuildContext context) {
    final currentAlarm = ref
        .read(advancedAlarmSettingsProvider(widget.deviceId))
        .alarmLevels[widget.index];

    CustomBottomPicker.showNumeric(
      context: context,
      min: 1,
      max: 10,
      step: 1,
      initialValue: currentAlarm.repeatCount,
      title: t.selectAlarmRepeats,
      submitButtonText: t.done,
      selectedTextColor: context.theme.primaryColor,
      onSubmit: (newValue) {
        if (newValue > 0) {
          _updateAlarmLevel(repeatCount: newValue);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes to the alarm
    final currentAlarm = ref.watch(
      advancedAlarmSettingsProvider(widget.deviceId).select(
        (state) => state.alarmLevels[widget.index],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _showCo2Picker(context),
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
                      '${currentAlarm.co2Threshold}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      t.units.ppm,
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
            child: InkWell(
              onTap: () => _showRepeatsPicker(context),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${currentAlarm.repeatCount}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Switch(
              value: currentAlarm.enabled,
              onChanged: (newValue) => _updateAlarmLevel(enabled: newValue),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
