import 'dart:convert';
import 'dart:math' as math;

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/widgets/airspot_chart/echart.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/models/graph_settings.dart';
import 'package:airspothealth/features/device_graph/providers/graph_range_provider.dart';
import 'package:airspothealth/features/device_graph/providers/graph_settings_provider.dart';
import 'package:airspothealth/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// fake data length
const fakeDataLength = 5;

const yAxesValues = [
  350,
  400,
  600,
  800,
  1000,
  1200,
  1400,
  1600,
  2000,
  2500,
  3000,
  3500,
  4000,
  4500,
  5000,
];

class DataGraphWidget extends ConsumerStatefulWidget {
  final List<DeviceData> deviceDataList;

  final bool loading;

  final DeviceSettings deviceSettings;

  const DataGraphWidget({
    super.key,
    required this.deviceDataList,
    required this.deviceSettings,
    this.loading = false,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DataGraphWidgetState();
}

class _DataGraphWidgetState extends ConsumerState<DataGraphWidget> {
  List<DeviceData> get currentDataList => List.from(widget.deviceDataList);

  bool get loading => widget.loading;

  dynamic get greenThreshold => widget.deviceSettings.greenUpperLimit;

  dynamic get amberThreshold => widget.deviceSettings.yellowUpperLimit;

  @override
  Widget build(BuildContext context) {
    final GraphSettings settings = ref.watch(graphSettingsProvider);
    final GraphDataDuration duration = ref.watch(graphDurationProvider);

    final String currentOption = _buildOption(settings, duration);

    return EChart(option: currentOption);
  }

  String _buildOption(GraphSettings settings, GraphDataDuration duration) {
    // Check if there is no data
    if (loading) {
      return Constants.loadingEchartString;
    }

    if (currentDataList.isEmpty) {
      return Constants.noChartDataString;
    }

    final seriesData = _generateSeriesData(currentDataList, duration);
    final fakeData = _generatePreviousAndAfterFakeData(duration);
    // Get the maximum value of the y-axis
    // it should be the maximum value of the data and round it to nearest value of yAxesValues
    final yMax = _calculateYMax();

    return '''
{
  tooltip: {
    trigger: "axis",
    axisPointer: {
      type: "line",
      axis: "x",
      lineStyle: {
        color: '#777',
        width: 1,
        type: 'solid'
      },
    },
    position: function (point, params, dom, rect, size) {
      var x = (size.viewSize[0] - dom.clientWidth) / 2;
      var y = 50;
      return [x, y];
    },

  },
  xAxis: {
    type: 'time',
    boundaryGap: true,
    maxInterval: 1000 * 60 * 60 * 3,
    showSymbol: false,
    symbol: 'circle',
    axisLabel: {
      hideOverlap: true,
      fontSize: 11,
      formatter: {
        year: '{yyyy}',
        month: '{MMM}',
        day: '{dayStyle|{ee}}',
        hour: '${systemTimeFormat.pattern!.contains('a') ? '{hh} {A}' : '{HH}'}',
        minute: '${systemTimeFormat.pattern!.contains('a') ? '{hh}:{mm} {A}' : '{HH}:{mm}'}',
        second: '${systemTimeFormat.pattern!.contains('a') ? '{hh}:{mm}:{ss} {A}' : '{HH}:{mm}:{ss}'}',
        millisecond: '${systemTimeFormat.pattern!.contains('a') ? '{hh}:{mm}:{ss} {SSS} {A}' : '{HH}:{mm}:{ss} {SSS}'}',
        none: '{yyyy}-{MM}-{dd} {hh}:{mm}:{ss} {SSS}'
      },
      rich: {
        dayStyle: {
          fontWeight: 'bold',
        }
      }
    },
    axisLine: {
      show: false,
    },
    splitArea: {
      show: true,
      areaStyle: {
        color: ['#f8f8f8', '#fff']
      }
    },
    offset: 10,
    axisTick: {
      show: false,
    },
    splitLine: {
      show: false,
    }
  },
  yAxis: {
    type: 'value',
    axisLine: {
      lineStyle: {
        color: '#333',
        type: 'solid',
        width: 1
      }
    },
    gridIndex: 0,
    scale: true,
    splitLine: {
      show: true,
      lineStyle: {
        color: '#eee',
        width: 1.5,
        type: 'dashed'
      }
    },
    z: 1,
    min: 350,
    max: $yMax,
    axisLabel: {
      fontSize: 11,
      customValues: ${jsonEncode(yAxesValues)},
      formatter: function (value, index) {
        return value;
      },
      showMinLabel: false,
    }
  },
  dataZoom: [
    {
      type: 'inside',
      filterMode: 'empty',
      xAxisIndex: [0],
      orient: 'horizontal',
      throttle: 50,
    }${settings.showZoomSlider ? ', { type: "slider", start: 0, end: 100 }' : ''}
  ],
  grid: {
    left: 40,
    right: 20,
    top: 50,
    bottom: ${settings.showZoomSlider ? 80 : 50}
  },
  series: [
    {
      name: '${Constants.co2Text} Value',
      type: 'line',
      data: ${jsonEncode(seriesData)},
      ${settings.showAreaFill ? 'areaStyle: { opacity: 0.2 },' : ''}
      smooth: true,
      showSymbol: false,
      symbolSize: 8,
      lineStyle: {
        width: 1
      },
      markLine: ${settings.showMarkLines ? '''
        {
          symbol: ['none', 'none'],
          label: { show: false },
          silent: true,
          animation: false,
          data: [
            { yAxis: $greenThreshold, lineStyle: { color: '#FE9A23', type: 'dashed' } },
            { yAxis: $amberThreshold, lineStyle: { color: '#D9001B', type: 'dashed' } }
          ]
        }
      ''' : 'null'}
    },
    {
      name: '< $greenThreshold',
      type: 'line',
      data: [],
      color: '#63A103',
      lineStyle: { width: 0 }
    },
    {
      name: '$greenThreshold - $amberThreshold',
      type: 'line',
      data: [],
      color: '#FE9A23',
      lineStyle: { width: 0 }
    },
    {
      name: '> $amberThreshold',
      type: 'line',
      data: [],
      color: '#D9001B',
      lineStyle: { width: 0 }
    },
    {
      name: 'FakeData',
      type: 'line',
      data: ${jsonEncode(fakeData)},
      lineStyle: { width: 0 },
      tooltip: { show: false }
    }
  ],
  visualMap: {
    type: 'piecewise',
    show: false,
    dimension: 1,
    pieces: [
      {lte: $greenThreshold, color: '#63A103'},
      {gt: $greenThreshold, lte: $amberThreshold, color: '#FE9A23'},
      {gt: $amberThreshold, color: '#D9001B'}
    ]
  },
  animationEasing: 'linear',
  animationEasingUpdate: 'linear',
  animationDuration: 500,
  stateAnimation: {
    duration: 500,
    easing: 'linear'
  }
}
''';
  }

  List<List<dynamic>> _generateSeriesData(
      List<DeviceData> currentDataList, GraphDataDuration duration) {
    final dataList = currentDataList
        .map((data) => [
              data.dateTime.toLocal().toIso8601String(),
              data.value.toInt().clamp(350, 5000)
            ])
        .toList();

    return dataList;
  }

  // Generate fake data for the previous and after 4 hours of the current data with value null
  // to make the real data in the middle of the chart
  // the data will be used to make the chart look better

  List<List<dynamic>> _generatePreviousAndAfterFakeData(
      GraphDataDuration duration) {
    final range = duration.getDateTimeRange();

    final fakeData = <List<dynamic>>[];

    for (int i = 0; i < fakeDataLength; i++) {
      final fakeDate =
          range.start.subtract(Duration(hours: fakeDataLength - i));
      fakeData.add([fakeDate.toIso8601String(), null]);
    }

    for (int i = 0; i < fakeDataLength; i++) {
      final fakeDate = range.end.add(Duration(hours: i + 1));
      fakeData.add([fakeDate.toIso8601String(), null]);
    }

    return fakeData;
  }

  dynamic _calculateYMax() {
    dynamic yMax = currentDataList
        .fold<int>(
          1600,
          (prevMax, data) => math.max(prevMax, data.value),
        )
        .ceilToDouble();

    return yAxesValues.firstWhere(
      (element) => element >= yMax,
      orElse: () => yAxesValues.last,
    );
  }
}
