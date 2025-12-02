import 'dart:math' as math;

import 'package:airspothealth/features/device_graph/models/zone_analysis_data.dart';
import 'package:flutter/material.dart';

/// A mini pie chart icon that shows actual zone data proportions
/// Used in the view mode toggle button to represent current data
/// Can be sized for different use cases (toggle button, larger displays, etc.)
class MiniPieChartIcon extends StatelessWidget {
  const MiniPieChartIcon({
    super.key,
    required this.zoneData,
    this.size = 24.0,
    this.showBorder = false,
    this.strokeWidth = 1.0,
  });

  final ZoneAnalysisData? zoneData;
  final double size;
  final bool showBorder;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    // If no data, show a placeholder circle
    if (zoneData == null || zoneData!.totalDataPoints == 0) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade300,
          border: Border.all(
            color: Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Icon(
          Icons.pie_chart_outline_outlined,
          size: size * 0.6,
          color: Colors.grey.shade500,
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MiniPieChartPainter(
          greenPercentage: zoneData!.greenPercentage,
          yellowPercentage: zoneData!.yellowPercentage,
          redPercentage: zoneData!.redPercentage,
          showBorder: showBorder,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

/// Custom painter for the mini pie chart icon
class _MiniPieChartPainter extends CustomPainter {
  final int greenPercentage;
  final int yellowPercentage;
  final int redPercentage;
  final bool showBorder;
  final double strokeWidth;

  _MiniPieChartPainter({
    required this.greenPercentage,
    required this.yellowPercentage,
    required this.redPercentage,
    required this.showBorder,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw background circle with border
    final backgroundPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw border if enabled
    if (showBorder) {
      final borderPaint = Paint()
        ..color = const Color(0xFFE0E0E0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius, borderPaint);
    }

    // Only draw pie slices if there's actual data
    final totalPercentage = greenPercentage + yellowPercentage + redPercentage;
    if (totalPercentage == 0) return;

    // Draw pie slices with a small inner margin
    const startAngle = -math.pi / 2;
    double currentAngle = startAngle;
    final pieRadius = radius - 2;

    // Green slice
    if (greenPercentage > 0) {
      final greenPaint = Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.fill;
      final sweepAngle = (greenPercentage * 2 * math.pi) / 100;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: pieRadius),
        currentAngle,
        sweepAngle,
        true,
        greenPaint,
      );
      currentAngle += sweepAngle;
    }

    // Yellow slice
    if (yellowPercentage > 0) {
      final yellowPaint = Paint()
        ..color = const Color(0xFFFF9800)
        ..style = PaintingStyle.fill;
      final sweepAngle = (yellowPercentage * 2 * math.pi) / 100;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: pieRadius),
        currentAngle,
        sweepAngle,
        true,
        yellowPaint,
      );
      currentAngle += sweepAngle;
    }

    // Red slice
    if (redPercentage > 0) {
      final redPaint = Paint()
        ..color = const Color(0xFFF44336)
        ..style = PaintingStyle.fill;
      final sweepAngle = (redPercentage * 2 * math.pi) / 100;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: pieRadius),
        currentAngle,
        sweepAngle,
        true,
        redPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniPieChartPainter oldDelegate) {
    return oldDelegate.greenPercentage != greenPercentage ||
        oldDelegate.yellowPercentage != yellowPercentage ||
        oldDelegate.redPercentage != redPercentage ||
        oldDelegate.showBorder != showBorder ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
