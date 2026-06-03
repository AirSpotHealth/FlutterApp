import 'dart:io';

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/features/device_graph/providers/device_historical_data_provider.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final csvDataImportProvider = NotifierProvider.family
    .autoDispose<CsvDataImportNotifier, AsyncProgressValue, String>(
        CsvDataImportNotifier.new);

class CsvDataImportNotifier
    extends AutoDisposeFamilyNotifier<AsyncProgressValue, String> {
  String get deviceId => arg;

  static final _dateFormat = DateFormat('yyyy-MM-dd-HH-mm-ss');

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
      final lines = csvContent.split('\n');

      state = AsyncInProgress(0.5, message: 'Parsing data...');

      // Skip header rows (first 2 lines contain device info, 3rd line is empty, 4th is CSV header)
      int headerRows = 0;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('DateTime,Value,Type')) {
          headerRows = i;
          break;
        }
      }

      if (headerRows == 0 && lines.length > 3) {
        headerRows = 3; // Default if header not found
      }

      final dataLines = lines.sublist(headerRows + 1);
      final List<DeviceData> deviceDatas = [];

      for (final line in dataLines) {
        if (line.trim().isEmpty) continue;

        // Parse CSV line
        final parts = _parseCSVLine(line);
        if (parts.length < 3) continue;

        final dateTimeStr = parts[0].replaceAll('"', '');
        final valueStr = parts[1].replaceAll('"', '');
        final typeStr = parts[2].replaceAll('"', '');

        try {
          // Parse datetime
          final dateTime = _dateFormat.parse(dateTimeStr);

          // Parse value as integer instead of double
          int value = int.parse(valueStr);

          // Find device data type
          DeviceDataType? dataType;
          for (var type in DeviceDataType.values) {
            if (type.humanizedName.toUpperCase() == typeStr) {
              dataType = type;
              break;
            }
          }

          if (dataType == null) continue;

          // Create device data with constructor
          final deviceData = DeviceData(
            deviceId: deviceId,
            dateTime: dateTime,
            value: value,
            type: dataType.index,
            isLiveCo2: false,
          );

          deviceDatas.add(deviceData);
        } catch (e) {
          debugPrint('Error parsing line: $line - $e');
          continue;
        }
      }

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

  // Helper to parse CSV line respecting quoted fields
  List<String> _parseCSVLine(String line) {
    final List<String> result = [];
    bool inQuotes = false;
    String currentValue = '';

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(currentValue);
        currentValue = '';
      } else {
        currentValue += char;
      }
    }

    // Don't forget to add the last value
    if (currentValue.isNotEmpty) {
      result.add(currentValue);
    }

    return result;
  }
}
