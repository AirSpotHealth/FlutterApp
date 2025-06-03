import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/i18n/strings.g.dart';
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

  @override
  void dispose() {
    calibrationValueController.dispose();
    super.dispose();
  }

  void _submitTarget() {
    final value = calibrationValueController.text;

    if (value.isEmpty) return;

    final validationError = _validateInput(value);
    if (validationError != null) return;

    final int calibrationValue = int.parse(value);
    ref.read(deviceSettingsProvider(widget.deviceId).notifier).updateSetting(
          (settings) =>
              settings.copyWith(recalibrationTarget: calibrationValue),
          sendCommands: true,
        );
    context.showSnackBar(t.calibrationTargetUpdated(value: calibrationValue));
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return t.deviceSettings.pleaseEnterCalibrationTarget;
    }

    if (int.tryParse(value) == null) {
      return t.deviceSettings.pleaseEnterValidNumber;
    }

    if (int.parse(value) <= 0) {
      return t.deviceSettings.pleaseEnterPositiveNumber;
    }

    if (int.parse(value) > 1000) {
      return t.deviceSettings.pleaseEnterNumberLessThan1000;
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: calibrationValueController,
                decoration: InputDecoration(
                  labelText: t.deviceSettings.calibrationTarget,
                  labelStyle: context.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onSurface,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  helperMaxLines: 3,
                  helperStyle: context.textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                  ),
                  suffixIcon: Padding(
                    padding: EdgeInsets.all(4),
                    child: Button(
                      wrapWidth: true,
                      height: 40,
                      onPressed: _submitTarget,
                      label: t.common.set,
                    ),
                  ),
                ),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                validator: _validateInput,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                style: context.textTheme.bodyMedium?.weight700,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          t.deviceSettings.calibrationTargetDescription,
          style: context.textTheme.bodySmall,
        ),
      ],
    );
  }
}
