import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/custom_bottom_picker.dart';
import 'package:airspothealth/features/advanced_alarm_settings/providers/advanced_alarm_settings_provider.dart';
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

class _AlarmLevelRowState extends ConsumerState<AlarmLevelRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late AlarmLevel _originalAlarm;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _originalAlarm = widget.alarm.copyWith();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (kDebugMode) {
      print(
          'AlarmLevelRow initialized for index ${widget.index} with CO2: ${widget.alarm.co2Threshold}');
    }
  }

  @override
  void didUpdateWidget(AlarmLevelRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle reset to defaults - detect if our alarm was reset from outside
    if (_isResetOperation(oldWidget.alarm, widget.alarm)) {
      if (kDebugMode) {
        print(
            'Reset detected for index ${widget.index}: ${oldWidget.alarm.co2Threshold} -> ${widget.alarm.co2Threshold}');
      }
      _resetState();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Reset local state to match the incoming alarm (likely after a reset to defaults)
  void _resetState() {
    if (kDebugMode) {
      print('Resetting state for index ${widget.index}');
    }
    setState(() {
      _originalAlarm = widget.alarm.copyWith();
      _hasUnsavedChanges = false;
      // Hide save button if showing
      if (_animationController.value > 0) {
        _animationController.reverse();
      }
    });
  }

  /// Detect if this appears to be a reset to defaults operation
  bool _isResetOperation(AlarmLevel oldAlarm, AlarmLevel newAlarm) {
    // Only proceed if there's an actual change in the alarm
    if (oldAlarm == newAlarm) {
      if (kDebugMode) {
        print(
            'No actual change in alarm values for index ${widget.index}, skipping reset detection');
      }
      return false;
    }

    // If CO2 threshold changed to match a default value, it's likely a reset operation
    final defaultValues = [800, 1000, 1200, 1500, 0, 0, 0, 0, 0, 0];
    final isDefaultValue = widget.index < defaultValues.length &&
        newAlarm.co2Threshold == defaultValues[widget.index] &&
        oldAlarm.co2Threshold != newAlarm.co2Threshold;

    // Multiple properties changing at once suggests a reset operation rather than user edits
    final hasMultipleChanges =
        (oldAlarm.co2Threshold != newAlarm.co2Threshold &&
                oldAlarm.repeatCount != newAlarm.repeatCount) ||
            (oldAlarm.co2Threshold != newAlarm.co2Threshold &&
                oldAlarm.enabled != newAlarm.enabled);

    final result = isDefaultValue || hasMultipleChanges;

    if (kDebugMode && result) {
      debugPrint(
          'Reset operation detected: isDefaultValue=$isDefaultValue, hasMultipleChanges=$hasMultipleChanges');
      debugPrint(
          'oldAlarm: CO2=${oldAlarm.co2Threshold}, repeats=${oldAlarm.repeatCount}, enabled=${oldAlarm.enabled}');
      debugPrint(
          'newAlarm: CO2=${newAlarm.co2Threshold}, repeats=${newAlarm.repeatCount}, enabled=${newAlarm.enabled}');
    }

    return result;
  }

  /// Update the value in the provider
  void _updateAlarmLevel({int? co2Threshold, int? repeatCount, bool? enabled}) {
    if (kDebugMode) {
      print(
          'Updating alarm level for index ${widget.index}: CO2=$co2Threshold, repeats=$repeatCount, enabled=$enabled');
    }

    // Get current alarm to check if we're actually changing anything
    final currentAlarm = ref
        .read(advancedAlarmSettingsProvider(widget.deviceId))
        .alarmLevels[widget.index];

    // Only proceed if there's an actual change
    final willChange =
        (co2Threshold != null && co2Threshold != currentAlarm.co2Threshold) ||
            (repeatCount != null && repeatCount != currentAlarm.repeatCount) ||
            (enabled != null && enabled != currentAlarm.enabled);

    if (!willChange) {
      if (kDebugMode) {
        print('No actual change in values, skipping update');
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

    // Set flag for unsaved changes
    setState(() {
      _hasUnsavedChanges = true;
    });

    // Ensure animation starts immediately
    if (_animationController.status != AnimationStatus.completed &&
        _animationController.status != AnimationStatus.forward) {
      _animationController.forward();
    }
  }

  /// Save changes to the device
  Future<void> _saveChanges() async {
    if (_isSaving) return;

    if (kDebugMode) {
      print('Saving changes for index ${widget.index}');
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(advancedAlarmSettingsProvider(widget.deviceId).notifier)
          .saveSingleAlarmLevel(widget.index);

      // Get the current state after saving
      final currentAlarm = ref
          .read(advancedAlarmSettingsProvider(widget.deviceId))
          .alarmLevels[widget.index];

      setState(() {
        _isSaving = false;
        _hasUnsavedChanges = false;
        _originalAlarm = currentAlarm.copyWith();
      });

      _animationController.reverse();

      if (kDebugMode) {
        print('Changes saved successfully for index ${widget.index}');
      }
    } catch (e) {
      setState(() => _isSaving = false);

      if (kDebugMode) {
        print('Error saving changes for index ${widget.index}: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${e.toString()}')),
        );
      }
    }
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
      title: 'Select CO₂ Level',
      suffix: 'ppm',
      submitButtonText: 'Save',
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
      title: 'Select Alarm Repeats',
      submitButtonText: 'Save',
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

    // Check if there are unsaved changes
    final hasChanges =
        currentAlarm.co2Threshold != _originalAlarm.co2Threshold ||
            currentAlarm.repeatCount != _originalAlarm.repeatCount ||
            currentAlarm.enabled != _originalAlarm.enabled;

    // If change status has changed, update tracking and animations
    if (hasChanges != _hasUnsavedChanges) {
      if (kDebugMode) {
        print(
            'Change status updated for index ${widget.index}: hasChanges=$hasChanges, hadChanges=$_hasUnsavedChanges');
        print(
            'Current CO2: ${currentAlarm.co2Threshold}, Original CO2: ${_originalAlarm.co2Threshold}');
        print(
            'Current repeats: ${currentAlarm.repeatCount}, Original repeats: ${_originalAlarm.repeatCount}');
        print(
            'Current enabled: ${currentAlarm.enabled}, Original enabled: ${_originalAlarm.enabled}');
      }

      // We need to use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasUnsavedChanges = hasChanges;
          });

          // Explicitly control animation
          if (hasChanges) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        }
      });
    }

    // Force the save button to be visible if we have unsaved changes
    // This ensures it appears even if animation hasn't completed
    final showSaveButton = hasChanges || _hasUnsavedChanges;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ppm',
                      style: TextStyle(
                        fontSize: 12,
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
                    fontSize: 14,
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
            ),
          ),
          if (showSaveButton)
            AnimatedOpacity(
              opacity: showSaveButton ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: SizeTransition(
                sizeFactor: _animation,
                axis: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: _isSaving
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                          )
                        : IconButton(
                            icon: const Icon(Icons.save, color: Colors.blue),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: _saveChanges,
                            tooltip: 'Save changes',
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
