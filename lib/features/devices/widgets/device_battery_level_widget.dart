import 'package:airspothealth/features/devices/providers/device_battery_level_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceBatteryLevelWidget extends ConsumerWidget {
  const DeviceBatteryLevelWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    BatteryState batteryState = ref.watch(deviceBatteryLevelProvider(deviceId));

    if (batteryState.level != null && batteryState.level! > 100) {
      batteryState = batteryState.copyWith(level: null);
    }

    // create a battery level indicator
    // when tapped it will show a tooltip with the battery level

    debugPrint(
        'Battery level: ${batteryState.level}, isCharging: ${batteryState.isCharging}');

    return Tooltip(
      message: batteryState.isCharging
          ? 'Charging'
          : batteryState.level != null
              ? "${batteryState.level}%"
              : "Unknown",
      triggerMode: TooltipTriggerMode.tap,
      child: CustomPaint(
        painter: BatteryLevelIndicatorPainter(
            batteryState.level, batteryState.isCharging),
        child: Container(
          alignment: Alignment.topCenter,
          width: 40,
          height: 25,
          padding: EdgeInsets.only(top: 1, right: 4),
          child: batteryState.isCharging
              ? const Icon(
                  Icons.bolt,
                  color: Colors.amberAccent,
                  size: 16,
                )
              : null,
        ),
      ),
    );
  }
}

class BatteryLevelIndicatorPainter extends CustomPainter {
  final int? batteryLevel;

  final bool isCharging;

  BatteryLevelIndicatorPainter(this.batteryLevel, this.isCharging);

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
      ..color = batteryLevel == 0 ? Colors.red : Colors.green;

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
    if (isCharging || batteryLevel != null && batteryLevel! > 0) {
      final double fillWidth = isCharging
          ? batteryWidth - borderWidth * 2
          : ((batteryLevel! / 100) * (batteryWidth - borderWidth * 2));
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

    if (batteryLevel == 0) {
      // show Low text
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: "Low",
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
    return oldDelegate is! BatteryLevelIndicatorPainter ||
        oldDelegate.batteryLevel != batteryLevel ||
        oldDelegate.isCharging != isCharging;
  }
}
