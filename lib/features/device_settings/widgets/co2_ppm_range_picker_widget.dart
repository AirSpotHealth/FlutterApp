import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Co2PpmRangePickerWidget extends ConsumerStatefulWidget {
  const Co2PpmRangePickerWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<Co2PpmRangePickerWidget> createState() =>
      _Co2PpmRangePickerWidgetState();
}

class _Co2PpmRangePickerWidgetState
    extends ConsumerState<Co2PpmRangePickerWidget> {
  // Define the range of values for the pickers
  static const int minValue = 400;
  static const int maxValue = 4000;
  static const int stepSize = 50;

  // Generate the list of values for the pickers
  final List<int> _ppmValues = List<int>.generate(
    ((maxValue - minValue) ~/ stepSize) + 1,
    (index) => minValue + (index * stepSize),
  );

  // Selected values
  late int _selectedGreenValue =
      ref.read(deviceSettingsProvider(widget.deviceId)).greenUpperLimit;
  late int _selectedYellowValue =
      ref.read(deviceSettingsProvider(widget.deviceId)).yellowUpperLimit;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(widget.deviceId));

    // Check if values have changed
    final bool hasChanged =
        _selectedGreenValue != deviceSettings.greenUpperLimit ||
            _selectedYellowValue != deviceSettings.yellowUpperLimit;

    // Get indices for selected values
    final int greenIndex = _ppmValues.indexOf(_selectedGreenValue);
    final int yellowIndex = _ppmValues.indexOf(_selectedYellowValue);

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
              redValue: _selectedYellowValue,
              yellowValue: _selectedGreenValue,
            ),
          ),
        ),

        Row(
          children: [
            Expanded(
              child: _buildThresholdCard(
                'Green Zone',
                'Up to:',
                AppColors.brandColorGreen,
                greenIndex,
                (index) {
                  if (index > yellowIndex) {
                    return;
                  }

                  setState(() {
                    _selectedGreenValue = _ppmValues[index];
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildThresholdCard(
                'Yellow Zone',
                'Up to:',
                AppColors.brandColorAmber,
                yellowIndex,
                (index) {
                  if (index < greenIndex) {
                    return;
                  }

                  setState(() {
                    _selectedYellowValue = _ppmValues[index];
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLegend(),
        const SizedBox(height: 16),

        // Update button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasChanged ? () => _updateValues() : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Update PPM Zones',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
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
  }

  Widget _buildThresholdCard(
    String title,
    String subtitle,
    Color color,
    int initialIndex,
    Function(int) onChanged,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            _buildPicker(initialIndex, onChanged, color),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker(int initialIndex, Function(int) onChanged, Color color) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: CupertinoPicker(
        scrollController:
            FixedExtentScrollController(initialItem: initialIndex),
        itemExtent: 40,
        backgroundColor: Colors.transparent,
        onSelectedItemChanged: onChanged,
        children: _ppmValues.map((value) {
          return Center(
            child: Text(
              '$value ppm',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
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
