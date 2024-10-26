import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

/// BLE data utils class to handle BLE data operations
/// This class provides methods to handle BLE data operations.
class BleDataUtils {
  /// Converts bytes to hex string
  static String? bytesToHexStr(List<int>? bytes) =>
      bytes?.map((byt) => byt.toRadixString(16).padLeft(2, '0')).join();

  /// Parses the response command based on device ID and data
  static dynamic parseResponseCommand(String deviceId, List<int> data) {
    if (data.length < 6) return null;

    final responseCommand = ResponseCommand.fromValue(data[2]);
    final parser = ResponseCommandParser(deviceId);

    final responseParsers = {
      ResponseCommand.co2Value: parser.parseCo2Value,
      ResponseCommand.setAlarmResult: parser.parseAlarm,
      ResponseCommand.setVibrationResult: parser.parseVibration,
      ResponseCommand.setTimeResult: parser.parseSetTimeResult,
      ResponseCommand.setPowerMode: parser.parseSetPowermodeResult,
      ResponseCommand.disconnectResult: parser.parseDisconnect,
      ResponseCommand.setCoo2Ppm: parser.parseSetCo2Ppm,
      ResponseCommand.initialData: parser.parseInitialData,
      ResponseCommand.alias: parser.parseAlias,
      ResponseCommand.setAliasResult: parser.parseSetAlias,
      ResponseCommand.getCo2History: parser.parseGetCo2History,
      ResponseCommand.calibrateSensors: parser.parseCalibrateSensors,
      ResponseCommand.setContinuosDisplayResult:
          parser.parseSetContinuosDisplay,
      ResponseCommand.firmwareVersion: parser.parseFirmwareVersion,
      ResponseCommand.recalibrationTime: parser.parseRecalibrationTime,
      ResponseCommand.recalibrationConfirm: parser.parseRecalibrationTime,
    };

    final result = responseParsers[responseCommand]?.call(data);

    if (responseCommand == ResponseCommand.co2Value) {
      return result as int;
    }

    if (responseCommand == ResponseCommand.recalibrationTime) {
      return result as int;
    }

    if (responseCommand == ResponseCommand.recalibrationConfirm) {
      return result as int;
    }

    if (responseCommand == ResponseCommand.firmwareVersion) {
      return result as String;
    }

    return null;
  }
}

/// Response command parser class
/// Provides methods to parse response commands
class ResponseCommandParser {
  ResponseCommandParser(this.deviceId);

  final String deviceId;
  final IsarService isarService = IsarService();
  int parseCo2Value(List<int> data) => (data[4] * 256 + (data[5] & 0xff));

  bool parseAlarm(List<int> data) => _parseBoolean(data, 4);

  bool parseVibration(List<int> data) => _parseBoolean(data, 4);

  bool parseSetTimeResult(List<int> data) => _parseBoolean(data, 4);

  bool parseSetPowermodeResult(List<int> data) => _parseBoolean(data, 4);

  bool parseDisconnect(List<int> data) => _parseBoolean(data, 4);

  bool parseSetCo2Ppm(List<int> data) => _parseBoolean(data, 4);

  String parseFirmwareVersion(List<int> data) {
    final firmwareVersion = _parseString(data, 3);
    debugPrint('Firmware Version: $firmwareVersion');

    isarService.write((isar) {
      final device =
          isar.bleDevices.where().deviceIdEqualTo(deviceId).findFirst();
      if (device == null) {
        return;
      }

      debugPrint('Got version $firmwareVersion for device: ${device.name}');
      isar.bleDevices.put(device.copyWith(firmwareVersion: firmwareVersion));
    });

    return firmwareVersion;
  }

  void parseInitialData(List<int> data) {
    debugPrint('Initial Data: ${data.toString()}');
    _updateDeviceSettings(
      (settings) {
        debugPrint('AutoConnect: ${settings.autoConnect}');
        return settings.copyWith(
          deviceId: deviceId,
          alarmEnabled: _parseBoolean(data, 4),
          vibrationEnabled: _parseBoolean(data, 5),
          powerMode: PowerMode.fromValue(data[6]),
          continuosScreenEnabled: _parseBoolean(data, 11),
          thresholds: DeviceThresholds(
            greenUpperLimit: _parseTwoBytesToInt(data, 7),
            yellowUpperLimit: _parseTwoBytesToInt(data, 9),
          ),
        );
      },
    );
  }

  String parseAlias(List<int> data) {
    final alias = _parseString(data, 3);
    isarService.write((isar) {
      final settings =
          isar.bleDevices.where().deviceIdEqualTo(deviceId).findFirst();

      if (settings == null) {
        return;
      }

      isar.bleDevices.put(settings.copyWith(alias: alias));
    });

    return alias;
  }

  bool parseSetAlias(List<int> data) => _parseBoolean(data, 4);

