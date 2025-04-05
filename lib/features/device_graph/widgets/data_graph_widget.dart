import 'dart:convert';
import 'dart:math' as math;

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/widgets/airspot_chart/echart.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/models/graph_settings.dart';
import 'package:airspothealth/features/device_graph/providers/graph_settings_provider.dart';
import 'package:airspothealth/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// fake data lengths
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

class RebreatheTable {
  final int co2;
  final double rebreathed;
  final int? oneInXBreaths;

  RebreatheTable({
    required this.co2,
    required this.rebreathed,
    this.oneInXBreaths,
  });
}

final rebreatheTable = [
  // [CO2 ppm, rebreathed %, 1 in X breaths]
  RebreatheTable(co2: 400, rebreathed: 0, oneInXBreaths: null),
  RebreatheTable(co2: 800, rebreathed: 1, oneInXBreaths: 100),
  RebreatheTable(co2: 1200, rebreathed: 2, oneInXBreaths: 50),
  RebreatheTable(co2: 1600, rebreathed: 3, oneInXBreaths: 33),
  RebreatheTable(co2: 2000, rebreathed: 4, oneInXBreaths: 25),
  RebreatheTable(co2: 2400, rebreathed: 5, oneInXBreaths: 20),
  RebreatheTable(co2: 2800, rebreathed: 6, oneInXBreaths: 17),
  RebreatheTable(co2: 3200, rebreathed: 7, oneInXBreaths: 14),
  RebreatheTable(co2: 3600, rebreathed: 8, oneInXBreaths: 13),
  RebreatheTable(co2: 4000, rebreathed: 9, oneInXBreaths: 11),
  RebreatheTable(co2: 4400, rebreathed: 10, oneInXBreaths: 10),
  RebreatheTable(co2: 4800, rebreathed: 11, oneInXBreaths: 9),
  RebreatheTable(co2: 5200, rebreathed: 12, oneInXBreaths: 8),
];

class DataGraphWidget extends ConsumerStatefulWidget {
  final List<DeviceData> deviceDataList;

  final bool loading;

  final DeviceSettings deviceSettings;

  final GraphDataDuration duration;

