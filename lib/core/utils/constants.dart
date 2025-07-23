import 'package:airspothealth/core/utils/local_date_format.dart';
import 'package:intl/intl.dart';

class Constants {
  static const String baseUrl = 'https://update.airspothealth.com/api';

  static const String mapUrl = 'https://airspot-map.vercel.app/';

  // UUIDs for the service and characteristics
  static const String serviceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String notifyUuid = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String writeUuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";

  static const String greenUpperLimit = "greenThreshold";
  static const int defaultGreenUpperLimit = 800;

  static const String yellowUpperLimit = "yellowThreshold";
  static const int defaultYellowUpperLimit = 1000;

  static const int defaultco2AlertThreshold = 2000;

  static const List<int> co2PPMValues = [
    400,
    500,
    600,
    700,
    800,
    900,
    1000,
    1100,
    1200,
    1300,
    1400,
    1500,
    1600,
    1700,
    1800,
    1900,
    2000
  ];

  static const String solutionsUrl =
      'https://airspothealth.com/a/blog/category/';

  static const String homeWidgetKey = 'airspot_home_widget';
  static const String appGroupId = 'group.com.airspot.lohas';
  static const String iOSWidgetName = 'Co2ValueWidget';
  static const String androidWidgetName = 'airspothealth.Co2ValueWidget';

  static const String subscript2 = '₂';

  static const String co2Text = 'CO₂';

  /// loading echart html string
  static const loadingEchartString = '''
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

  /// no data echart html string
  static const String noChartDataString = '''
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

  static const int maxFlashPageCount = 16384;

  static const int syncedTimeThreshold = 978267600000;

  static const int emptyFlashDate = 0xFFFFFFFF;

  static final DateFormat csvDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String echartTimeFormat() {
    // Get system date and time format
    String sDFormat =
        LocalDateFormat.instance.systemDateFormat.pattern ?? "d/M/y";
    String sTFormat = LocalDateFormat.instance.systemTimeFormat.pattern ??
        "h:mm a"; // Fallback if null

    // Mapping Date Format
    String formattedDate = sDFormat
        .replaceAll('y', '{yyyy}')
        .replaceAll('M', '{MM}')
        .replaceAll('d', '{dd}');

    // Mapping Time Format
    String formattedTime = sTFormat
        .replaceAllMapped(
            RegExp(r'(?<!H)h+'), (match) => '{hh}') // 12-hour format
        .replaceAll('HH', '{HH}') // 24-hour format
        .replaceAll('mm', '{mm}')
        .replaceAll('ss', '{ss}')
        .replaceAll('SSS', '{SSS}')
        .replaceAllMapped(RegExp(r'a'), (match) => '{A}'); // AM/PM

    // Construct the formatter map
    return '''
{
      'year': '{yyyy}',
      'month': '{MM}',
      'day': '{dd}',
      'hour': formattedTime.contains('{A}')
          ? '{hh} {A}'
          : '{HH}', // 12-hour vs. 24-hour
      'minute': formattedTime.contains('{A}') ? '{hh}:{mm} {A}' : '{HH}:{mm}',
      'second': formattedTime.contains('{A}')
          ? '{hh}:{mm}:{ss} {A}'
          : '{HH}:{mm}:{ss}',
      'millisecond': formattedTime.contains('{A}')
          ? '{hh}:{mm}:{ss} {SSS} {A}'
          : '{HH}:{mm}:{ss} {SSS}',
      'none': '$formattedDate $formattedTime'
    }
  ''';
  }
}
