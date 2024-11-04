import 'dart:convert';

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/widgets/airspot_chart/echart.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/models/graph_settings.dart';
import 'package:airspothealth/features/device_graph/providers/graph_range_provider.dart';
import 'package:airspothealth/features/device_graph/providers/graph_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DataGraphWidget extends ConsumerStatefulWidget {
  final List<DeviceData> deviceDataList;

  final bool loading;

  const DataGraphWidget({
    super.key,
    required this.deviceDataList,
    this.loading = false,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DataGraphWidgetState();
}

class _DataGraphWidgetState extends ConsumerState<DataGraphWidget> {
  List<DeviceData> get currentDataList => widget.deviceDataList;

  bool get loading => widget.loading;

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
      return '''
    {
      title: {
        text: '',
      },
      graphic: {
    elements: [
      {
        type: 'group',
        left: 'center',
        top: 'center',
        children: new Array(7).fill(0).map((val, i) => ({
          type: 'rect',
          x: i * 20,
          shape: {
            x: 0,
            y: -40,
            width: 10,
            height: 80
          },
          style: {
            fill: '#009FD7'
          },
          keyframeAnimation: {
            duration: 500,
            delay: i * 200,
            loop: true,
            keyframes: [
              {
                percent: 0.5,
                scaleY: 0.3,
                easing: 'cubicIn'
              },
              {
                percent: 1,
                scaleY: 1,
                easing: 'cubicOut'
              }
            ]
          }
        }))
      }
    ]
  }
    }
    ''';
    }

    if (currentDataList.isEmpty) {
      return '''
    {
      title: {
        text: 'No data available',
        left: 'center',
        top: 'center',
        textStyle: {
          color: '#333',
          fontSize: 16
        }
      }
    }
    ''';
    }

    final seriesData = _generateSeriesData(currentDataList, duration);
    final fakeData = _generatePreviousAndAfterFakeData(duration);

    return '''
{
  tooltip: {
    trigger: "axis",
    axisPointer: {
      type: "none",
      snap: true,
      triggerOn: "none",
      handle: {
        show: true,
        size: 45,
      }
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
    minInterval: 1000 * 60 * 60,
    maxInterval: 1000 * 60 * 60 * 3,
    interval: 1000 * 60 * 60 * 3,
    axisLabel: {
      hideOverlap: true,
      fontSize: 11,
      formatter: function (value,index) {
        var date = new Date(value);
        var day = date.getDate();

        if (day === 1 || day === new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate()) {
          return date.toLocaleString('en-au', { month: 'short' }) + ' ' + day;
        }

        if (date.getHours() === 0) {
          return date.toLocaleString('en-au', { weekday: 'short' }).toUpperCase();
        }

        if (date.getHours() === 23) {
          return date.toLocaleString('en-au', { weekday: 'short' }).toUpperCase();
        }

        return date.toLocaleString('en-au', { hour: 'numeric', hour12: true }).padStart(2, '0').toUpperCase();
      
      },
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
    scale: false,
    splitLine: {
      show: true,
      lineStyle: {
        color: '#f2f2f2',
        width: 2,
        type: 'dashed'
      }
    },
    z: 1,
    min: 350    
  },
  dataZoom: [
    {
      type: 'inside',
      start: 60,
      end: 100,
      filterMode: 'empty',
      xAxisIndex: [0],
      orient: 'horizontal',
      throttle: 50
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
      name: 'CO2 Value',
      type: 'line',
      data: ${jsonEncode(seriesData)},
      ${settings.showAreaFill ? 'areaStyle: { opacity: 0.2 },' : ''}
      smooth: true,
      showSymbol: false,
      lineStyle: {
        width: 1.5
      },
      markLine: ${settings.showMarkLines ? '''
        {
          symbol: ['none', 'none'],
          label: { show: false },
          silent: true,
          animation: false,
          data: [
            { yAxis: 800, lineStyle: { color: '#FE9A23', type: 'dashed' } },
            { yAxis: 1000, lineStyle: { color: '#D9001B', type: 'dashed' } }
          ]
        }
      ''' : 'null'}
    },
    {
      name: '< 800',
      type: 'line',
      data: [],
      color: '#63A103',
      lineStyle: { width: 0 }
    },
    {
      name: '800 - 1000',
      type: 'line',
      data: [],
      color: '#FE9A23',
      lineStyle: { width: 0 }
    },
    {
      name: '> 1000',
      type: 'line',
      data: [],
      color: '#D9001B',
      lineStyle: { width: 0 }
    },
    {
      name: 'FakeData',
      type: 'line',
      data: ${jsonEncode(fakeData)},
      lineStyle: { width: 0 }
    }
  ],
  visualMap: {
    type: 'piecewise',
    show: false,
    dimension: 1,
    pieces: [
      {lte: 800, color: '#63A103'},
      {gt: 800, lte: 1000, color: '#FE9A23'},
      {gt: 1000, color: '#D9001B'}
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
              data.dateTime.toIso8601String(),
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
    final (graphStartDate, graphEndDate) = duration.getDateTimeRange();

    final fakeData = <List<dynamic>>[];

    const fakeDataLength = 8;

    for (int i = 0; i < fakeDataLength; i++) {
      final fakeDate =
          graphStartDate.subtract(Duration(hours: fakeDataLength - i));
      fakeData.add([fakeDate.toIso8601String(), null]);
    }

    for (int i = 0; i < fakeDataLength; i++) {
      final fakeDate = graphEndDate.add(Duration(hours: i + 1));
      fakeData.add([fakeDate.toIso8601String(), null]);
    }

    return fakeData;
  }
}
