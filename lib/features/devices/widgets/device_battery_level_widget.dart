import 'package:airspothealth/features/devices/providers/device_battery_level_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceBatteryLevelWidget extends ConsumerWidget {
  const DeviceBatteryLevelWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int? batteryLevel = ref.watch(deviceBatteryLevelProvider(deviceId));

    if (batteryLevel != null && batteryLevel > 100) {
      batteryLevel = null;
    }

    // create a battery level indicator
    // when tapped it will show a tooltip with the battery level

    debugPrint('Battery level: $batteryLevel');

    return Tooltip(
      message: batteryLevel != null ? "$batteryLevel%" : "Unknown",
      triggerMode: TooltipTriggerMode.tap,
      child: CustomPaint(
        painter: BatteryLevelIndicatorPainter(batteryLevel),
        child: SizedBox(
          width: 40,
          height: 25,
        ),
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

    // if the battery level is null, draw a unknown battery level indicator with a question mark
    if (batteryLevel == null) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: "?",
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          size.width / 2 - textPainter.width / 2 - 2,
          size.height / 2 - textPainter.height / 2 - 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
