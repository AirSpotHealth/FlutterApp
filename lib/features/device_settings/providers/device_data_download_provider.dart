import 'dart:io';

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_graph/providers/device_historical_data_provider.dart';
import 'package:airspothealth/features/device_graph/providers/graph_range_provider.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

final deviceDataDownloadProvider = NotifierProvider.family
    .autoDispose<_DeviceDataDownloadNotifier, AsyncProgressValue, String>(
        _DeviceDataDownloadNotifier.new);

class _DeviceDataDownloadNotifier
    extends AutoDisposeFamilyNotifier<AsyncProgressValue, String> {
  String get deviceId => arg;

  static final _dateFormat = DateFormat('yyyy-MM-dd-HH-mm-ss');

  bool share = false;

  @override
  AsyncProgressValue build(String arg) {
    return AsyncNone();
  }

  Future<void> setDataDownloadedFromDevice() async {
    debugPrint('setDataDownloadedFromDevice: $state');
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

      for (var element in deviceDatas) {
        debugPrint(
            'DeviceType: ${DeviceDataType.values[element.type].humanizedName}');
      }

      final device = ref.read(bleDeviceProvider(deviceId));
      final csvContent = _generateCsvContent(deviceDatas);
      final deviceName = device.alias == null || device.alias == 'Airspot'
          ? device.name
          : device.alias;
      final fileName = _generateFileName(deviceDatas, deviceName!);

      final deviceVersion = device.firmwareVersion;

      final csvHeader =
          "DEVICE NAME: $deviceName\nDEVICE VERSION: $deviceVersion\n\n";

      await _saveCsvFile(csvHeader + csvContent, fileName: fileName);

      debugPrint('Device data downloaded successfully');
      state = AsyncSuccess(true);
    } catch (e) {
      debugPrint('Failed to download device data: $e');
      state = AsyncFailure(e.toString());
    }
  }

  String _generateFileName(List<DeviceData> deviceDatas, String deviceName) {
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
        '${_dateFormat.format(firstDateTime)} - ${_dateFormat.format(lastDateTime)}';

    return '$deviceName-$dateRange';
  }

  Future<List<DeviceData>> _fetchDeviceData() async {
    final duration = ref.read(graphDurationProvider);
    final lower = duration.dateTimeRange.start;
    final upper = duration.dateTimeRange.end;

    final List<DeviceData> dataList = ref.read(isarServiceProvider).read(
      (isar) {
        return isar.deviceDatas
            .where()
            .deviceIdEqualTo(deviceId)
            .typeLessThan(DeviceDataType.empty.index)
            .isLiveCo2EqualTo(false)
            .dateTimeGreaterThanOrEqualTo(lower)
            .dateTimeLessThanOrEqualTo(upper)
            .sortByDateTime()
            .thenByTypeDesc()
            .findAll();
      },
    );

    // remove the data that has 0 value and is of type co2
    dataList.removeWhere((element) =>
        element.value == 0 && element.type == DeviceDataType.co2.index);

    return dataList;
  }

  String _generateCsvContent(List<DeviceData> deviceDatas) {
    final headerRow = 'DateTime,Value,Type\n';

    final csvRows = deviceDatas.map((data) {
      return '"${_dateFormat.format(data.dateTime)}","${data.parsedValue}","${DeviceDataType.values[data.type].humanizedName.toUpperCase()}"';
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

    if (share) {
      await Share.shareXFiles([XFile(file.path)],
          text: fileName, fileNameOverrides: [fileName]);
    } else {
      await FileSaver.instance.saveAs(
          name: fileName, bytes: bytes, mimeType: MimeType.csv, ext: 'csv');
    }
  }

  Future<void> downloadDeviceData(
      {bool share = false, bool last7Days = false}) async {
    this.share = share;
    GraphDataDuration duration = ref.read(graphDurationProvider);

    debugPrint('DOWNLOAD:Device data download provider: $duration');

    if (last7Days) {
      duration = GraphDataDuration.custom(
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)).startOfDay,
          end: DateTime.now(),
        ),
      );

      ref.read(graphDurationProvider.notifier).setDuration(duration);
      ref.read(deviceHistoricalDataProvider((deviceId, duration)));
    } else {
      state = AsyncInProgress(0.5, message: 'Downloading device data....');
      await Future.delayed(const Duration(seconds: 1));
      setDataDownloadedFromDevice();
    }
  }

  void setProgress(double progress) {
    state = AsyncInProgress(progress, message: 'Downloading device data....');
  }
}
