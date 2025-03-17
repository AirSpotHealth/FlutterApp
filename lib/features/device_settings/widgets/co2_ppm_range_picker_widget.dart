import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/delayed_function_call.dart';
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

  // Debouncer for sending commands
  final DelayedFunctionCaller _debouncer = DelayedFunctionCaller();

  // Track if values are being changed to prevent sending commands during initialization
  bool _isChanging = false;

  @override
  Widget build(BuildContext context) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(widget.deviceId));

    // Find the closest indices for the current values
    final int greenIndex =
        _findClosestValueIndex(deviceSettings.greenUpperLimit);
    final int yellowIndex =
        _findClosestValueIndex(deviceSettings.yellowUpperLimit);

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

        // A three colored rectangle with the green, yellow and red zones
        // and a indicator line for the yellow and red start zones
        SizedBox(
          width: MediaQuery.of(context).size.width - 32 - 16,
          height: 30,
          child: CustomPaint(
            painter: _CO2PPMRangePainter(
              redValue: deviceSettings.yellowUpperLimit,
              yellowValue: deviceSettings.greenUpperLimit,
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
                (index) => _updateGreenThreshold(index),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildThresholdCard(
                'Yellow Zone',
                'Up to:',
                AppColors.brandColorAmber,
                yellowIndex,
                (index) => _updateYellowThreshold(index),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
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
        onSelectedItemChanged: (index) {
          // Only trigger the update when scrolling settles
          _debouncer.call(() {
            _isChanging = true;
            onChanged(index);
            _isChanging = false;
          }, delay: 800);
        },
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

  int _findClosestValueIndex(int value) {
    // Find the closest value in the list
    int closestIndex = 0;
    int minDifference = (value - _ppmValues[0]).abs();

    for (int i = 1; i < _ppmValues.length; i++) {
      final int difference = (value - _ppmValues[i]).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  void _updateGreenThreshold(int index) {
    final DeviceSettings deviceSettings =
        ref.read(deviceSettingsProvider(widget.deviceId));
    final int greenValue = _ppmValues[index];

    // Ensure green threshold is less than yellow threshold
    if (greenValue >= deviceSettings.yellowUpperLimit) {
      // Find the next available yellow value that's greater than the selected green value
      final int nextYellowIndex =
          _ppmValues.indexWhere((value) => value > greenValue);
      if (nextYellowIndex != -1) {
        _updateThresholds(greenValue, _ppmValues[nextYellowIndex]);
      }
    } else {
      _updateThresholds(greenValue, deviceSettings.yellowUpperLimit);
    }
  }

  void _updateYellowThreshold(int index) {
    final DeviceSettings deviceSettings =
        ref.read(deviceSettingsProvider(widget.deviceId));
    final int yellowValue = _ppmValues[index];

    // Ensure yellow threshold is greater than green threshold
    if (yellowValue <= deviceSettings.greenUpperLimit) {
      // Find the previous available green value that's less than the selected yellow value
      final int prevGreenIndex =
          _ppmValues.lastIndexWhere((value) => value < yellowValue);
      if (prevGreenIndex != -1) {
        _updateThresholds(_ppmValues[prevGreenIndex], yellowValue);
      }
    } else {
      _updateThresholds(deviceSettings.greenUpperLimit, yellowValue);
    }
  }

  void _updateThresholds(int greenValue, int yellowValue) {
    final DeviceSettings deviceSettings =
        ref.read(deviceSettingsProvider(widget.deviceId));

    // Update the device settings
    ref.read(deviceSettingsProvider(widget.deviceId).notifier).updateSettings(
          deviceSettings.copyWith(
            thresholds: DeviceThresholds(
              greenUpperLimit: greenValue,
              yellowUpperLimit: yellowValue,
            ),
          ),
        );

    // Send command immediately since debouncing is handled at picker level
    if (_isChanging) {
      ref
          .read(bleDeviceCommunicationProvider(widget.deviceId).notifier)
          .sendCommand(deviceSettings.thresholdsCmd);
    }
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
