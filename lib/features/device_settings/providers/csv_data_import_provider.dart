import 'dart:io';

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/features/device_settings/service/reading_csv.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/features/device_graph/providers/device_historical_data_provider.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final csvDataImportProvider = NotifierProvider.family
    .autoDispose<CsvDataImportNotifier, AsyncProgressValue, String>(
        CsvDataImportNotifier.new);

class CsvDataImportNotifier
    extends AutoDisposeFamilyNotifier<AsyncProgressValue, String> {
  String get deviceId => arg;

  @override
  AsyncProgressValue build(String arg) {
    return AsyncNone();
  }

  Future<void> importCsvData() async {
    try {
      state = AsyncInProgress(0.1, message: 'Selecting CSV file...');

      // Pick a CSV file
      final result = await FilePicker.pickFiles(
          // type: FileType.custom,
          // allowedExtensions: ['csv'],
          );

      if (result == null || result.files.isEmpty) {
        state = AsyncNone();
        return;
      }

      state = AsyncInProgress(0.3, message: 'Reading CSV file...');

      // Read file content
      final file = File(result.files.first.path!);
      final csvContent = await file.readAsString();
      state = AsyncInProgress(0.5, message: 'Parsing data...');
      final List<DeviceData> deviceDatas =
          parseReadingCsv(csvContent, deviceId);

      if (deviceDatas.isEmpty) {
        state = AsyncFailure('No valid data found in the CSV file');
        return;
      }

      state = AsyncInProgress(0.8, message: 'Saving data to database...');

      // Save to database
      ref.read(isarServiceProvider).write((isar) {
        isar.deviceDatas.putAll(deviceDatas);
      });

      // Invalidate any related providers
      ref.invalidate(deviceHistoricalDataProvider);

      state = AsyncSuccess(true);
      debugPrint('Imported ${deviceDatas.length} records successfully');
    } catch (e) {
      debugPrint('Failed to import CSV data: $e');
      state = AsyncFailure(e.toString());
    }
  }
}
