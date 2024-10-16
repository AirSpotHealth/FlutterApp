import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

class DeviceGraphPage extends ConsumerStatefulWidget {
  const DeviceGraphPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DeviceDataPageState();
}

class _DeviceDataPageState extends ConsumerState<DeviceGraphPage> {
  @override
  Widget build(BuildContext context) {
    final deviceDataList = ref
        .read(isarServiceProvider)
        .deviceDatas
        .where()
        .deviceIdEqualTo(widget.deviceId)
        .sortByDateTime()
        .watch(fireImmediately: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Data'),
      ),
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
    // uses fl charts to display the data
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: deviceDataList
                .map((data) => FlSpot(
                    data.dateTime.millisecondsSinceEpoch.toDouble(),
                    data.value.toDouble()))
                .toList(),
            isCurved: true,
            barWidth: 4,
            isStrokeCapRound: true,
            gradient: const LinearGradient(
              colors: [
                AppColors.brandColorRed,
                AppColors.brandColorAmber,
                AppColors.brandColorGreen
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(axisNameWidget: Text('Value')),
          bottomTitles: AxisTitles(axisNameWidget: Text('Time')),
        ),
        borderData: FlBorderData(show: true),
        gridData: const FlGridData(show: true),
      ),
    );
  }
}
