import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/features/device_graph/models/history_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/device_historical_data_provider.dart';
import 'package:airspothealth/features/device_graph/widgets/data_graph_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DataGraphWrapper extends ConsumerStatefulWidget {
  const DataGraphWrapper({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DataGraphWrapperState();
}

class _DataGraphWrapperState extends ConsumerState<DataGraphWrapper> {
  String get deviceId => widget.deviceId;

  @override
  void initState() {
    super.initState();
    _fetchDeviceData(HistoryDataDuration.today);
  }

  void _fetchDeviceData(HistoryDataDuration duration) {
    // ref
    //     .read(deviceHistoricalDataProvider(deviceId).notifier)
    //     .setDuration(duration);
  }

  @override
  Widget build(BuildContext context) {
    final List<DeviceData> deviceDataList =
        ref.watch(deviceHistoricalDataProvider(deviceId));

    return DataGraphWidget(
      deviceDataList: deviceDataList,
    );
  }
}
