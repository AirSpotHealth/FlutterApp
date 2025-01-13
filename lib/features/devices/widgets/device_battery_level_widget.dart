import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceBatteryLevelWidget extends ConsumerWidget {
  const DeviceBatteryLevelWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? batteryLevel = ref.watch(
        deviceSettingsProvider(deviceId).select((value) => value.batteryLevel));

    // create a battery level indicator custom widget using paint method
    return CustomPaint(
      painter: BatteryLevelIndicatorPainter(batteryLevel),
      child: SizedBox(
        width: 40,
        height: 25,
      ),
    );
  }
}

class BatteryLevelIndicatorPainter extends CustomPainter {
  final int? batteryLevel;

  BatteryLevelIndicatorPainter(this.batteryLevel);

  @override
  void paint(Canvas canvas, Size size) {
    final double borderWidth = 2.0;
    final double cornerRadius = 4.0;

    final Paint outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = borderWidth;

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green;

    final Paint terminalPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    // Define dimensions
    final double batteryWidth = size.width * 0.85;
    final double batteryHeight = size.height * 0.7;

    // Space between the battery body and the positive terminal
    final double terminalSpacing = 2;

    // Draw the main battery outline with rounded corners
    final RRect batteryBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, batteryWidth, batteryHeight),
      Radius.circular(cornerRadius),
    );
    canvas.drawRRect(batteryBody, outlinePaint);

    // Draw the solid positive terminal
    final double terminalWidth =
        size.width - batteryWidth - terminalSpacing - 2;
    final double terminalHeight = size.height * 0.35;
    final RRect terminal = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        batteryWidth + terminalSpacing, // Add spacing
        batteryHeight * 0.25, // Center the terminal vertically
        terminalWidth,
        terminalHeight,
      ),
      Radius.circular(cornerRadius / 2),
    );
    canvas.drawRRect(terminal, terminalPaint);

    // Draw the battery fill level
    if (batteryLevel != null && batteryLevel! > 0) {
      final double fillWidth =
          ((batteryLevel! / 100) * (batteryWidth - borderWidth * 2));
      final RRect fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          borderWidth,
          borderWidth,
          fillWidth,
          batteryHeight - borderWidth * 2,
        ),
        Radius.circular(cornerRadius / 2), // Smaller rounding for fill
      );
      canvas.drawRRect(fillRect, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
