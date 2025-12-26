import 'dart:convert';
import 'dart:io';

import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/network_service.dart';
import 'package:airspothealth/core/services/supabase_service.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/features/report_issue/models/issue_report.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Service for submitting issue reports to the API
class IssueReportingService {
  IssueReportingService._();
  static final IssueReportingService instance = IssueReportingService._();

  /// Submit an issue report to the API
  Future<void> submitIssue(IssueReport report) async {
    try {
      final payload = report.toJson();

      // Add attachment as base64 if present
      if (report.attachmentPath != null) {
        final file = File(report.attachmentPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final base64Data = base64Encode(bytes);
          final extension =
              report.attachmentPath!.split('.').last.toLowerCase();
          final mimeType = _getMimeType(extension);

          payload['attachment_base64'] = 'data:$mimeType;base64,$base64Data';
          payload['attachment_filename'] = file.path.split('/').last;
        }
      }

      debugPrint('Submitting issue report: ${payload['issue_type']}');

      // Use API key from Constants
      final headers = <String, String>{};
      if (Constants.apiKey.isNotEmpty) {
        headers['x-api-key'] = Constants.apiKey;
      }

      final response = await NetworkService.instance.post(
        '/issues',
        payload,
        headers: headers.isNotEmpty ? headers : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Issue report submitted successfully');
      } else {
        throw Exception('Failed to submit issue: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Network error submitting issue: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Error submitting issue: $e');
      rethrow;
    }
  }

  /// Collect device and app metadata automatically
  Future<IssueReport> enrichWithMetadata(IssueReport report) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final supabase = SupabaseService();

    return report.copyWith(
      appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
      platform: Platform.isIOS ? 'ios' : 'android',
      deviceModel: await _getDeviceModel(),
      osVersion: Platform.operatingSystemVersion,
      userId: supabase.currentUser?.id,
      userEmail: supabase.currentUser?.email,
    );
  }

  Future<String> _getDeviceModel() async {
    // Simple device model detection
    if (Platform.isIOS) {
      return 'iOS Device';
    } else if (Platform.isAndroid) {
      return 'Android Device';
    }
    return 'Unknown';
  }

  /// Collect diagnostic data for a specific AirSpot device
  Map<String, dynamic> collectDeviceDiagnostics(String deviceId) {
    final diagnostics = <String, dynamic>{};
    final service = IsarService();

    try {
      final collection = service.deviceDatas;

      // Get last CO2 reading
      final lastCo2 = collection
          .where()
          .deviceIdEqualTo(deviceId)
          .typeEqualTo(DeviceDataType.co2.index)
          .sortByDateTimeDesc()
          .findFirst();

      if (lastCo2 != null) {
        diagnostics['last_co2_reading'] = lastCo2.value;
        diagnostics['last_co2_time'] = lastCo2.dateTime.toIso8601String();
      }

      // Get last sensor error (if any)
      final lastError = collection
          .where()
          .deviceIdEqualTo(deviceId)
          .typeEqualTo(DeviceDataType.sensorError.index)
          .sortByDateTimeDesc()
          .findFirst();

      if (lastError != null) {
        diagnostics['last_sensor_error_code'] = lastError.value;
        diagnostics['last_sensor_error'] = lastError.parsedValue;
        diagnostics['last_sensor_error_time'] =
            lastError.dateTime.toIso8601String();
      }

      // Get last battery low event
      final lastBatteryLow = collection
          .where()
          .deviceIdEqualTo(deviceId)
          .typeEqualTo(DeviceDataType.batteryLow.index)
          .sortByDateTimeDesc()
          .findFirst();

      if (lastBatteryLow != null) {
        diagnostics['last_battery_low_time'] =
            lastBatteryLow.dateTime.toIso8601String();
      }

      // Get last calibration event
      final lastCalib = collection
          .where()
          .deviceIdEqualTo(deviceId)
          .typeEqualTo(DeviceDataType.calibration.index)
          .sortByDateTimeDesc()
          .findFirst();

      if (lastCalib != null) {
        diagnostics['last_calibration_time'] =
            lastCalib.dateTime.toIso8601String();
      }

      // Get last device reset
      final lastReset = collection
          .where()
          .deviceIdEqualTo(deviceId)
          .typeEqualTo(DeviceDataType.reset.index)
          .sortByDateTimeDesc()
          .findFirst();

      if (lastReset != null) {
        diagnostics['last_reset_reason'] = lastReset.parsedValue;
        diagnostics['last_reset_time'] = lastReset.dateTime.toIso8601String();
      }

      // Get total reading count
      final totalReadings = collection
          .where()
          .deviceIdEqualTo(deviceId)
          .typeEqualTo(DeviceDataType.co2.index)
          .count();
      diagnostics['total_co2_readings'] = totalReadings;

      debugPrint(
          'Collected device diagnostics: ${diagnostics.length} data points');
    } catch (e) {
      debugPrint('Error collecting device diagnostics: $e');
    }

    return diagnostics;
  }
}

String _getMimeType(String extension) {
  switch (extension) {
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    case 'heic':
      return 'image/heic';
    default:
      return 'application/octet-stream';
  }
}
