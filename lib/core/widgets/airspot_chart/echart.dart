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
    this.onMapHandoff,
  });

  final String option;
  final void Function(int tsMs, int co2)? onMapHandoff;

  @override
  State<EChart> createState() => _EChartState();
}

class _EChartState extends State<EChart> {
  WebViewController? _controller;

  String get _currentOption => widget.option;

  bool _zoomed = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController();
    _configure();
  }

  Future<void> _configure() async {
    try {
      await _controller!.setBackgroundColor(const Color(0x00000000));
      await _controller!.setJavaScriptMode(JavaScriptMode.unrestricted);
      await _controller!.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            try {
              final urlStr = request.url;
              debugPrint('Navigation request: $urlStr');
              if (urlStr.startsWith('airspothealth://')) {
                final uri = Uri.parse(urlStr);
                if (uri.host == 'chart-map-handoff') {
                  final tsParam = uri.queryParameters['ts'];
                  final co2Param = uri.queryParameters['co2'];
                  if (tsParam != null && co2Param != null) {
                    final ts = int.tryParse(tsParam);
                    final co2 = int.tryParse(co2Param);
                    if (ts != null && co2 != null) {
                      widget.onMapHandoff?.call(ts, co2);
                    }
                  }
                  return NavigationDecision.prevent;
                }
              }
            } catch (e) {
              debugPrint('Navigation intercept error: $e');
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) => _ready = false,
          onPageFinished: (url) => init(),
          onWebResourceError: (e) {
            debugPrint('Chart error: ${e.description}');
          },
        ),
      );
      await _controller!.addJavaScriptChannel('Print',
          onMessageReceived: (JavaScriptMessage javascriptMessage) {
        debugPrint('Chart message: ${javascriptMessage.message}');
      });
      await _controller!.addJavaScriptChannel('GraphBridge',
          onMessageReceived: (JavaScriptMessage message) {
        try {
          final data = jsonDecode(message.message) as Map<String, dynamic>;
          if (data['type'] == 'mapHandoff') {
            final ts = (data['ts'] as num).toInt();
            final co2 = (data['co2'] as num).toInt();
            widget.onMapHandoff?.call(ts, co2);
          }
        } catch (e) {
          debugPrint('GraphBridge parse error: $e');
        }
      });
      if (mounted) {
        await _controller!.loadHtmlString(utf8.fuse(base64).decode(htmlBase64));
      }
    } catch (error) {
      debugPrint('Chart setup failed: $error');
    }
  }

  Future<void> init() async {
    if (!mounted) return;
    _ready = false;
    final initialOption = _currentOption;
    try {
      await _controller!.runJavaScript('''
      $script;
      var chart = echarts.init(document.getElementById('chart'));
      chart.setOption($initialOption, true);
      // Global tooltip auto-hide logic

      // Global tooltip debounce logic
      (function() {

        let tooltipTimeout = null;

        // Ensure tooltip CSS accepts clicks
        try {
          var style = document.createElement('style');
          style.type = 'text/css';
          style.appendChild(document.createTextNode('.echarts-tooltip { pointer-events: auto !important; }'));
          document.head.appendChild(style);
        } catch (_) {}

        chart.on("showTip", function (params) {

          // If there is an active timeout, clear it
          if (tooltipTimeout) {
            clearTimeout(tooltipTimeout);
          }

          // Start a new timeout (always ensure tooltip hides)
          tooltipTimeout = setTimeout(() => {
            var tooltip = document.querySelector('.echarts-tooltip');
            var isHovering = false;
            if (tooltip) {
              var rect = tooltip.getBoundingClientRect();
              var x = window._lastMouseX || -1;
              var y = window._lastMouseY || -1;
              isHovering = x >= rect.left && x <= rect.right && y >= rect.top && y <= rect.bottom;
            }
            if (!isHovering) {
              chart.dispatchAction({ type: 'hideTip' });
              chart.dispatchAction({
                type: 'updateAxisPointer',
                currTrigger: 'leave',
                dataIndex: -1
              });
              tooltipTimeout = null; // Reset timeout
            }
          }, 5000);
          // Hook map handoff button click
          try {
            var idx = (params && params.dataIndex != null) ? params.dataIndex : null;
            if (idx == null && params && params.batch && params.batch.length) {
              idx = params.batch[0].dataIndex;
            }
            var series = chart.getOption().series;
            if (idx != null && series && series.length) {
              var pt = series[0].data[idx];
              var tsIso = pt && pt.length ? pt[0] : null;
              var co2Val = pt && pt.length ? pt[1] : null;
              var tsMs = tsIso ? (new Date(tsIso)).getTime() : null;
              // Store latest point globally for delegated handlers
              if (tsMs && (co2Val !== null && co2Val !== undefined)) {
                window._latestPoint = { ts: tsMs, co2: co2Val };
              }
              setTimeout(function() {
                var btn = document.getElementById('map-handoff-btn');
                if (btn && tsMs && (co2Val !== null && co2Val !== undefined)) {
                  btn.style.pointerEvents = 'auto';
                  btn.addEventListener('mouseenter', function(){ window._hoveringTooltip = true; });
                  btn.addEventListener('mouseleave', function(){ window._hoveringTooltip = false; });
                  btn.onclick = function(ev) {
                    ev.preventDefault(); ev.stopPropagation();
                    if (typeof GraphBridge !== 'undefined' && GraphBridge.postMessage) {
                      GraphBridge.postMessage(JSON.stringify({ type: 'mapHandoff', ts: tsMs, co2: co2Val }));
                    }
                  };
                  // Touch fallback
                  btn.addEventListener('touchend', function(ev){
                    ev.preventDefault(); ev.stopPropagation();
                    if (typeof GraphBridge !== 'undefined' && GraphBridge.postMessage) {
                      GraphBridge.postMessage(JSON.stringify({ type: 'mapHandoff', ts: tsMs, co2: co2Val }));
                    }
                  }, { passive: false });
                }
                // Ensure tooltip wrapper accepts events
                var tooltipEl = document.querySelector('.echarts-tooltip');
                if (tooltipEl) { tooltipEl.style.pointerEvents = 'auto'; tooltipEl.style.zIndex = '9999'; }
              }, 0);
            }
          } catch (e) {
            if (typeof Print !== 'undefined' && Print.postMessage) { Print.postMessage('map btn error: ' + e); }
          }
        });

        // Track last mouse position to detect hovering over tooltip
        document.addEventListener('mousemove', function(ev){
          window._lastMouseX = ev.clientX; window._lastMouseY = ev.clientY;
        });

        // Delegate click/touch on tooltip icon to ensure reliability on mobile
        if (!window._mapHandoffBound) {
          window._mapHandoffBound = true;
          var handler = function(ev) {
            var target = ev.target;
            if (!target) return;
            var btn = (target.id === 'map-handoff-btn') ? target : (target.closest ? target.closest('#map-handoff-btn') : null);
            if (btn) {
              ev.preventDefault(); ev.stopPropagation();
              try {
                var tsAttr = btn.getAttribute('data-ts');
                var co2Attr = btn.getAttribute('data-co2');
                var tsVal = tsAttr ? parseInt(tsAttr, 10) : (window._latestPoint ? window._latestPoint.ts : null);
                var co2Val = co2Attr ? parseInt(co2Attr, 10) : (window._latestPoint ? window._latestPoint.co2 : null);
                if (typeof GraphBridge !== 'undefined' && GraphBridge.postMessage) {
                  GraphBridge.postMessage(JSON.stringify({ type: 'mapHandoff', ts: tsVal, co2: co2Val }));
                }
              } catch (e) {}
            }
          };
          document.addEventListener('click', handler, true);
          document.addEventListener('touchend', handler, { passive: false, capture: true });
        }

      })();
    ''');
      if (!mounted) return;
      _ready = true;
      debugPrint('Chart initialized.');
      update(initialOption);
    } catch (error) {
      debugPrint('Chart initialization failed: $error');
    }
  }

  Future<void> _runChartScript(String source) async {
    if (!mounted || !_ready) return;
    try {
      await _controller!.runJavaScript(source);
    } catch (error) {
      debugPrint('Chart operation failed: $error');
    }
  }

  void update(String preOption) {
    if (_currentOption != preOption) {
      _runChartScript('''
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
        ),
        // another set to now icon that keeps the zoom but moves the chart to the latest data
        Positioned(
          right: 8,
          top: 80,
          child: IconButton(
            onPressed: _moveToLatestData,
            icon: Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  void _moveToLatestData() {
    _runChartScript('''
      (function() {
        try {
          const data = chart.getOption().series[0].data;
          
          if (!data || data.length === 0) {
            console.error("No data available");
            return;
          }

          // get the zoom range
          const zoom = chart.getOption().dataZoom[0];
          if (!zoom) {
            console.error("No zoom data available");
            return;
          }

          const lastIndex = data.length - 1;
          const lastData = data[lastIndex];
          const lastTimestamp = new Date(lastData[0]);
          
          // Get the current visible data range
          const currentStartValue = zoom.startValue;
          const currentEndValue = zoom.endValue;
          
          // If we don't have startValue/endValue, calculate them from percentages
          let zoomSizeMs;
          if (currentStartValue && currentEndValue) {
            // We already have time-based zoom, just calculate the window size
            zoomSizeMs = new Date(currentEndValue) - new Date(currentStartValue);
          } else {
            // We have percentage-based zoom, convert to time
            const firstTimestamp = new Date(data[0][0]);
            const totalTimeRange = lastTimestamp - firstTimestamp;
            const zoomSizePercent = zoom.end - zoom.start;
            zoomSizeMs = totalTimeRange * (zoomSizePercent / 100);
          }
          
          console.log('Current zoom window size (ms):', zoomSizeMs);
          
          // Calculate the end time (latest data point)
          const endValue = lastData[0]; // ISO string of the last timestamp
          
          // Calculate the start time based on the current zoom window size
          const startDate = new Date(lastTimestamp - zoomSizeMs);
          const startValue = startDate.toISOString();
          
          console.log('New zoom start value:', startValue);
          console.log('New zoom end value:', endValue);
          
          // Apply zoom using startValue and endValue
          chart.dispatchAction({
            type: 'dataZoom',
            startValue: startValue,
            endValue: endValue
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
          console.error("Error moving to latest data:", e);
        }
      })();
    ''');
  }

  void _toggleZoom() {
    if (!_ready) return;
    final zoomScript = _zoomed
        ? '''
        (function() {
        // hide tooltip
        chart.dispatchAction({
          type: 'hideTip'
        });

        chart.dispatchAction({
          type: 'dataZoom',
          start: 0,
          end: 100
        });
        
      })();
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
            const firstTimestamp = new Date(data[0][0]);

            // Calculate total hours between first and last data point
            const totalHours = (lastTimestamp - firstTimestamp) / (1000 * 60 * 60);
            
            // Calculate number of days
            const numberOfDays = Math.ceil(totalHours / 24);
            
            console.log('Total hours:', totalHours);
            console.log('Number of days:', numberOfDays);

            // Define zoom window size based on data span
            // For single day, use 6 hours window
            // For multi-day, use 12 hours window to focus more on recent data
            const zoomWindowMs = numberOfDays > 1 
              ? 12 * 60 * 60 * 1000  // 12 hours in milliseconds
              : 6 * 60 * 60 * 1000;  // 6 hours in milliseconds
            
            // Calculate the end time (latest data point)
            const endValue = lastData[0]; // ISO string of the last timestamp
            
            // Calculate the start time based on the zoom window size
            const startDate = new Date(lastTimestamp - zoomWindowMs);
            const startValue = startDate.toISOString();
            
            console.log('Zoom window size (ms):', zoomWindowMs);
            console.log('Zoom start value:', startValue);
            console.log('Zoom end value:', endValue);

            // Apply zoom using startValue and endValue
            chart.dispatchAction({
              type: 'dataZoom',
              startValue: startValue,
              endValue: endValue
            });

            // Wait for zoom animation to finish before showing tooltip
            setTimeout(() => {
              chart.dispatchAction({
                type: 'showTip',
                seriesIndex: 0,
                dataIndex: lastIndex
              });
            }, 500); // Adjust delay if needed

          } catch (e) {
            console.error("Zoom & Tooltip error:", e);
          }
        })();
      ''';

    _runChartScript(zoomScript);
    setState(() {
      _zoomed = !_zoomed;
    });
  }
}