  /// Parses CO2 history data
  List<Map<String, dynamic>> parseGetCo2History(List<int> data) {
    List<Map<String, dynamic>> co2Data = [];

    // Check if the data length is at least 6 bytes (minimum valid length)
    if (data.length < 6) return co2Data;

    // Extract the initial timestamp (first 4 bytes)
    int baseTimestamp = _byteArrayToInt(data, 0, 3);

    // Calculate the timestamp from 2000-01-01 00:00:00 UTC
    DateTime timestampFrom2000 =
        DateTime.utc(2000, 1, 1, 0, 0, 0).add(Duration(seconds: baseTimestamp));

    // Manually adjust the timestamp to align with the current date
    timestampFrom2000 =
        timestampFrom2000.subtract(const Duration(days: (365 * 111) + 66));

    // Extract the sampling rate (5th byte)
    int samplingRate = data[4];
    String mode = _getSamplingMode(samplingRate);

    // If the sampling rate is unrecognized, default to "HI power mode"
    if (mode == 'Unknown mode') {
      samplingRate = 0x02; // Default to HI power mode
      mode = 'HI power mode';
    }

    // Extract the CO2 samples (from 6th byte onward)
    for (int i = 5; i < data.length - 1; i += 2) {
      int highByte = data[i];
      int lowByte = data[i + 1];
      int ppmValue = (highByte << 8) | lowByte;

      // Add the parsed CO2 sample to the list
      co2Data.add({
        'timestamp': timestampFrom2000,
        'samplingRate': mode,
        'ppmValue': ppmValue,
      });

      // Update the timestamp based on the sampling rate
      timestampFrom2000 = timestampFrom2000
          .add(Duration(seconds: _getIntervalInSeconds(samplingRate)));
    }

    final List<DeviceData> dd = co2Data.map((e) {
      return DeviceData(
        deviceId: deviceId,
        dateTime: e['timestamp'],
        value: e['ppmValue'],
      );
    }).toList();

    isarService.write((isar) {
      isar.deviceDatas.putAll(dd);
    });

    return co2Data;
  }

  /// Helper method to convert sampling rate to mode description
  String _getSamplingMode(int samplingRate) {
    switch (samplingRate) {
      case 0x00:
        return 'LOW power mode';
      case 0x01:
        return 'MED power mode';
      case 0x02:
        return 'HI power mode';
      default:
        return 'Unknown mode';
    }
  }

  /// Helper method to get the interval in seconds based on sampling rate
  int _getIntervalInSeconds(int samplingRate) {
    switch (samplingRate) {
      case 0x00:
        return 180; // 3 minutes for LOW power mode
      case 0x01:
        return 60; // 1 minute for MED power mode
      case 0x02:
        return 5; // 5 seconds for HI power mode
      default:
        return 5; // Default to HI power mode interval
    }
  }

  bool parseCalibrateSensors(List<int> data) => _parseBoolean(data, 4);

  bool parseSetContinuosDisplay(List<int> data) => _parseBoolean(data, 4);

  int parseRecalibrationTime(List<int> data) => data[4];

  // Helper Methods
  int _parseTwoBytesToInt(List<int> data, int startIndex) =>
      _byteArrayToInt(data, startIndex, startIndex + 1);

  bool _parseBoolean(List<int> data, int index) => data[index] == 0x01;

  String _parseString(List<int> data, int sizeIndex) {
    final size = data[sizeIndex];
    final contentArray = data.sublist(4, size + 4);
    return String.fromCharCodes(contentArray);
  }

  void _updateDeviceSettings(DeviceSettings Function(DeviceSettings) update) {
    isarService.write((isar) {
      final settings =
          isar.deviceSettings.where().deviceIdEqualTo(deviceId).findFirst();
      isar.deviceSettings
          .put(update(settings ?? DeviceSettings.empty(deviceId: deviceId)));
    });
  }

  int _byteArrayToInt(List<int> data, int startIndex, int endIndex) {
    dynamic result = 0;
    for (var i = startIndex; i <= endIndex; i++) {
      result = result << 8;
      result = result | (data[i] & 0xFF);
    }
    return result.toInt();
  }
}

/// Enum representing various response commands with their corresponding integer values.
///
/// Each command is associated with a specific integer value that can be used to identify
/// the command in a BLE (Bluetooth Low Energy) communication context.
///
/// - `co2Value`: Command for CO2 value (0x01).
/// - `setAlarmResult`: Command for setting alarm result (0x02).
/// - `setVibrationResult`: Command for setting vibration result (0x03).
/// - `setTimeResult`: Command for setting time result (0x04).
/// - `setPowerMode`: Command for setting power mode (0x05).
/// - `disconnectResult`: Command for disconnect result (0x06).
/// - `setCoo2Ppm`: Command for setting CO2 PPM (0x07).
/// - `initialData`: Command for initial data (0x08).
/// - `alias`: Command for alias (0x09).
/// - `setAliasResult`: Command for setting alias result (0x0A).
/// - `getCo2History`: Command for getting CO2 history (0x0C).
/// - `calibrateSensors`: Command for calibrating sensors (0x0D).
/// - `setContinuosDisplayResult`: Command for setting continuous display result (0x0E).
/// - `firmwareVersion`: Command for firmware version (0x13).
///
/// The `fromValue` factory constructor allows creating an instance of `ResponseCommand`
/// from an integer value. If the value does not correspond to any command, an exception
/// is thrown.

enum ResponseCommand {
  co2Value(0x01),
  setAlarmResult(0x02),
  setVibrationResult(0x03),
  setTimeResult(0x04),
  setPowerMode(0x05),
  disconnectResult(0x06),
  setCoo2Ppm(0x07),
  initialData(0x08),
  alias(0x09),
  setAliasResult(0x0A),
  getCo2History(0x0C),
  calibrateSensors(0x11),
  setContinuosDisplayResult(0x0E),
  firmwareVersion(0x13),
  recalibrationTime(0x0F),
  recalibrationConfirm(0x0D);

  const ResponseCommand(this.value);
  final int value;

  factory ResponseCommand.fromValue(int value) => ResponseCommand.values
      .firstWhere((e) => e.value == value, orElse: () => throw 'Invalid value');
}
