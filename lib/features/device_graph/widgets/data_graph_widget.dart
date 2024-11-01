import 'dart:convert';

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/models/graph_settings.dart';
import 'package:airspothealth/features/device_graph/providers/graph_range_provider.dart';
import 'package:airspothealth/features/device_graph/providers/graph_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DataGraphWidget extends ConsumerStatefulWidget {
  final List<DeviceData> deviceDataList;

  const DataGraphWidget({
    super.key,
    required this.deviceDataList,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DataGraphWidgetState();
}

class _DataGraphWidgetState extends ConsumerState<DataGraphWidget> {
  List<DeviceData> get currentDataList => widget.deviceDataList;

  @override
  Widget build(BuildContext context) {
    final GraphSettings settings = ref.watch(graphSettingsProvider);
    final GraphDataDuration duration = ref.watch(graphDurationProvider);

    final String currentOption = _buildOption(settings, duration);

    return Echarts(
      option: currentOption,
      onMessage: (message) {
        debugPrint('Chart message: $message');
      },
    );
  }

  String _buildOption(GraphSettings settings, GraphDataDuration duration) {
    final xData = currentDataList
        .map((data) => _formatDate(data.dateTime, duration: duration))
        .toList();

    final yData = currentDataList.map((data) => data.value.toDouble()).toList();

    // Check if there is no data
    if (xData.isEmpty || yData.isEmpty) {
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

    return '''
    {
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'cross'
        }
      },
      xAxis: {
        type: 'category',
        data: ${jsonEncode(xData)},
        boundaryGap: false,
        axisLabel: {
          hideOverlap: true
        }
      },
      yAxis: {
        type: 'value',
        axisLine: {
          lineStyle: {
            color: '#333'
          }
        },
        min: 350,
        scale: true,
        splitLine: {
          show: true
        }
      },
      dataZoom: [
        {
          type: 'inside',
          start: 0,
          end: 100,
          zoomRate: 0.5
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
          data: ${jsonEncode(yData)},
           ${settings.showAreaFill ? 'areaStyle: { opacity: 0.2 },' : ''}
          smooth: true,
          lineStyle: {
            width: 2
          },
          markLine: ${settings.showMarkLines ? '''
            {
              symbol: ['none', 'none'],
              label: { show: false },
              silent: true,
              animation: false,
              data: [
                { yAxis: 800, lineStyle: { color: '#FE9A23', type: 'dashed', } },
                { yAxis: 1000, lineStyle: { color: '#D9001B', type: 'dashed' } }
              ]
            }
          ''' : 'null'}
        },
        // Dummy series for legend
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
  }
  ''';
  }

  // Menu to toggle chart settings

  String _formatDate(DateTime dateTime, {GraphDataDuration? duration}) {
    final String hm =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    switch (duration) {
      case GraphDataDuration.last7Days:
        return '${dateTime.month}.${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      default:
        return hm;
    }
  }
}
