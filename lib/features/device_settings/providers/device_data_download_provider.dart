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

  static final _dateFormat = DateFormat.yMMMMd().add_Hms();

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

    final DateTime firstDateTime = deviceDatas
        .firstWhere(
          (data) => data.dateTime.isAfter(DateTime(2020)),
          orElse: () => deviceDatas.first,
        )
        .dateTime;
    final DateTime lastDateTime = deviceDatas
        .lastWhere(
          (data) => data.dateTime.isAfter(DateTime(2020)),
          orElse: () => deviceDatas.last,
        )
        .dateTime;
    final dateRange =
        '${_dateFormat.format(firstDateTime).replaceAll("/", "-")} - ${_dateFormat.format(lastDateTime).replaceAll("/", "-")}';

    return '$deviceName-$dateRange';
  }

  Future<List<DeviceData>> _fetchDeviceData() async {
    final List<DeviceData> dataList = ref.read(isarServiceProvider).read(
      (isar) {
        return isar.deviceDatas
            .where()
            .deviceIdEqualTo(deviceId)
            .typeLessThan(DeviceDataType.empty)
            .sortByDateTime()
            .findAll();
      },
    );

    // remove the data that has 0 value and is of type co2
    dataList.removeWhere(
        (element) => element.value == 0 && element.type == DeviceDataType.co2);

    return dataList;
  }

  String _generateCsvContent(List<DeviceData> deviceDatas) {
    final headerRow = 'DateTime,Value,Type\n';

    final csvRows = deviceDatas.map((data) {
      return '"${_dateFormat.format(data.dateTime).replaceAll("/", "-")}","${data.parsedValue}","${data.type.humanizedName().toUpperCase()}"';
    }).join('\n');

    return headerRow + csvRows;
  }

  Future<void> _saveCsvFile(String csvContent,
      {required String fileName}) async {
    final directory = await getApplicationDocumentsDirectory();
    final File file =
        File('${directory.path}/$fileName${Platform.isIOS ? '.csv' : ''}');

    state = AsyncInProgress(0.8, message: 'Generating CSV file....');

    await file.writeAsString(csvContent);

    final bytes = await file.readAsBytes();

    state = AsyncInProgress(1.0, message: 'Device data ready for download....');

    // await Share.shareXFiles([XFile(file.path)],
    //     text: fileName, fileNameOverrides: [fileName]);

    await FileSaver.instance.saveAs(
        name: fileName, bytes: bytes, mimeType: MimeType.csv, ext: 'csv');
  }

  Future<void> downloadDeviceData() async {
    state = AsyncInProgress(0.0, message: 'Downloading device data....');

    ref.read(
        deviceHistoricalDataProvider((deviceId, GraphDataDuration.last7Days)));

    state = AsyncInProgress(0.1, message: 'Fetching device data....');

    // set a timeout if incase there was an issue with fetching the data
    Future.delayed(const Duration(minutes: 4), () {
      if (state is AsyncInProgress) {
        state = AsyncFailure('Failed to fetch device data: Timeout');
      }
    });
  }

  void setProgress(double progress) {
    state = AsyncInProgress(progress, message: 'Downloading device data....');
  }
}
