import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/features/device_graph/models/zone_analysis_data.dart';
import 'package:airspothealth/features/device_graph/providers/device_historical_data_provider.dart';
import 'package:airspothealth/features/device_graph/providers/graph_range_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider that calculates zone analysis for device data
final zoneAnalysisProvider = Provider.family<ZoneAnalysisResult, String>(
  (ref, deviceId) {
    // Get the current duration
    final duration = ref.watch(graphDurationProvider);

    // Get device data for the selected duration
    final deviceDataAsync = ref.watch(
      deviceHistoricalDataProvider(
        DeviceHistoryDataRequest(deviceId, duration),
      ),
    );

    // Get device settings for thresholds
    final deviceSettings = ref.watch(deviceSettingsProvider(deviceId));

    // If data is not loaded or empty, return empty analysis
    if (!deviceDataAsync.hasValue || deviceDataAsync.value == null) {
      return ZoneAnalysisResult.empty();
    }

    final deviceDataList = deviceDataAsync.value!;

    // Filter only CO2 data points
    final co2DataList = deviceDataList
        .where((data) => data.type == DeviceDataType.co2.index)
        .toList();

    if (co2DataList.isEmpty) {
      return ZoneAnalysisResult.empty();
    }

    final greenUpperLimit = deviceSettings.greenUpperLimit;
    final yellowUpperLimit = deviceSettings.yellowUpperLimit;

    // Check if the range spans multiple days
    final startDate = DateTime(
      duration.dateTimeRange.start.year,
      duration.dateTimeRange.start.month,
      duration.dateTimeRange.start.day,
    );
    final endDate = DateTime(
      duration.dateTimeRange.end.year,
      duration.dateTimeRange.end.month,
      duration.dateTimeRange.end.day,
    );
    final daysDifference = endDate.difference(startDate).inDays;

    if (daysDifference == 0) {
      // Single day - return aggregated data
      final analysis = _calculateZoneAnalysis(
        co2DataList,
        greenUpperLimit,
        yellowUpperLimit,
      );
      return ZoneAnalysisResult.singleDay(analysis);
    } else {
      // Multiple days - return daily breakdown
      final dailyAnalysis = <DailyZoneAnalysisData>[];

      for (int i = 0; i <= daysDifference; i++) {
        final currentDate = startDate.add(Duration(days: i));
        final nextDate = currentDate.add(const Duration(days: 1));

        // Filter data for this specific day
        final dayData = co2DataList.where((data) {
          return data.dateTime.isAfter(currentDate) &&
              data.dateTime.isBefore(nextDate);
        }).toList();

        if (dayData.isNotEmpty) {
          final analysis = _calculateZoneAnalysis(
            dayData,
            greenUpperLimit,
            yellowUpperLimit,
          );
          dailyAnalysis.add(DailyZoneAnalysisData(
            date: currentDate,
            zoneData: analysis,
          ));
        }
      }

      return ZoneAnalysisResult.multiDay(dailyAnalysis);
    }
  },
);

ZoneAnalysisData _calculateZoneAnalysis(
  List<dynamic> dataList,
  int greenUpperLimit,
  int yellowUpperLimit,
) {
  int greenCount = 0;
  int yellowCount = 0;
  int redCount = 0;

  for (final data in dataList) {
    final value = data.value;

    if (value < greenUpperLimit) {
      greenCount++;
    } else if (value < yellowUpperLimit) {
      yellowCount++;
    } else {
      redCount++;
    }
  }

  final totalCount = dataList.length;

  if (totalCount == 0) {
    return ZoneAnalysisData.empty();
  }

  // Calculate percentages
  final greenPercentage = ((greenCount / totalCount) * 100).round();
  final yellowPercentage = ((yellowCount / totalCount) * 100).round();
  final redPercentage = ((redCount / totalCount) * 100).round();

  // Determine dominant zone
  String dominantZone;
  if (greenCount >= yellowCount && greenCount >= redCount) {
    dominantZone = 'green';
  } else if (yellowCount >= redCount) {
    dominantZone = 'yellow';
  } else {
    dominantZone = 'red';
  }

  return ZoneAnalysisData(
    greenPercentage: greenPercentage,
    yellowPercentage: yellowPercentage,
    redPercentage: redPercentage,
    dominantZone: dominantZone,
    totalDataPoints: totalCount,
  );
}
