import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/device_historical_data_provider.dart';
import 'package:airspothealth/features/device_graph/providers/graph_range_provider.dart';
import 'package:airspothealth/features/device_graph/widgets/data_graph_widget.dart';
import 'package:airspothealth/features/device_graph/widgets/device_data_transmission_indicator.dart';
import 'package:airspothealth/features/device_graph/widgets/graph_legends.dart';
import 'package:airspothealth/features/device_graph/widgets/graph_range_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  void initState() {
    super.initState();
    // check if the duration is today and timerange is not today
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(graphDurationProvider.notifier).validateDateTimeRange();
    });
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
