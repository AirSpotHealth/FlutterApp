import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A small sensor window: one sampled point or an uninterrupted signal.
/// Drawn as vectors so it stays sharp without adding a font or image asset.
class SlimMeasurementIcon extends StatelessWidget {
  const SlimMeasurementIcon({super.key, this.mode, this.size = 32, this.color});

  final PowerMode? mode;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter:
              _MeasurementPainter(mode, color ?? AppColors.primaryColorDark),
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
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Open corners give the mark an instrument-panel silhouette.
    for (final path in [
      Path()
        ..moveTo(3, 10)
        ..lineTo(3, 6)
        ..quadraticBezierTo(3, 3, 6, 3)
        ..lineTo(10, 3),
      Path()
        ..moveTo(22, 3)
        ..lineTo(26, 3)
        ..quadraticBezierTo(29, 3, 29, 6)
        ..lineTo(29, 10),
      Path()
        ..moveTo(29, 22)
        ..lineTo(29, 26)
        ..quadraticBezierTo(29, 29, 26, 29)
        ..lineTo(22, 29),
      Path()
        ..moveTo(10, 29)
        ..lineTo(6, 29)
        ..quadraticBezierTo(3, 29, 3, 26)
        ..lineTo(3, 22),
    ]) {
      canvas.drawPath(path, line);
    }
    if (mode == PowerMode.low) {
      canvas.drawLine(const Offset(6, 16), const Offset(10, 16), line);
      canvas.drawLine(const Offset(22, 16), const Offset(26, 16), line);
      canvas.drawCircle(const Offset(16, 16), 3, Paint()..color = color);
    } else if (mode == PowerMode.high) {
      final signal = Path()
        ..moveTo(5, 17)
        ..lineTo(8, 17)
        ..cubicTo(10, 17, 10, 10, 12, 10)
        ..cubicTo(14, 10, 14, 22, 16, 22)
        ..cubicTo(18, 22, 18, 10, 20, 10)
        ..cubicTo(22, 10, 22, 17, 24, 17)
        ..lineTo(27, 17);
      canvas.drawPath(signal, line);
    } else {
      canvas.drawCircle(const Offset(16, 16), 4, line);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MeasurementPainter oldDelegate) =>
      oldDelegate.mode != mode || oldDelegate.color != color;
}
