import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A filled sensor tile with a cut-out sample point or continuous signal.
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
    // Isolate the cut-outs so they reveal the actual row/card background.
    canvas.saveLayer(const Rect.fromLTWH(0, 0, 32, 32), Paint());
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(2, 2, 28, 28), const Radius.circular(7)),
      Paint()..color = color,
    );
    final line = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (mode == PowerMode.low) {
      canvas.drawLine(const Offset(6, 16), const Offset(10, 16), line);
      canvas.drawLine(const Offset(22, 16), const Offset(26, 16), line);
      canvas.drawCircle(
          const Offset(16, 16), 3, Paint()..blendMode = BlendMode.clear);
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
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MeasurementPainter oldDelegate) =>
      oldDelegate.mode != mode || oldDelegate.color != color;
}
