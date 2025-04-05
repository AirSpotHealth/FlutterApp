import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DataLoggerService {
  // Method to log data to a text file
  Future<void> logData({
    required String deviceId,
    required dynamic value,
    required DateTime dateTime,
    required bool sent,
    bool st = false,
  }) async {
    try {
      // Get the local directory for storing files
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/data_log_$deviceId.txt';
      final file = File(filePath);

      // Prepare the data entry with an additional boolean flag 'st'
      String entry =
          '${dateTime.toIso8601String()},$value,${sent ? 'sent' : 'received'}${sent ? (st ? 'Success' : 'Failed') : ""}\n';

      // Append the data entry to the file
      await file.writeAsString(entry, mode: FileMode.append, flush: true);
    } catch (e) {
      debugPrint('Error logging data: $e');
    }
  }

  // Method to get the file path for downloading
  Future<File> getLogFile(String deviceId) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data_log_$deviceId.txt');
  }

  // Method to read log data
  Future<String> readLogData(String deviceId) async {
    try {
      final file = await getLogFile(deviceId);
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return 'No log data available.';
      }
    } catch (e) {
      return 'Error reading log data.';
    }
  }

  // Method to clear log data
  Future<void> clearLogData(String deviceId) async {
    try {
      final file = await getLogFile(deviceId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error clearing log data: $e');
    }
  }

  /// Download the log file to user's device
  Future<void> downloadLogData(String deviceId) async {
    try {
      debugPrint('Downloading log data for device: $deviceId');
      final file = await getLogFile(deviceId);

      // get the bytes of the file
      final bytes = await file.readAsBytes();

      // save the file
      final name = 'data_log_$deviceId.txt';

      await FileSaver.instance.saveAs(
          name: name, bytes: bytes, mimeType: MimeType.text, ext: 'txt');
    } catch (e) {
      debugPrint('Error downloading log data: $e');
    }
  }
}
