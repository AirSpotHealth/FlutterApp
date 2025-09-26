import 'dart:convert' show base64Encode;

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/services/map_handoff_service.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/device_historical_data_provider.dart';
import 'package:airspothealth/features/device_graph/providers/graph_range_provider.dart';
import 'package:airspothealth/features/device_graph/widgets/data_graph_widget.dart';
import 'package:airspothealth/features/device_graph/widgets/device_data_transmission_indicator.dart';
import 'package:airspothealth/features/device_graph/widgets/graph_legends.dart';
import 'package:airspothealth/features/device_graph/widgets/graph_range_selector.dart';
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

    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: DataGraphWidget(
            deviceSettings: deviceSettings,
            deviceDataList: deviceDataList.valueOrNull ?? const [],
            loading: deviceDataList.isLoading,
            duration: duration,
            mapIconDataUrl: _mapIconDataUrl,
            // Wire map handoff via chart bridge
            onMapHandoff: (tsMs, co2) async {
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
            },
          ),
        ),
        Positioned(
          top: 8,
          left: 16,
          child: const GraphRangeSelector(),
        ),
        Positioned(
          right: 12,
          child: GraphLegends(
            deviceSettings: deviceSettings,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: DeviceDataTransmissionIndicator(deviceId: widget.deviceId),
        ),
      ],
    );
  }
}