  const DataGraphWidget({
    super.key,
    required this.deviceDataList,
    required this.deviceSettings,
    required this.duration,
    this.loading = false,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DataGraphWidgetState();

  // Make this a static method since it's a pure calculation
  static double calculateRebreathePercentage(num co2Value) {
    // For values below first entry
    if (co2Value <= rebreatheTable[0].co2) return 0;
    // For values above last entry
    if (co2Value >= rebreatheTable.last.co2) {
      return rebreatheTable.last.rebreathed.toDouble();
    }

    // Find the appropriate interval in the table
    for (int i = 0; i < rebreatheTable.length - 1; i++) {
      if (co2Value >= rebreatheTable[i].co2 &&
          co2Value < rebreatheTable[i + 1].co2) {
        final co2Lower = rebreatheTable[i].co2;
        final co2Upper = rebreatheTable[i + 1].co2;
        final percentLower = rebreatheTable[i].rebreathed;
        final percentUpper = rebreatheTable[i + 1].rebreathed;

        // Linear interpolation between points
        return percentLower +
            (co2Value - co2Lower) *
                (percentUpper - percentLower) /
                (co2Upper - co2Lower);
      }
    }

    return 0; // Fallback
  }
}

class _DataGraphWidgetState extends ConsumerState<DataGraphWidget> {
  List<DeviceData> get currentDataList => List.from(widget.deviceDataList);

  bool get loading => widget.loading;

  dynamic get greenThreshold => widget.deviceSettings.greenUpperLimit;

  dynamic get amberThreshold => widget.deviceSettings.yellowUpperLimit;

  late GraphDataDuration duration = widget.duration;

  @override
  void didUpdateWidget(DataGraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      duration = widget.duration;
    }
  }

  @override
  Widget build(BuildContext context) {
    final GraphSettings settings = ref.watch(graphSettingsProvider);

    final String currentOption = _buildOption(settings, duration.dateTimeRange);

    return EChart(option: currentOption);
  }

  String _buildOption(GraphSettings settings, DateTimeRange range) {
    // Check if there is no data
    if (loading) {
      return Constants.loadingEchartString;
    }

    if (currentDataList.isEmpty) {
      return Constants.noChartDataString;
    }

    final seriesData = _generateSeriesData(currentDataList);

    // Calculate rebreathed data and max percentage
    double maxRebreathePercentage = 4; // Default minimum range
    final rebreatheData = settings.showRebreathePercentage
        ? seriesData.map((data) {
            final co2Value = data[1] as num;
            final percentage =
                DataGraphWidget.calculateRebreathePercentage(co2Value);
            maxRebreathePercentage =
                math.max(maxRebreathePercentage, percentage);
            return [data[0], percentage];
          }).toList()
        : [];

    // Round up to the next multiple of 2 for clean intervals
    maxRebreathePercentage = (maxRebreathePercentage / 2).ceil() * 2;

    final fakeData = _generatePreviousAndAfterFakeData(range);
    // Get the maximum value of the y-axis
    // it should be the maximum value of the data and round it to nearest value of yAxesValues
    final yMax = _calculateYMax();

    final is12Hour = systemTimeFormat.pattern!.contains('a');

    // Check if we're viewing today's data only by checking duration name
    final isToday = duration.name == 'today';

    // For today's view, set explicit min and max for x-axis
    String xAxisMinMax = '';
    if (isToday) {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      xAxisMinMax = ''',
      min: "${startOfDay.toIso8601String()}",
      max: "${endOfDay.toIso8601String()}"''';
    }

    return '''
{
  tooltip: {
    trigger: 'axis',
    formatter: function(params) {
      if (!params || params.length === 0) return '';
      
      var date = new Date(params[0].value[0]);
      var hours = date.getHours();
      var minutes = date.getMinutes();
      var seconds = date.getSeconds();
      var timeStr = $is12Hour 
        ? ((hours % 12 || 12) + ':' + (minutes < 10 ? '0' : '') + minutes + ':' + (seconds < 10 ? '0' : '') + seconds + ' ' + (hours >= 12 ? 'PM' : 'AM'))
        : ((hours < 10 ? '0' : '') + hours + ':' + (minutes < 10 ? '0' : '') + minutes + ':' + (seconds < 10 ? '0' : '') + seconds);
      
      var result = date.toLocaleDateString() + ' ' + timeStr + '<br/>';
      
      for (var i = 0; i < params.length; i++) {
        var param = params[i];
        if (param.seriesName === 'CO₂') {
          result += 'CO₂: ' + param.value[1] + ' ppm<br/>';
        } else if (param.seriesName === 'Rebreathed Air' && param.value[1] != null) {
          result += 'Rebreathed: ' + param.value[1].toFixed(1) + '%';
        }
      }
      
      return result;
    },
    axisPointer: {
      type: 'line',
      axis: 'x'
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
    symbol: 'circle'$xAxisMinMax,
    axisLabel: {
      hideOverlap: true,
      fontSize: 11,
      formatter: {
        year: '{yyyy}',
        month: '{MMM}',
        day: '{dayStyle|{ee}}',
        hour: '${is12Hour ? '{hh} {A}' : '{HH}'}',
        minute: '${is12Hour ? '{hh}:{mm} {A}' : '{HH}:{mm}'}',
        second: '${is12Hour ? '{hh}:{mm}:{ss} {A}' : '{HH}:{mm}:{ss}'}',
        millisecond: '${is12Hour ? '{hh}:{mm}:{ss} {SSS} {A}' : '{HH}:{mm}:{ss} {SSS}'}',
        none: '${is12Hour ? '{hh}:{mm}:{ss} {A}' : '{HH}:{mm}:{ss}'}'
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
  yAxis: [
    {
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
      min: 300,
      max: $yMax,
      axisLabel: {
        fontSize: 11,
        customValues: ${jsonEncode(yAxesValues)},
        formatter: function (value, index) {
          return value;
        },
        showMinLabel: false,
      }
    }${settings.showRebreathePercentage ? ''',
    {
      type: 'value',
      name: '',
      position: 'right',
      min: 0,
      max: $maxRebreathePercentage,
      interval: ${maxRebreathePercentage <= 6 ? 1 : 2},
      axisLabel: {
        formatter: '{value}%'
      }
    }''' : ''}
  ],
  dataZoom: [
    {
      type: 'inside',
      filterMode: 'empty',
      xAxisIndex: [0],
      orient: 'horizontal',
      throttle: 50,
      start: 0,
      end: 100
    }
  ],
  grid: {
    left: 40,
    right: ${settings.showRebreathePercentage ? '40' : '20'},
    top: 50,
    bottom: ${settings.showZoomSlider ? 80 : 50}
  },
  series: [
    {
      name: 'CO₂',
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
      ''' : 'null'},
    }${settings.showRebreathePercentage ? ''',
    {
      name: 'Rebreathed Air',
      type: 'line',
      yAxisIndex: 1,
      data: ${jsonEncode(rebreatheData)},
      showSymbol: false,
      lineStyle: {
        type: 'dashed',
        color: '#666',
        width: 0
      }
    }''' : ''},
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

  List<List<dynamic>> _generateSeriesData(List<DeviceData> currentDataList) {
    debugPrint('currentDataList: ${currentDataList.map((e) => e.dateTime)}');
    final dataList = currentDataList
        .map((data) => [
              data.dateTime.toLocal().toIso8601String(),
              data.value.toInt().clamp(0, 5000)
            ])
        .toList();

    return dataList;
  }

  // Generate fake data for the previous and after 4 hours of the current data with value null
  // to make the real data in the middle of the chart
  // the data will be used to make the chart look better

  List<List<dynamic>> _generatePreviousAndAfterFakeData(DateTimeRange range) {
    final fakeData = <List<dynamic>>[];

    // Check if we're viewing today's data only by checking duration name
    final isToday = duration.name == 'today';

    if (isToday) {
      // For today, add padding from start of day to first data point
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);

      // Only add if the range doesn't start at the beginning of the day
      if (range.start.isAfter(startOfDay)) {
        // Add data point at 12 AM (midnight)
        fakeData.add([startOfDay.toIso8601String(), null]);

        // Add a few more points between midnight and first data point if there's a big gap
        final hourDifference = range.start.difference(startOfDay).inHours;
        if (hourDifference > 2) {
          for (int i = 1; i < hourDifference; i++) {
            final fakeDate = startOfDay.add(Duration(hours: i));
            fakeData.add([fakeDate.toIso8601String(), null]);
          }
        }
      }
    } else {
      // For non-today views, use the original padding
      for (int i = 0; i < fakeDataLength; i++) {
        final fakeDate =
            range.start.subtract(Duration(hours: fakeDataLength - i));
        fakeData.add([fakeDate.toIso8601String(), null]);
      }

      for (int i = 0; i < fakeDataLength; i++) {
        final fakeDate = range.end.add(Duration(hours: i + 1));
        fakeData.add([fakeDate.toIso8601String(), null]);
      }
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
