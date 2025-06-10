import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define constants at the file level so they're accessible to all classes
const int kMinValue = 400;
const int kMaxValue = 4000;
const int kStepSize = 50;

class Co2PpmRangePickerWidget extends ConsumerStatefulWidget {
  const Co2PpmRangePickerWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<Co2PpmRangePickerWidget> createState() =>
      _Co2PpmRangePickerWidgetState();
}

class _Co2PpmRangePickerWidgetState
    extends ConsumerState<Co2PpmRangePickerWidget> {
  // Generate the list of values for the pickers
  final List<int> _ppmValues = List<int>.generate(
    ((kMaxValue - kMinValue) ~/ kStepSize) + 1,
    (index) => kMinValue + (index * kStepSize),
  );

  // Selected values
  late int _selectedGreenValue;
  late int _selectedYellowValue;

  @override
  void initState() {
    super.initState();
    _selectedGreenValue =
        ref.read(deviceSettingsProvider(widget.deviceId)).greenUpperLimit;
    _selectedYellowValue =
        ref.read(deviceSettingsProvider(widget.deviceId)).yellowUpperLimit;
  }

  @override
  Widget build(BuildContext context) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(widget.deviceId));

    // Check if values have changed
    final bool hasChanged =
        _selectedGreenValue != deviceSettings.greenUpperLimit ||
            _selectedYellowValue != deviceSettings.yellowUpperLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'CO₂ PPM Zones',
            style: context.textTheme.bodyMedium?.weight600,
          ),
        ),

        // Visual indicator
        SizedBox(
          width: MediaQuery.of(context).size.width - 32 - 16,
          height: 30,
          child: CustomPaint(
            painter: _CO2PPMRangePainter(
              yellowValue: _selectedGreenValue,
              redValue: _selectedYellowValue,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Green zone dropdown
        Row(
          children: [
            Expanded(
              child: _ZoneValueDropdown(
                deviceId: widget.deviceId,
                currentValue: _selectedGreenValue,
                label: 'Green Zone (Up to)',
                values: _ppmValues,
                valueColor: AppColors.brandColorGreen,
                onValueChanged: (int newValue) {
                  if (newValue >= _selectedYellowValue) {
                    context.showSnackBar(
                        'Green zone cannot be greater than yellow zone');
                    return;
                  }

                  setState(() {
                    _selectedGreenValue = newValue;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Button(
              wrapWidth: true,
              onPressed: hasChanged ? () => _updateValues() : null,
              child: const Text('Set'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Yellow zone dropdown
        Row(
          children: [
            Expanded(
              child: _ZoneValueDropdown(
                deviceId: widget.deviceId,
                currentValue: _selectedYellowValue,
                label: 'Yellow Zone (Up to)',
                values: _ppmValues,
                valueColor: AppColors.brandColorAmber,
                onValueChanged: (int newValue) {
                  if (newValue < _selectedGreenValue) {
                    context.showSnackBar(
                        'Yellow zone cannot be less than green zone');
                    return;
                  }

                  setState(() {
                    _selectedYellowValue = newValue;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Button(
              wrapWidth: true,
              onPressed: hasChanged ? () => _updateValues() : null,
              child: const Text('Set'),
            ),
          ],
        ),

        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  void _updateValues() {
    // Simple validation: ensure green is less than yellow
    if (_selectedGreenValue >= _selectedYellowValue) {
      context.showSnackBar(
          'Green ${Constants.co2Text} must be less than yellow ${Constants.co2Text}');
      return;
    }

    // Get the current settings
    final DeviceSettings deviceSettings =
        ref.read(deviceSettingsProvider(widget.deviceId));

    // Create updated settings
    final updatedSettings = deviceSettings.copyWith(
      thresholds: DeviceThresholds(
        greenUpperLimit: _selectedGreenValue,
        yellowUpperLimit: _selectedYellowValue,
      ),
    );

    // Update the settings
    ref
        .read(deviceSettingsProvider(widget.deviceId).notifier)
        .updateSettings(updatedSettings);

    // Send the command
    ref
        .read(bleDeviceCommunicationProvider(widget.deviceId).notifier)
        .sendCommand(updatedSettings.thresholdsCmd);

    // Show feedback to the user
    context.showSnackBar('CO₂ PPM Zones updated successfully');
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('Good', AppColors.brandColorGreen),
        const SizedBox(width: 16),
        _buildLegendItem('Warning', AppColors.brandColorAmber),
        const SizedBox(width: 16),
        _buildLegendItem('Alert', AppColors.brandColorRed),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

class _ZoneValueDropdown extends ConsumerWidget {
  final String deviceId;
  final int currentValue;
  final String label;
  final List<int> values;
  final Color valueColor;
  final Function(int) onValueChanged;

  const _ZoneValueDropdown({
    required this.deviceId,
    required this.currentValue,
    required this.label,
    required this.values,
    required this.valueColor,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: valueColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.textTheme.bodyMedium?.weight600,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value:
                  values.contains(currentValue) ? currentValue : values.first,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              style: context.textTheme.bodyMedium,
              items: values.map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value ppm'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onValueChanged(newValue);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a value between $kMinValue and $kMaxValue ppm',
          style: context.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _CO2PPMRangePainter extends CustomPainter {
  _CO2PPMRangePainter({required this.yellowValue, required this.redValue});

  final int yellowValue;
  final int redValue;

  @override
  void paint(Canvas canvas, Size size) {
    // Three rectangles for the green, yellow and red zones in a row
    final greenRect = Rect.fromLTWH(0, 0, size.width / 3, size.height - 24);
    final yellowRect =
        Rect.fromLTWH(size.width / 3, 0, size.width / 3, size.height - 24);
    final redRect =
        Rect.fromLTWH(size.width * 2 / 3, 0, size.width / 3, size.height - 24);

    final greenPaint = Paint()
      ..color = AppColors.brandColorGreen
      ..style = PaintingStyle.fill;
    final yellowPaint = Paint()
      ..color = AppColors.brandColorAmber
      ..style = PaintingStyle.fill;
    final redPaint = Paint()
      ..color = AppColors.brandColorRed
      ..style = PaintingStyle.fill;

    // Draw the rectangles
    canvas.drawRect(greenRect, greenPaint);
    canvas.drawRect(yellowRect, yellowPaint);
    canvas.drawRect(redRect, redPaint);

    // Draw divider lines
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(yellowRect.left, 0),
      Offset(yellowRect.left, size.height - 24),
      linePaint,
    );
    canvas.drawLine(
      Offset(redRect.left, 0),
      Offset(redRect.left, size.height - 24),
      linePaint,
    );

    // Create text painters
    final yellowTextPainter = TextPainter(
      text: TextSpan(
        text: '$yellowValue ppm',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final redTextPainter = TextPainter(
      text: TextSpan(
        text: '$redValue ppm',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Layout the text painters
    yellowTextPainter.layout();
    redTextPainter.layout();

    // Calculate text positions
    final yellowTextX = yellowRect.left - (yellowTextPainter.width / 2);
    final redTextX = redRect.left - (redTextPainter.width / 2);
    final textY = size.height - 20;

    // Draw the text
    yellowTextPainter.paint(canvas, Offset(yellowTextX, textY));
    redTextPainter.paint(canvas, Offset(redTextX, textY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
