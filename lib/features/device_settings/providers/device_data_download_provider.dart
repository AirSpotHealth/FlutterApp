import 'dart:io';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_graph/providers/device_historical_data_provider.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

final deviceDataDownloadProvider = NotifierProvider.family
    .autoDispose<_DeviceDataDownloadNotifier, AsyncProgressValue, String>(
        _DeviceDataDownloadNotifier.new);

class _DeviceDataDownloadNotifier
    extends AutoDisposeFamilyNotifier<AsyncProgressValue, String> {
  String get deviceId => arg;

  @override
  AsyncProgressValue build(String arg) {
    return AsyncNone();
  }

  Future<void> setDataDownloadedFromDevice() async {
    debugPrint('setDataDownloadedFromDevice');
    if (state is AsyncNone || state is AsyncSuccess) {
      return;
    }

    try {
      state = AsyncInProgress(0.5, message: 'Processing device data....');

      final List<DeviceData> deviceDatas = await _fetchDeviceData();
      if (deviceDatas.isEmpty) {
        state = AsyncFailure('No data found for the device');
        return;
      }

      final csvContent = _generateCsvContent(deviceDatas);
      final fileName = _generateFileName(deviceDatas);

      await _saveCsvFile(csvContent, fileName: fileName);

      debugPrint('Device data downloaded successfully');
      state = AsyncSuccess(true);
    } catch (e) {
      debugPrint('Failed to download device data: $e');
      state = AsyncFailure(e.toString());
    }
  }

  String _generateFileName(List<DeviceData> deviceDatas) {
    final BleDevice device = ref.read(bleDeviceProvider(deviceId));
    final deviceName = device.alias == null || device.alias == "AirSpot"
        ? device.name
        : device.alias;
    final dateRange =
        '${deviceDatas.first.dateTime.toIso8601String()} - ${deviceDatas.last.dateTime.toIso8601String()}';

    return '$deviceName-$dateRange';
  }

  Future<List<DeviceData>> _fetchDeviceData() async {
    return ref.read(isarServiceProvider).read(
      (isar) {
        return isar.deviceDatas
            .where()
            .deviceIdEqualTo(deviceId)
            .dateTimeGreaterThan(DateTime(2010))
            .sortByDateTime()
            .findAll();
      },
    );
  }

  String _generateCsvContent(List<DeviceData> deviceDatas) {
    final headerRow = 'DateTime,Value,Type\n';
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    final csvRows = deviceDatas.map((data) {
      return '"${dateFormat.format(data.dateTime)}","${data.value}","${data.type.name.toUpperCase()}"';
    }).join('\n');

    return headerRow + csvRows;
  }

  Future<void> _saveCsvFile(String csvContent,
      {required String fileName}) async {
    final directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$fileName.csv');

    state = AsyncInProgress(0.8, message: 'Generating CSV file....');

    await file.writeAsString(csvContent);

    final bytes = await file.readAsBytes();
    final String name = "$fileName.csv";

    state = AsyncInProgress(1.0, message: 'Device data ready for download....');

    await FileSaver.instance
        .saveAs(name: name, bytes: bytes, mimeType: MimeType.csv, ext: 'csv');
  }

  Future<void> downloadDeviceData() async {
    state = AsyncInProgress(0.0, message: 'Downloading device data....');

    ref.read(
        deviceHistoricalDataProvider((deviceId, GraphDataDuration.last7Days)));

    state = AsyncInProgress(0.1, message: 'Fetching device data....');
  }

  void setProgress(double progress) {
    state = AsyncInProgress(progress, message: 'Downloading device data....');
  }
}
