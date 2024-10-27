import 'dart:convert';

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DataGraphWidget extends StatefulWidget {
  const DataGraphWidget({super.key, required this.deviceDataList});

  final List<DeviceData> deviceDataList;

  @override
  State<DataGraphWidget> createState() => _DataGraphWidgetState();
}

class _DataGraphWidgetState extends State<DataGraphWidget> {
  late final WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadFlutterAsset(Assets.chartHtml)
    ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (url) => _buildGraph()))
    ..setBackgroundColor(Colors.white);

  @override
  void didUpdateWidget(DataGraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _buildGraph();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.height * 0.45,
      child: WebViewWidget(
        controller: controller,
      ),
    );
  }

  void _buildGraph() {
    final Iterable<DeviceData> data = widget.deviceDataList
        .where((data) => data.value != null && data.value is num)
        .map((data) =>
            data.copyWith(value: data.value < 400 ? 400 : data.value));

    // Prepare data for graph
    List<String> xAxisData = [];
    List<num> yAxisData = [];

    for (var deviceData in data) {
      xAxisData.add(_formatDate(deviceData.dateTime));
      yAxisData.add(deviceData.value);
    }

    // Constructing the JSON data for the chart
    var chartData = {
      "xAxis": {"data": xAxisData},
      "series": [
        {"name": "ppm", "type": "line", "data": yAxisData}
      ]
    };

    // Convert chartData to JSON string
    String optionJson = jsonEncode(chartData);

    // JavaScript to set the chart options
    String jsCode = "javascript:setOption($optionJson);";

    // Execute the JavaScript code
    controller.runJavaScript(jsCode);
  }

  String _formatDate(DateTime dateTime) {
    // Format the DateTime to a string representation (20.10.24 01:00)
    return '${dateTime.year.toString().substring(2)}.${dateTime.month}.${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:00';
  }
}
