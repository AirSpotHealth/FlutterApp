import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:isar_plus/isar_plus.dart';

/// Service responsible for analyzing CO2 zone data and calculating percentages
/// Follows single responsibility principle - only handles zone analysis logic
class ZoneAnalysisService {
  static final ZoneAnalysisService _instance = ZoneAnalysisService._internal();
  factory ZoneAnalysisService() => _instance;
  ZoneAnalysisService._internal();

  final IsarService _isarService = IsarService();

  /// Calculate zone percentages for today's CO2 readings
  Future<ZoneAnalysisResult> calculateZonePercentages({
    required String deviceId,
    required int greenUpperLimit,
    required int yellowUpperLimit,
  }) async {
    // Get today's CO2 readings from database
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final todayReadings = await _isarService.readAsync<List<int>>((isar) {
      const co2TypeIndex = 0; // DeviceDataType.co2.index
      return isar.deviceDatas
          .where()
          .deviceIdEqualTo(deviceId)
          .typeEqualTo(co2TypeIndex)
          .dateTimeBetween(startOfDay, endOfDay)
          .valueProperty()
          .findAll();
    });

    // Calculate zone analysis
    return _analyzeZoneData(
      readings: todayReadings,
      greenUpperLimit: greenUpperLimit,
      yellowUpperLimit: yellowUpperLimit,
    );
  }

  /// Analyze CO2 readings and determine zone percentages
  ZoneAnalysisResult _analyzeZoneData({
    required List<int> readings,
    required int greenUpperLimit,
    required int yellowUpperLimit,
  }) {
    if (readings.isEmpty) {
      return ZoneAnalysisResult.empty();
    }

    // Count readings in each zone
    int greenCount = 0;
    int yellowCount = 0;
    int redCount = 0;

    for (final value in readings) {
      if (value <= greenUpperLimit) {
        greenCount++;
      } else if (value <= yellowUpperLimit) {
        yellowCount++;
      } else {
        redCount++;
      }
    }

    final totalReadings = readings.length;

    // Calculate percentages using integer arithmetic for better performance
    final greenPercentage = ((greenCount * 100) / totalReadings).round();
    final yellowPercentage = ((yellowCount * 100) / totalReadings).round();
    final redPercentage = ((redCount * 100) / totalReadings).round();

    // Determine dominant zone
    final dominantZone = _determineDominantZone(
      greenCount: greenCount,
      yellowCount: yellowCount,
      redCount: redCount,
    );

    final dominantZonePercentage = _getDominantZonePercentage(
      dominantZone: dominantZone,
      greenPercentage: greenPercentage,
      yellowPercentage: yellowPercentage,
      redPercentage: redPercentage,
    );

    return ZoneAnalysisResult(
      greenZonePercentage: greenPercentage,
      yellowZonePercentage: yellowPercentage,
      redZonePercentage: redPercentage,
      dominantZone: dominantZone,
      dominantZonePercentage: dominantZonePercentage,
    );
  }

  /// Determine which zone has the highest count
  String _determineDominantZone({
    required int greenCount,
    required int yellowCount,
    required int redCount,
  }) {
    if (greenCount >= yellowCount && greenCount >= redCount) {
      return 'green';
    } else if (yellowCount >= redCount) {
      return 'yellow';
    } else {
      return 'red';
    }
  }

  /// Get the percentage for the dominant zone
  int _getDominantZonePercentage({
    required String dominantZone,
    required int greenPercentage,
    required int yellowPercentage,
    required int redPercentage,
  }) {
    switch (dominantZone) {
      case 'green':
        return greenPercentage;
      case 'yellow':
        return yellowPercentage;
      case 'red':
        return redPercentage;
      default:
        return 0;
    }
  }
}

/// Data class representing the result of zone analysis
class ZoneAnalysisResult {
  final int greenZonePercentage;
  final int yellowZonePercentage;
  final int redZonePercentage;
  final String dominantZone;
  final int dominantZonePercentage;

  const ZoneAnalysisResult({
    required this.greenZonePercentage,
    required this.yellowZonePercentage,
    required this.redZonePercentage,
    required this.dominantZone,
    required this.dominantZonePercentage,
  });

  /// Factory constructor for empty result
  factory ZoneAnalysisResult.empty() {
    return const ZoneAnalysisResult(
      greenZonePercentage: 0,
      yellowZonePercentage: 0,
      redZonePercentage: 0,
      dominantZone: 'none',
      dominantZonePercentage: 0,
    );
  }

  /// Convert to map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'greenZonePercentage': greenZonePercentage,
      'yellowZonePercentage': yellowZonePercentage,
      'redZonePercentage': redZonePercentage,
      'dominantZone': dominantZone,
      'dominantZonePercentage': dominantZonePercentage,
    };
  }

  @override
  String toString() {
    return 'ZoneAnalysisResult(green: $greenZonePercentage%, yellow: $yellowZonePercentage%, red: $redZonePercentage%, dominant: $dominantZone $dominantZonePercentage%)';
  }
}
