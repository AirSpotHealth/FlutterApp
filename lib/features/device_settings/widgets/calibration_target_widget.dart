import 'dart:async';

import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalibrationTargetWidget extends ConsumerStatefulWidget {
  const CalibrationTargetWidget({
    required this.deviceId,
    required this.calibrationTarget,
    super.key,
  });

  final String deviceId;

  final int calibrationTarget;

  @override
  ConsumerState<CalibrationTargetWidget> createState() =>
      _CalibrationCorrectionWidgetState();
}

class _CalibrationCorrectionWidgetState
    extends ConsumerState<CalibrationTargetWidget> {
  late final TextEditingController calibrationValueController =
      TextEditingController()..text = widget.calibrationTarget.toString();

  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 500);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    calibrationValueController.dispose();
    super.dispose();
  }

  void _handleValueChange(String value) {
    if (value.isEmpty) return;

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(_debounceDuration, () {
      if (!mounted) return;

      final validationError = _validateInput(value);
      if (validationError != null) return;

      final int calibrationValue = int.parse(value);
      ref.read(deviceSettingsProvider(widget.deviceId).notifier).updateSetting(
            (settings) =>
                settings.copyWith(recalibrationTarget: calibrationValue),
            sendCommands: true,
          );
    });
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a calibration target';
    }

    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    if (int.parse(value) <= 0) {
      return 'Please enter a positive number greater than 0';
    }
    return null;
  }

  @override
  void didUpdateWidget(covariant CalibrationTargetWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.calibrationTarget != widget.calibrationTarget) {
      calibrationValueController.text = widget.calibrationTarget.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: calibrationValueController,
      decoration: InputDecoration(
        labelText: 'Calibration Target',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        helperMaxLines: 3,
        helperStyle: context.textTheme.bodySmall,
        helperText:
            "You can set the CO2 level of the air where calibration takes place. If unknown, 420-450 is typical for outdoors. This value is used for manual or automatic calibration.",
      ),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      validator: _validateInput,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.number,
      style: context.textTheme.bodyMedium?.weight700,
      onFieldSubmitted: _handleValueChange,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}
