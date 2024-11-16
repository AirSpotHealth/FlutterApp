import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'echart_script.dart' show script;

/// <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0, target-densitydpi=device-dpi" /><style type="text/css">body,html,#chart{height: 100%;width: 100%;margin: 0px;}div {-webkit-tap-highlight-color:rgba(255,255,255,0);}</style></head><body><div id="chart" /></body></html>
/// 'data:text/html;base64,' + base64Encode(const Utf8Encoder().convert( /* STRING ABOVE */ ))
const htmlBase64 =
    'PCFET0NUWVBFIGh0bWw+PGh0bWw+PGhlYWQ+PG1ldGEgY2hhcnNldD0idXRmLTgiPjxtZXRhIG5hbWU9InZpZXdwb3J0IiBjb250ZW50PSJ3aWR0aD1kZXZpY2Utd2lkdGgsIGluaXRpYWwtc2NhbGU9MS4wLCBtYXhpbXVtLXNjYWxlPTEuMCwgbWluaW11bS1zY2FsZT0xLjAsIHVzZXItc2NhbGFibGU9MCwgdGFyZ2V0LWRlbnNpdHlkcGk9ZGV2aWNlLWRwaSIgLz48c3R5bGUgdHlwZT0idGV4dC9jc3MiPmJvZHksaHRtbCwjY2hhcnR7aGVpZ2h0OiAxMDAlO3dpZHRoOiAxMDAlO21hcmdpbjogMHB4O31kaXYgey13ZWJraXQtdGFwLWhpZ2hsaWdodC1jb2xvcjpyZ2JhKDI1NSwyNTUsMjU1LDApO308L3N0eWxlPjwvaGVhZD48Ym9keT48ZGl2IGlkPSJjaGFydCIgLz48L2JvZHk+PC9odG1sPg==';

class EChart extends StatefulWidget {
  const EChart({
    super.key,
    required this.option,
  });

  final String option;

  @override
  State<EChart> createState() => _EChartState();
}

class _EChartState extends State<EChart> {
  WebViewController? _controller;

  String get _currentOption => widget.option;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setBackgroundColor(const Color(0x00000000))
      ..loadHtmlString(utf8.fuse(base64).decode(htmlBase64))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) => init(),
          onWebResourceError: (e) {
            debugPrint('Chart error: ${e.description}');
          },
        ),
      )
      ..addJavaScriptChannel('Print',
          onMessageReceived: (JavaScriptMessage javascriptMessage) {
        debugPrint('Chart message: ${javascriptMessage.message}');
      });
  }

  void init() {
    _controller?.runJavaScript('''
      $script;
      var chart = echarts.init(document.getElementById('chart'));
      chart.setOption($_currentOption, true);
      Print.postMessage('Chart initialized');
    ''');
  }

  static const String showTipScript = '''
      chart.on('datazoom', function (params) {

        try {
          const series = chart.getOption().series[0]; // Get the series data
          const data = series.data; // Access the data array

          Print.postMessage("SeriesName: " + series.name);

          // Get the current dataZoom range (start and end)
          const dataZoomComponent = chart.getModel().getComponent('dataZoom').option;
          const startPercent = dataZoomComponent.start;
          const endPercent = dataZoomComponent.end;

          // Calculate the indices of the visible range
          const startIndex = Math.floor((startPercent / 100) * data.length);
          const endIndex = Math.floor((endPercent / 100) * data.length);

          // Calculate the middle index of the visible range
          const middleIndex = Math.floor((startIndex + endIndex) / 2);

          Print.postMessage("Middle index: " + middleIndex);
          Print.postMessage("Middle data point: " + data[middleIndex]);
          Print.postMessage("Data length: " + data.length);

          if (middleIndex < 0 || middleIndex >= data.length) {
            return;
          }
        

          chart.dispatchAction({
              type: 'showTip',
              seriesIndex: 0,
              dataIndex: middleIndex
          });
        } catch (e) {
          Print.postMessage("Error: " + e);
        }
      });
''';

  void update(String preOption) {
    if (_currentOption != preOption) {
      _controller?.runJavaScript('''
        try {
          const parsedOption = typeof $_currentOption === 'string' ? JSON.parse($_currentOption) : $_currentOption;

          const zoom = chart.getOption().dataZoom[0];

          if (!zoom) {
            chart.setOption(parsedOption, true);
          } else {
            parsedOption.dataZoom[0].start = zoom.start;
            parsedOption.dataZoom[0].end = zoom.end;

            chart.setOption(parsedOption, true);
          }
        } catch (e) {
          console.log(e);
        }
''');
    }
  }

  @override
  void didUpdateWidget(EChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    update(oldWidget.option);
  }

  @override
  void dispose() {
    _controller?.clearCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller!);
  }
}
