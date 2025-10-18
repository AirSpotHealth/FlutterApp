import 'dart:math' as math;

import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/models/zone_analysis_data.dart';
import 'package:airspothealth/features/device_graph/providers/device_historical_data_provider.dart';
import 'package:airspothealth/features/device_graph/providers/graph_range_provider.dart';
import 'package:airspothealth/features/device_graph/providers/zone_analysis_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ZonePieChartWidget extends ConsumerWidget {
  const ZonePieChartWidget({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoneAnalysisResult = ref.watch(zoneAnalysisProvider(deviceId));
    final duration = ref.watch(graphDurationProvider);

    // Check if we're currently loading data
    final isLoading = ref.watch(
      deviceHistoricalDataProvider(
        DeviceHistoryDataRequest(
          deviceId,
          duration,
        ),
      ).select((value) => value.isLoading),
    );

    // Show loading state while data is being fetched
    if (isLoading && !zoneAnalysisResult.hasData) {
      return _buildLoadingState(context);
    }

    if (!zoneAnalysisResult.hasData) {
      return _buildEmptyState(context);
    }

    // Always use compact list view format
    List<DailyZoneAnalysisData> dailyData;

    if (zoneAnalysisResult.isMultiDay && zoneAnalysisResult.dailyData != null) {
      dailyData = zoneAnalysisResult.dailyData!;
    } else if (zoneAnalysisResult.aggregatedData != null) {
      // Convert single day to list format with the date from duration
      dailyData = [
        DailyZoneAnalysisData(
          date: duration.dateTimeRange.start,
          zoneData: zoneAnalysisResult.aggregatedData!,
        ),
      ];
    } else {
      return _buildEmptyState(context);
    }

    // Sort by date descending (newest first)
    dailyData.sort((a, b) => b.date.compareTo(a.date));

    return _buildCompactListView(context, dailyData);
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a date range with recorded data',
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactListView(
      BuildContext context, List<DailyZoneAnalysisData> dailyData) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, 40, 16, 16),
      itemCount: dailyData.length,
      itemBuilder: (context, index) {
        final dayData = dailyData[index];
        return _buildCompactDayRow(context, dayData);
      },
    );
  }

  Widget _buildCompactDayRow(
      BuildContext context, DailyZoneAnalysisData dayData) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final zoneData = dayData.zoneData;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(dayData.date),
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${zoneData.totalDataPoints} readings',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Compact Pie Chart
          SizedBox(
            width: 60,
            height: 60,
            child: CustomPaint(
              painter: _CompactPieChartPainter(
                greenPercentage: zoneData.greenPercentage,
                yellowPercentage: zoneData.yellowPercentage,
                redPercentage: zoneData.redPercentage,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Green Zone Percentage (Primary metric)
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${zoneData.greenPercentage}%',
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Green',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact pie chart painter for multi-day list view
class _CompactPieChartPainter extends CustomPainter {
  final int greenPercentage;
  final int yellowPercentage;
  final int redPercentage;

  _CompactPieChartPainter({
    required this.greenPercentage,
    required this.yellowPercentage,
    required this.redPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw pie slices
    const startAngle = -math.pi / 2;
    double currentAngle = startAngle;

    // Green slice
    if (greenPercentage > 0) {
      final greenPaint = Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.fill;
      final sweepAngle = (greenPercentage * 2 * math.pi) / 100;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 2),
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
        Rect.fromCircle(center: center, radius: radius - 2),
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
        Rect.fromCircle(center: center, radius: radius - 2),
        currentAngle,
        sweepAngle,
        true,
        redPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CompactPieChartPainter oldDelegate) {
    return oldDelegate.greenPercentage != greenPercentage ||
        oldDelegate.yellowPercentage != yellowPercentage ||
        oldDelegate.redPercentage != redPercentage;
  }
}
