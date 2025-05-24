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

  final _formKey = GlobalKey<FormState>();
  Timer? _debounce;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _altitudeController = TextEditingController();
    _pressureController = TextEditingController();
    _scalingController = TextEditingController();

    final deviceSettings = ref.read(deviceSettingsProvider(widget.deviceId));
    _updateTextControllers(deviceSettings);

    _altitudeController.addListener(_validateForm);
    _pressureController.addListener(_validateForm);
    _scalingController.addListener(_validateForm);
    _validateForm(); // Initial validation
  }

  double clampScaling(double value) => value.clamp(0.5, 2.0);

  void _updateTextControllers(DeviceSettings settings) {
    final scaling = clampScaling(settings.scaling);
    final altitude = convertScalingToAltitude(scaling);
    final pressure = convertScalingToPressure(scaling);
    _altitudeController.text = altitude.toStringAsFixed(2);
    _pressureController.text = pressure.toStringAsFixed(2);
    _scalingController.text = scaling.toStringAsFixed(4);
  }

  @override
  void dispose() {
    _altitudeController.removeListener(_validateForm);
    _pressureController.removeListener(_validateForm);
    _scalingController.removeListener(_validateForm);
    _altitudeController.dispose();
    _pressureController.dispose();
    _scalingController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onAltitudeChanged(String value) {
    final altitude = double.tryParse(value);
    if (altitude != null) {
      final scaling = calculateScalingFromAltitude(altitude);
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
      final scaling = calculateScalingFromPressure(pressure);
      final altitude = convertScalingToAltitude(scaling);

      _scalingController.value = TextEditingValue(
        text: scaling.toStringAsFixed(4),
        selection:
            TextSelection.collapsed(offset: scaling.toStringAsFixed(4).length),
      );

      _altitudeController.value = TextEditingValue(
        text: altitude.toStringAsFixed(0),
        selection:
            TextSelection.collapsed(offset: altitude.toStringAsFixed(2).length),
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
            TextSelection.collapsed(offset: altitude.toStringAsFixed(2).length),
      );

      _pressureController.value = TextEditingValue(
        text: pressure.toStringAsFixed(2),
        selection:
            TextSelection.collapsed(offset: pressure.toStringAsFixed(2).length),
      );
    }
  }

  void _saveSettings() {
    FocusScope.of(context).unfocus();

    final deviceSettings = ref.read(deviceSettingsProvider(widget.deviceId));

    if (deviceSettings.flightMode) {
      return;
    }

    if (_formKey.currentState!.validate()) {
      final raw = double.tryParse(_scalingController.text);
      if (raw == null) {
        context.showSnackBar('Invalid scaling value. Settings not saved.');
        return;
      }

      final clamped = clampScaling(raw);
      final rounded = double.parse(clamped.toStringAsFixed(4));
      debugPrint('Saving scaling: $rounded');
      ref.read(deviceSettingsProvider(widget.deviceId).notifier).updateSetting(
          (settings) => settings.copyWith(scaling: rounded),
          sendCommands: true);

      context.showSnackBar('Settings saved');
    } else {
      setState(() {
        _isFormValid = false;
      });
    }
  }

  String? _validateAltitudeField(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (double.tryParse(value) == null) return 'Invalid';
    return null;
  }

  String? _validatePressureField(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (double.tryParse(value) == null) return 'Invalid';
    return null;
  }

  String? _validateScalingField(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final scaling = double.tryParse(value);
    if (scaling == null || scaling < 0.5 || scaling > 2.0) {
      return 'Invalid';
    }
    return null;
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(fontSize: 12, color: Colors.grey);
    const fieldTextStyle = TextStyle(fontSize: 14);

    final deviceSettings = ref.watch(deviceSettingsProvider(widget.deviceId));
    final bool isFlightModeOn = deviceSettings.flightMode;

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
        if (isFlightModeOn)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GestureDetector(
              onTap: () {
                ref
                    .read(deviceSettingsProvider(widget.deviceId).notifier)
                    .updateSetting(
                      (settings) => settings.copyWith(flightMode: false),
                      sendCommands: true,
                    );

                if (mounted) {
                  context.showSnackBar(
                      'Flight mode turned off. You can now set scaling.');
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(
                      color: Colors.orange.withValues(alpha: .5), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flight_takeoff,
                        color: Colors.orange[700], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Flight mode is active. Scaling cannot be changed. Tap to turn off.',
                        style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.normal,
                            fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Row for Labels
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text('Metres above sea level', style: labelStyle)),
            const SizedBox(width: 8),
            Expanded(child: Text('Pressure (hPa)', style: labelStyle)),
            const SizedBox(width: 8),
            Expanded(child: Text('Scaling (0.5-2.0)', style: labelStyle)),
            const SizedBox(width: 8),
            SizedBox(
                width: 60), // Placeholder for button width, adjust as needed
          ],
        ),
        const SizedBox(height: 4), // Space between labels and fields
        // Row for TextFields and Button
        Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.baseline, // Align by baseline
            textBaseline: TextBaseline.alphabetic, // Use alphabetic baseline
            children: [
              Expanded(
                  child: _buildTextFormField(
                _altitudeController,
                _onAltitudeChanged,
                _validateAltitudeField,
                fieldTextStyle,
                enabled: !isFlightModeOn,
              )),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextFormField(
                  _pressureController,
                  _onPressureChanged,
                  _validatePressureField,
                  fieldTextStyle,
                  enabled: !isFlightModeOn,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextFormField(
                  _scalingController,
                  _onScalingChanged,
                  _validateScalingField,
                  fieldTextStyle,
                  enabled: !isFlightModeOn,
                ),
              ),
              const SizedBox(width: 8),
              Button(
                wrapWidth: true,
                onPressed: _saveSettings,
                label: 'SET',
                disabled: !_isFormValid || isFlightModeOn,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    ValueChanged<String> onChanged,
    String? Function(String?)? validator,
    TextStyle textStyle, {
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      style: textStyle,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,5}(\.\d{0,4})?$')),
      ],
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        isDense: true,
        helperText: ' ',
      ),
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
