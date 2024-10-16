import 'dart:convert';

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/airspot_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DeviceGraphPage extends ConsumerWidget {
  const DeviceGraphPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceDataList = ref
        .read(isarServiceProvider)
        .deviceDatas
        .where()
        .deviceIdEqualTo(deviceId)
        .sortByDateTime()
        .watch(fireImmediately: true);

    return Scaffold(
      appBar: const AirspotBar(),
      body: StreamBuilder<List<DeviceData>>(
        stream: deviceDataList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          }

          return _buildDeviceDataChart(
              snapshot.data!.where((data) => data.value != null).toList());
        },
      ),
    );
  }

  Widget _buildDeviceDataChart(List<DeviceData> deviceDataList) {
    return _AirGraph(deviceDataList: deviceDataList);
  }
}

class _AirGraph extends StatefulWidget {
  const _AirGraph({required this.deviceDataList});

  final List<DeviceData> deviceDataList;

  @override
  _AirGraphState createState() => _AirGraphState();
}

class _AirGraphState extends State<_AirGraph> {
  late final WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..enableZoom(true)
    ..loadFlutterAsset('assets/html/echarts.html')
    ..setNavigationDelegate(NavigationDelegate(
      onPageFinished: (url) {
        _buildGraph(widget.deviceDataList);
      },
    ));

  @override
  didUpdateWidget(_AirGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    _buildGraph(widget.deviceDataList);
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

  void _buildGraph(List<DeviceData> data) {
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
    // Format the DateTime to a string representation (dd-MM-yyyy)
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  }
}
