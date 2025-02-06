import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'echart_script.dart' show script;

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

  bool _zoomed = false;

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
    debugPrint('Chart initialized.');
    _controller?.runJavaScript('''
      $script;
      var chart = echarts.init(document.getElementById('chart'));
      chart.setOption($_currentOption, true);
      // Global tooltip auto-hide logic

      // Global tooltip debounce logic
      (function() {
        console.log("Global tooltip auto-hide script initialized.");

        let tooltipTimeout = null;

        chart.on("showTip", function (params) {
          console.log("Tooltip shown for index:", params.dataIndex);

          // If there is an active timeout, clear it
          if (tooltipTimeout) {
            clearTimeout(tooltipTimeout);
            console.log("Existing timeout cleared.");
          }

          // Start a new timeout (always ensure tooltip hides)
          tooltipTimeout = setTimeout(() => {
            chart.dispatchAction({ type: 'hideTip' });
            chart.dispatchAction({
              type: 'updateAxisPointer',
              currTrigger: 'leave',
              dataIndex: -1
            });
            console.log("Tooltip auto-hidden after 3 seconds.");
            tooltipTimeout = null; // Reset timeout
          }, 3000);
        });

      })();
    ''');
  }

  void update(String preOption) {
    if (_currentOption != preOption) {
      _controller?.runJavaScript('''
        ( function() {
        try {
          const parsedOption = typeof $_currentOption === 'string' ? JSON.parse($_currentOption) : $_currentOption;

          const zoom = chart.getOption().dataZoom[0];

          if (!zoom) {
            chart.setOption(parsedOption, true);
          } else {
            parsedOption.dataZoom[0].start = zoom.start;
            parsedOption.dataZoom[0].end = zoom.end;

            console.log('Old zoom: ', zoom.start, zoom.end);

            chart.setOption(parsedOption, true);
          }
        } catch (e) {
          const parsedOption = typeof $_currentOption === 'string' ? JSON.parse($_currentOption) : $_currentOption;
          console.error(e);
          chart.setOption(parsedOption, true);
        }
      })();
''');
    }
  }

  @override
  void didUpdateWidget(EChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => update(oldWidget.option));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller!),
        Positioned(
          right: 8,
          top: 48,
          child: IconButton(
            onPressed: _toggleZoom,
            icon: Icon(_zoomed ? Icons.zoom_out : Icons.zoom_in),
          ),
        )
      ],
    );
  }

  void _toggleZoom() {
    final zoomScript = _zoomed
        ? '''
        // hide tooltip
        chart.dispatchAction({
          type: 'hideTip'
        });

        chart.dispatchAction({
          type: 'dataZoom',
          start: 0,
          end: 100
        });
      '''
        : '''
        (function() {
          try {
            const data = chart.getOption().series[0].data;

            if (!data || data.length === 0) {
              console.error("No data available");
              return;
            }

            const lastIndex = data.length - 1;
            const lastData = data[lastIndex];
            const lastTimestamp = new Date(lastData[0]);

            // Extract the hour & minute
            const lastHour = lastTimestamp.getHours();
            const lastMinute = lastTimestamp.getMinutes();

            // Convert hour + fraction of hour (e.g., 10:30 AM -> 10.5)
            const lastTimeValue = lastHour + (lastMinute / 60);

            // Normalize between 0 (midnight) and 23 (end of day)
            const normalized = lastTimeValue / 24;

            // Calculate zoom center
            const zoomCenter = 15 + (normalized * (85 - 15));

            // Define zoom range ensuring the last point is centered
            const zoomOffset = 0.5;
            const zoomStart = Math.max(15, zoomCenter - zoomOffset);
            const zoomEnd = Math.min(85, zoomCenter + zoomOffset);

            console.log('Last Timestamp:', lastTimestamp);
            console.log('Last Hour:', lastHour);
            console.log('Last Minute:', lastMinute);
            console.log('Normalized Time:', normalized);
            console.log('Zoom Center:', zoomCenter);
            console.log('Final Zoom Range:', zoomStart, zoomEnd);

            // Apply zoom
            chart.dispatchAction({
              type: 'dataZoom',
              start: zoomStart,
              end: zoomEnd
            });

            // Wait for zoom animation to finish before showing tooltip
            setTimeout(() => {
              chart.dispatchAction({
                type: 'showTip',
                seriesIndex: 0,
                dataIndex: lastIndex
              });
              console.log('Tooltip triggered for index:', lastIndex);
            }, 500); // Adjust delay if needed

          } catch (e) {
            console.error("Zoom & Tooltip error:", e);
          }
        })();
      ''';

    _controller?.runJavaScript(zoomScript);
    setState(() {
      _zoomed = !_zoomed;
    });
  }
}
