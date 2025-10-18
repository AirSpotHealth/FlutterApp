class ZoneAnalysisData {
  final int greenPercentage;
  final int yellowPercentage;
  final int redPercentage;
  final String dominantZone;
  final int totalDataPoints;

  const ZoneAnalysisData({
    required this.greenPercentage,
    required this.yellowPercentage,
    required this.redPercentage,
    required this.dominantZone,
    required this.totalDataPoints,
  });

  factory ZoneAnalysisData.empty() {
    return const ZoneAnalysisData(
      greenPercentage: 0,
      yellowPercentage: 0,
      redPercentage: 0,
      dominantZone: 'none',
      totalDataPoints: 0,
    );
  }

  bool get hasData => totalDataPoints > 0;

  @override
  String toString() {
    return 'ZoneAnalysisData(green: $greenPercentage%, yellow: $yellowPercentage%, red: $redPercentage%, dominant: $dominantZone, total: $totalDataPoints)';
  }
}

/// Daily zone analysis data with date
class DailyZoneAnalysisData {
  final DateTime date;
  final ZoneAnalysisData zoneData;

  const DailyZoneAnalysisData({
    required this.date,
    required this.zoneData,
  });

  @override
  String toString() {
    return 'DailyZoneAnalysisData(date: $date, data: $zoneData)';
  }
}

/// Contains either single-day or multi-day zone analysis
class ZoneAnalysisResult {
  final ZoneAnalysisData? aggregatedData;
  final List<DailyZoneAnalysisData>? dailyData;
  final bool isMultiDay;

  const ZoneAnalysisResult({
    this.aggregatedData,
    this.dailyData,
    required this.isMultiDay,
  });

  factory ZoneAnalysisResult.singleDay(ZoneAnalysisData data) {
    return ZoneAnalysisResult(
      aggregatedData: data,
      isMultiDay: false,
    );
  }

  factory ZoneAnalysisResult.multiDay(List<DailyZoneAnalysisData> data) {
    return ZoneAnalysisResult(
      dailyData: data,
      isMultiDay: true,
    );
  }

  factory ZoneAnalysisResult.empty() {
    return ZoneAnalysisResult(
      aggregatedData: ZoneAnalysisData.empty(),
      isMultiDay: false,
    );
  }

  bool get hasData =>
      (aggregatedData?.hasData ?? false) || (dailyData?.isNotEmpty ?? false);
}
