import 'dart:io';

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
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

  Future<void> downloadDeviceData() async {
    try {
      state = AsyncInProgress(0.0, message: 'Downloading device data....');

      final List<DeviceData> deviceDatas = ref.read(isarServiceProvider).read(
        (isar) {
          return isar.deviceDatas.where().deviceIdEqualTo(deviceId).findAll();
        },
      );

      if (deviceDatas.isEmpty) {
        state = AsyncFailure('No data found for the device');
        return;
      }

      // convert the file to csv and make it available for download

      final csvData = deviceDatas.map((data) {
        return '${data.dateTime.toIso8601String()},${data.value},${data.type.name}';
      }).join('\n');

      final directory = await getApplicationDocumentsDirectory();

      final File file =
          await File('${directory.path}/device_data_$deviceId.csv')
              .writeAsString(csvData)
            ..readAsBytes();

      final bytes = await file.readAsBytes();

      final String name = 'device_data_$deviceId.csv';

      await FileSaver.instance
          .saveAs(name: name, bytes: bytes, mimeType: MimeType.csv, ext: 'csv');

      debugPrint('Device data downloaded successfully');
      state = AsyncSuccess(true);
    } catch (e) {
      debugPrint('Failed to download device data: $e');
      state = AsyncFailure(e.toString());
    }
  }

  void setProgress(double progress) {
    state = AsyncInProgress(progress, message: 'Downloading device data....');
  }
}
