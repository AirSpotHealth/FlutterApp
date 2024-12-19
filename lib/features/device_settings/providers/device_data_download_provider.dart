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

      final List<DeviceData> deviceDatas = ref.read(isarServiceProvider).read(
        (isar) {
          return isar.deviceDatas
              .where()
              .deviceIdEqualTo(deviceId)
              .sortByDateTimeDesc()
              .findAll();
        },
      );

      if (deviceDatas.isEmpty) {
        state = AsyncFailure('No data found for the device');
        return;
      }

      // convert the file to csv and make it available for download

      final headerRow = 'DateTime,Value,Type\n';

      final BleDevice device = ref.read(bleDeviceProvider(deviceId));
      final deviceName = device.alias ?? device.name;
      final dateRange =
          '${deviceDatas.first.dateTime.toIso8601String()} - ${deviceDatas.last.dateTime.toIso8601String()}';

      final csvData = deviceDatas.map((data) {
        return '${data.dateTime.toIso8601String().replaceAll("T", " ")},${data.value},${data.type.name.toUpperCase()}';
      }).join('\n');

      final directory = await getApplicationDocumentsDirectory();

      final File file = File('${directory.path}/$deviceName.csv');

      state = AsyncInProgress(0.8, message: 'Generating CSV file....');

      await file.writeAsString(headerRow);
      await file.writeAsString(csvData, mode: FileMode.append);

      final bytes = await file.readAsBytes();

      final String name = "${deviceName}_data_$dateRange.csv";

      state =
          AsyncInProgress(1.0, message: 'Device data ready for download....');

      await FileSaver.instance
          .saveAs(name: name, bytes: bytes, mimeType: MimeType.csv, ext: 'csv');

      debugPrint('Device data downloaded successfully');
      state = AsyncSuccess(true);
    } catch (e) {
      debugPrint('Failed to download device data: $e');
      state = AsyncFailure(e.toString());
    }
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
