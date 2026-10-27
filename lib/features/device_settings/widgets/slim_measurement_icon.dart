import 'dart:math' as math;
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Matches the full-bleed blue tiles and bold white circular marks of the
/// existing reading-rate assets, with a distinct symbol for each acquisition mode.
class SlimMeasurementIcon extends StatelessWidget {
  const SlimMeasurementIcon({super.key, this.mode, this.size = 32, this.color});
  final PowerMode? mode;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _MeasurementPainter(mode, color ?? AppColors.primaryColor),
        ),
      );
}

class _MeasurementPainter extends CustomPainter {
  const _MeasurementPainter(this.mode, this.color);
  final PowerMode? mode;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 32, size.height / 32);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 32, 32), const Radius.circular(4)),
      Paint()..color = color,
    );
    final white = Paint()..color = Colors.white;
    final line = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    const ring = Rect.fromLTWH(4, 4, 24, 24);
    if (mode == PowerMode.singleShotSleep) {
      // Solid crescent, using the same blue tile and white mark as other modes.
      final moon = Path.combine(
          PathOperation.difference,
          Path()..addOval(const Rect.fromLTWH(5, 5, 22, 22)),
          Path()..addOval(const Rect.fromLTWH(12, 1, 20, 20)));
      canvas.drawPath(moon, white);
    } else if (mode == PowerMode.high) {
      // Two sweeping arrows communicate sustained acquisition.
      for (final start in [-math.pi / 2, math.pi / 2]) {
        const sweep = math.pi * 0.82;
        final end = start + sweep;
        final radial = Offset(math.cos(end), math.sin(end));
        final tangent = Offset(-math.sin(end), math.cos(end));
        final tip = const Offset(16, 16) + radial * 12;
        final base = tip - tangent * 4.5;
        canvas.drawArc(ring, start, sweep - 0.22, false, line);
        canvas.drawPath(
          Path()
            ..moveTo(tip.dx, tip.dy)
            ..lineTo((base + radial * 2.7).dx, (base + radial * 2.7).dy)
            ..lineTo((base - radial * 2.7).dx, (base - radial * 2.7).dy)
            ..close(),
          white,
        );
      }
      final signal = Path()
        ..moveTo(9, 16)
        ..cubicTo(11, 16, 11, 11, 13, 11)
        ..cubicTo(15, 11, 15, 21, 17, 21)
        ..cubicTo(19, 21, 19, 16, 23, 16);
      canvas.drawPath(signal, line);
    } else {
      canvas.drawCircle(const Offset(16, 16), 12, line);
      if (mode == PowerMode.low) {
        canvas.drawCircle(const Offset(16, 16), 3.2, white);
        canvas.drawLine(const Offset(7, 16), const Offset(9, 16), line);
        canvas.drawLine(const Offset(23, 16), const Offset(25, 16), line);
      } else {
        canvas.drawLine(const Offset(16, 8), const Offset(16, 16), line);
        canvas.drawLine(const Offset(16, 16), const Offset(21, 19), line);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MeasurementPainter oldDelegate) =>
      oldDelegate.mode != mode || oldDelegate.color != color;
}
