import 'dart:async';

import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
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

    // Initialize controllers with current settings
    final deviceSettings = ref.read(deviceSettingsProvider(widget.deviceId));
    _updateTextControllers(deviceSettings);
  }

  void _updateTextControllers(DeviceSettings settings) {
    _altitudeController.text = settings.altitude.toStringAsFixed(0);
    _pressureController.text = settings.pressure.toStringAsFixed(2);
    _scalingController.text = settings.scaling.toStringAsFixed(2);
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
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final altitude = double.tryParse(value);
      if (altitude != null) {
        ref
            .read(deviceSettingsProvider(widget.deviceId).notifier)
            .updateSettings(ref
                .read(deviceSettingsProvider(widget.deviceId))
                .copyWith(altitude: altitude));
      }
    });
  }

  void _onPressureChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final pressure = double.tryParse(value);
      if (pressure != null) {
        ref
            .read(deviceSettingsProvider(widget.deviceId).notifier)
            .updateSettings(ref
                .read(deviceSettingsProvider(widget.deviceId))
                .copyWith(pressure: pressure));
      }
    });
  }

  void _onScalingChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final scaling = double.tryParse(value);
      if (scaling != null) {
        ref
            .read(deviceSettingsProvider(widget.deviceId).notifier)
            .updateSettings(ref
                .read(deviceSettingsProvider(widget.deviceId))
                .copyWith(scaling: scaling));
      }
    });
  }

  void _saveSettings() {
    ref
        .read(bleDeviceCommunicationProvider(widget.deviceId).notifier)
        .sendCommand(DeviceCmdUtils.setAltitudePressureScaling(
            ref.read(deviceSettingsProvider(widget.deviceId)).altitude.toInt(),
            ref.read(deviceSettingsProvider(widget.deviceId)).pressure.toInt(),
            ref.read(deviceSettingsProvider(widget.deviceId)).scaling.toInt()));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DeviceSettings>(deviceSettingsProvider(widget.deviceId),
        (previous, next) {
      // Update text controllers if the values change from provider (e.g. due to linked calculations)
      if (previous?.altitude != next.altitude ||
          previous?.pressure != next.pressure ||
          previous?.scaling != next.scaling) {
        if (mounted) {
          // Ensure widget is still in the tree
          _updateTextControllers(next);
        }
      }
    });

    final deviceSettings = ref.watch(deviceSettingsProvider(widget.deviceId));
    // Initial set or if widget rebuilds and controllers are re-initialized empty
    if (_altitudeController.text.isEmpty &&
        _pressureController.text.isEmpty &&
        _scalingController.text.isEmpty) {
      _updateTextControllers(deviceSettings);
    }

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
          crossAxisAlignment:
              CrossAxisAlignment.end, // Align items to the bottom
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Metres above sea level', style: labelStyle),
                  const SizedBox(height: 4),
                  _buildTextField(
                    controller: _altitudeController,
                    onChanged: _onAltitudeChanged,
                    textStyle: fieldTextStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pressure (hPa)', style: labelStyle),
                  const SizedBox(height: 4),
                  _buildTextField(
                    controller: _pressureController,
                    onChanged: _onPressureChanged,
                    textStyle: fieldTextStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Scaling', style: labelStyle),
                  const SizedBox(height: 4),
                  _buildTextField(
                    controller: _scalingController,
                    onChanged: _onScalingChanged,
                    textStyle: fieldTextStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Button(
              wrapWidth: true,
              onPressed: _saveSettings,
              label: 'SET',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    TextStyle? textStyle,
  }) {
    return TextFormField(
      controller: controller,
      style: textStyle,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
            horizontal: 8, vertical: 10), // Reduced padding
        isDense: true, // Makes the TextField more compact
      ),
      onChanged: onChanged,
    );
  }
}
