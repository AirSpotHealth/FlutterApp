import 'dart:convert';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/app_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/features/device_graph/providers/device_provider.dart';
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

    final BleDevice device = ref.read(bleDeviceProvider(deviceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Graph'),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            color: AppColors.primaryColor,
            alignment: Alignment.center,
            child: const AppLogo(
              width: 100,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: Text(
              device.name,
              style: context.textTheme.bodyMedium?.weight600,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Carbon dioxide',
                style: context.textTheme.labelLarge?.weight600),
          ),
          DeviceCurrentValueWidget(deviceId: device.deviceId),
          const SizedBox(height: 16),

          // StreamBuilder<List<DeviceData>>(
          //   stream: deviceDataList,
          //   builder: (context, snapshot) {
          //     if (!snapshot.hasData) {
          //       return const Center(
          //           child: CircularProgressIndicator.adaptive());
          //     }

          //     if (snapshot.data!.isEmpty) {
          //       return const Center(child: Text('No data found'));
          //     }

          //     return _buildDeviceDataChart(
          //         snapshot.data!.where((data) => data.value != null).toList());
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildDeviceDataChart(List<DeviceData> deviceDataList) {
    return _AirGraph(deviceDataList: deviceDataList);
  }
}

class DeviceCurrentValueWidget extends ConsumerWidget {
  const DeviceCurrentValueWidget({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceValue = ref.watch(bleDeviceCommunicationProvider(deviceId));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Text(
              'Current:',
              style: context.textTheme.bodyMedium?.weight500,
            ),
            const Spacer(),
            RichText(
              text: TextSpan(
                text: deviceValue != null ? "$deviceValue" : '------',
                style: context.textTheme.titleLarge?.copyWith(
                  color: AppUtils.getDataColorFromValue(deviceValue),
                  fontWeight: FontWeight.bold,
                ),
                children: const [
                  TextSpan(
                    text: ' ppm',
                    style: TextStyle(
                      color: AppColors.neutralGrey,
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    ..loadFlutterAsset('assets/html/echarts.html')
    ..setNavigationDelegate(NavigationDelegate(
      onPageFinished: (url) => _buildGraph(),
    ));

  @override
  void didUpdateWidget(_AirGraph oldWidget) {
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
    final List<DeviceData> data = widget.deviceDataList
      ..where((data) => data.value != null && data.value is num);

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
