import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/device_historical_data_provider.dart';
import 'package:airspothealth/features/device_graph/widgets/data_graph_widget.dart';
import 'package:airspothealth/features/device_graph/widgets/graph_legends.dart';
import 'package:airspothealth/features/device_graph/widgets/graph_range_selector.dart';
import 'package:flutter/cupertino.dart';
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
    _fetchDeviceData(GraphDataDuration.today);
  }

  void _fetchDeviceData(GraphDataDuration duration) {
    // ref
    //     .read(deviceHistoricalDataProvider(deviceId).notifier)
    //     .setDuration(duration);
  }

  @override
  Widget build(BuildContext context) {
    final List<DeviceData> deviceDataList =
        ref.watch(deviceHistoricalDataProvider(deviceId));

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: DataGraphWidget(
            deviceDataList: deviceDataList,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GraphRangeSelector(onRangeSelected: _fetchDeviceData),
        ),
        const Positioned(right: 12, child: GraphLegends()),
        // if (deviceDataList.isNotEmpty)
        //   Positioned.fill(
        //     top: 60,
        //     child: Container(
        //       color: Colors.black.withOpacity(0.2),
        //       child: const CupertinoActivityIndicator(),
        //     ),
        //   )
      ],
    );
  }
}
