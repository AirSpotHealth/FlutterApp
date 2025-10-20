import 'dart:convert' show base64Encode;

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/services/map_handoff_service.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/models/zone_analysis_data.dart';
import 'package:airspothealth/features/device_graph/providers/device_historical_data_provider.dart';
import 'package:airspothealth/features/device_graph/providers/graph_range_provider.dart';
import 'package:airspothealth/features/device_graph/providers/graph_view_mode_provider.dart';
import 'package:airspothealth/features/device_graph/providers/zone_analysis_provider.dart';
import 'package:airspothealth/features/device_graph/widgets/data_graph_widget.dart';
import 'package:airspothealth/features/device_graph/widgets/device_data_transmission_indicator.dart';
import 'package:airspothealth/features/device_graph/widgets/graph_legends.dart';
import 'package:airspothealth/features/device_graph/widgets/graph_range_selector.dart';
import 'package:airspothealth/features/device_graph/widgets/mini_pie_chart_icon.dart';
import 'package:airspothealth/features/device_graph/widgets/zone_pie_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DataGraphWrapper extends ConsumerStatefulWidget {
  const DataGraphWrapper({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  ConsumerState<DataGraphWrapper> createState() => _DataGraphWrapperState();
}

class _DataGraphWrapperState extends ConsumerState<DataGraphWrapper> {
  String? _mapIconDataUrl;

  @override
  void initState() {
    super.initState();
    // check if the duration is today and timerange is not today
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(graphDurationProvider.notifier).validateDateTimeRange();
    });

    _loadMapIcon();
  }

  Future<void> _loadMapIcon() async {
    try {
      final data = await rootBundle.load('assets/images/air_map_icon.png');
      final bytes = data.buffer.asUint8List();
      final b64 = base64Encode(bytes);
      setState(() {
        _mapIconDataUrl = 'data:image/png;base64,$b64';
      });
    } catch (e) {
      debugPrint('Failed to load map icon for tooltip: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final GraphDataDuration duration = ref.watch(graphDurationProvider);
    final AsyncValue<List<DeviceData>> deviceDataList = ref.watch(
        deviceHistoricalDataProvider(
            DeviceHistoryDataRequest(widget.deviceId, duration)));
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(widget.deviceId));
    final GraphViewMode viewMode = ref.watch(graphViewModeProvider);

    final Widget mainContent = viewMode == GraphViewMode.graph
        ? DataGraphWidget(
            deviceSettings: deviceSettings,
            deviceDataList: deviceDataList.valueOrNull ?? const [],
            loading: deviceDataList.isLoading,
            duration: duration,
            mapIconDataUrl: _mapIconDataUrl,
            onMapHandoff: _onMapHandoff,
          )
        : ZonePieChartWidget(deviceId: widget.deviceId);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Main content - either graph or pie chart
        Padding(padding: const EdgeInsets.only(top: 16), child: mainContent),
        // Date range selector
        Positioned(
          top: 8,
          left: 16,
          child: Row(
            children: [
              const GraphRangeSelector(),
              const SizedBox(width: 8),
              _buildViewModeToggle(context, viewMode: viewMode)
            ],
          ),
        ),

        // Legends (only show in graph mode)
        Positioned(
          right: 12,
          child: GraphLegends(
            deviceSettings: deviceSettings,
          ),
        ),
        // Data transmission indicator (show in both modes)
        Align(
          alignment: Alignment.bottomCenter,
          child: DeviceDataTransmissionIndicator(deviceId: widget.deviceId),
        ),
      ],
    );
  }

  Widget _buildViewModeToggle(BuildContext context,
      {required GraphViewMode viewMode}) {
    return GestureDetector(
      onTap: () {
        ref.read(graphViewModeProvider.notifier).toggleViewMode();
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          borderRadius: BorderRadius.circular(8),
        ),
        child: viewMode == GraphViewMode.graph
            ? _buildPieChartToggleIcon()
            : Image.asset(
                'assets/images/air_graph_icon.png',
                width: 24,
                height: 24,
              ),
      ),
    );
  }

  Widget _buildPieChartToggleIcon() {
    final zoneAnalysisResult = ref.watch(zoneAnalysisProvider(widget.deviceId));

    // Get aggregated data for the toggle icon
    // If it's multi-day, we'll show combined data; if single day, show that day's data
    final zoneData = zoneAnalysisResult.aggregatedData ??
        (zoneAnalysisResult.dailyData?.isNotEmpty == true
            ? _calculateCombinedZoneData(zoneAnalysisResult.dailyData!)
            : null);

    return MiniPieChartIcon(
      zoneData: zoneData,
      size: 26,
    );
  }

  /// Calculate combined zone data from multiple days for the toggle icon
  ZoneAnalysisData? _calculateCombinedZoneData(
      List<DailyZoneAnalysisData> dailyData) {
    if (dailyData.isEmpty) return null;

    int totalGreenPoints = 0;
    int totalYellowPoints = 0;
    int totalRedPoints = 0;
    int totalDataPoints = 0;

    for (final day in dailyData) {
      final dayTotal = day.zoneData.totalDataPoints;
      totalGreenPoints +=
          ((day.zoneData.greenPercentage * dayTotal) / 100).round();
      totalYellowPoints +=
          ((day.zoneData.yellowPercentage * dayTotal) / 100).round();
      totalRedPoints += ((day.zoneData.redPercentage * dayTotal) / 100).round();
      totalDataPoints += dayTotal;
    }

    if (totalDataPoints == 0) return null;

    final greenPercentage =
        ((totalGreenPoints / totalDataPoints) * 100).round();
    final yellowPercentage =
        ((totalYellowPoints / totalDataPoints) * 100).round();
    final redPercentage = ((totalRedPoints / totalDataPoints) * 100).round();

    // Determine dominant zone
    String dominantZone;
    if (totalGreenPoints >= totalYellowPoints &&
        totalGreenPoints >= totalRedPoints) {
      dominantZone = 'green';
    } else if (totalYellowPoints >= totalRedPoints) {
      dominantZone = 'yellow';
    } else {
      dominantZone = 'red';
    }

    return ZoneAnalysisData(
      greenPercentage: greenPercentage,
      yellowPercentage: yellowPercentage,
      redPercentage: redPercentage,
      dominantZone: dominantZone,
      totalDataPoints: totalDataPoints,
    );
  }

  void _onMapHandoff(int tsMs, int co2) async {
    debugPrint('Map handoff: $tsMs, $co2');
    // Build and open map handoff with selected ts and co2
    final service = MapHandoffService();
    try {
      final url = await service.buildSignedMapUrl(
        deviceId: widget.deviceId,
        recordLimit: 500,
        useFragment: true,
        tsMs: tsMs,
        selectedCo2: co2,
      );
      debugPrint('Map handoff URL: ${url.toString()}');
      await launchUrlString(url.toString(),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Failed to open map handoff from graph: $e');
    }
  }
}
