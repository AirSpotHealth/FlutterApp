import 'dart:async';

import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/app_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AltitudePressureScalingWidget extends ConsumerStatefulWidget {
  final String deviceId;

  const AltitudePressureScalingWidget({super.key, required this.deviceId});

  @override
  ConsumerState<AltitudePressureScalingWidget> createState() =>
      _AltitudePressureScalingWidgetState();
}

class _AltitudePressureScalingWidgetState
    extends ConsumerState<AltitudePressureScalingWidget> {
  late TextEditingController _altitudeController;
  late TextEditingController _pressureController;
  late TextEditingController _scalingController;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _altitudeController = TextEditingController();
    _pressureController = TextEditingController();
    _scalingController = TextEditingController();

    final deviceSettings = ref.read(deviceSettingsProvider(widget.deviceId));
    _updateTextControllers(deviceSettings);
  }

  double clampScaling(double value) => value.clamp(0.5, 2.0);

  void _updateTextControllers(DeviceSettings settings) {
    final scaling = clampScaling(settings.scaling);
    final altitude = convertScalingToAltitude(scaling);
    final pressure = convertScalingToPressure(scaling);
    _altitudeController.text = altitude.toStringAsFixed(0);
    _pressureController.text = pressure.toStringAsFixed(2);
    _scalingController.text = scaling.toStringAsFixed(4);
  }

  @override
  void dispose() {
    _altitudeController.dispose();
    _pressureController.dispose();
    _scalingController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onAltitudeChanged(String value) {
    final altitude = double.tryParse(value);
    if (altitude != null) {
      final scaling = clampScaling(calculateScalingFromAltitude(altitude));
      final pressure = convertScalingToPressure(scaling);

      _scalingController.value = TextEditingValue(
        text: scaling.toStringAsFixed(4),
        selection:
            TextSelection.collapsed(offset: scaling.toStringAsFixed(4).length),
      );

      _pressureController.value = TextEditingValue(
        text: pressure.toStringAsFixed(2),
        selection:
            TextSelection.collapsed(offset: pressure.toStringAsFixed(2).length),
      );
    }
  }

  void _onPressureChanged(String value) {
    final pressure = double.tryParse(value);
    if (pressure != null) {
      final scaling = clampScaling(calculateScalingFromPressure(pressure));
      final altitude = convertScalingToAltitude(scaling);

      _scalingController.value = TextEditingValue(
        text: scaling.toStringAsFixed(4),
        selection:
            TextSelection.collapsed(offset: scaling.toStringAsFixed(4).length),
      );

      _altitudeController.value = TextEditingValue(
        text: altitude.toStringAsFixed(0),
        selection:
            TextSelection.collapsed(offset: altitude.toStringAsFixed(0).length),
      );
    }
  }

  void _onScalingChanged(String value) {
    final scalingRaw = double.tryParse(value);
    if (scalingRaw != null && scalingRaw >= 0.5 && scalingRaw <= 2.0) {
      final scaling = clampScaling(scalingRaw);
      final altitude = convertScalingToAltitude(scaling);
      final pressure = convertScalingToPressure(scaling);

      _altitudeController.value = TextEditingValue(
        text: altitude.toStringAsFixed(0),
        selection:
            TextSelection.collapsed(offset: altitude.toStringAsFixed(0).length),
      );

      _pressureController.value = TextEditingValue(
        text: pressure.toStringAsFixed(2),
        selection:
            TextSelection.collapsed(offset: pressure.toStringAsFixed(2).length),
      );
    }
  }

  void _saveSettings() {
    final raw = double.tryParse(_scalingController.text) ?? 1.0000;
    final clamped = clampScaling(raw.clamp(0.5, 2.0));
    final rounded = double.parse(clamped.toStringAsFixed(4));
    debugPrint('Saving scaling: $rounded');
    ref.read(deviceSettingsProvider(widget.deviceId).notifier).updateSetting(
        (settings) => settings.copyWith(scaling: rounded),
        sendCommands: true);

    FocusScope.of(context).unfocus();

    context.showSnackBar('Settings saved');
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(fontSize: 12, color: Colors.grey);
    const fieldTextStyle = TextStyle(fontSize: 14);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Altitude/Pressure',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'For most accurate calibration, set altitude or air pressure or scaling here (optional advanced feature, see manual.)',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: _buildField(
                    'Metres above sea level',
                    _altitudeController,
                    _onAltitudeChanged,
                    labelStyle,
                    fieldTextStyle)),
            const SizedBox(width: 8),
            Expanded(
                child: _buildField('Pressure (hPa)', _pressureController,
                    _onPressureChanged, labelStyle, fieldTextStyle)),
            const SizedBox(width: 8),
            Expanded(
                child: _buildField('Scaling (0.5-2.0)', _scalingController,
                    _onScalingChanged, labelStyle, fieldTextStyle)),
            const SizedBox(width: 8),
            SizedBox(
              height: 40,
              child: Button(
                  wrapWidth: true, onPressed: _saveSettings, label: 'SET'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField(
      String label,
      TextEditingController controller,
      ValueChanged<String> onChanged,
      TextStyle labelStyle,
      TextStyle textStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          style: textStyle,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d{0,5}(\.\d{0,4})?$')),
          ],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            isDense: true,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
