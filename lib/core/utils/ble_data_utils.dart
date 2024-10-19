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
    if (data.length < 6) return;

    final responseCommand = ResponseCommand.fromValue(data[2]);
    final parser = ResponseCommandParser(deviceId);

    debugPrint('ResponseCommand: $responseCommand');

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
    };

    final result = responseParsers[responseCommand]?.call(data);

    if (responseCommand == ResponseCommand.co2Value) {
      return result;
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
  int parseCo2Value(List<int> data) => data[4] * 256 + (data[5] & 0xff);

  bool parseAlarm(List<int> data) => _parseBoolean(data, 4);

  bool parseVibration(List<int> data) => _parseBoolean(data, 4);

  bool parseSetTimeResult(List<int> data) => _parseBoolean(data, 4);

  bool parseSetPowermodeResult(List<int> data) => _parseBoolean(data, 4);

  bool parseDisconnect(List<int> data) => _parseBoolean(data, 4);

  bool parseSetCo2Ppm(List<int> data) => _parseBoolean(data, 4);

  String parseFirmwareVersion(List<int> data) {
    final firmwareVersion = _parseString(data, 3);
    debugPrint('Firmware Version: $firmwareVersion');

    _updateDeviceSettings(
        (settings) => settings.copyWith(version: firmwareVersion));

    return firmwareVersion;
  }

  Map<String, dynamic> parseInitialData(List<int> data) {
    final settings = DeviceSettings(
      deviceId: deviceId,
      alarmEnabled: _parseBoolean(data, 4),
      vibrationEnabled: _parseBoolean(data, 5),
      powerMode: PowerMode.fromValue(data[6]),
      continuosScreenEnabled: _parseBoolean(data, 11),
      thresholds: DeviceThresholds(
        greenUpperLimit: _parseTwoBytesToInt(data, 7),
        yellowUpperLimit: _parseTwoBytesToInt(data, 9),
      ),
      version: '',
      co2AlertThreshold: null,
    );

    debugPrint('Initial Data: ${settings.toString()}');
    _updateDeviceSettings((_) => settings);

    return settings.toJson();
  }

  String parseAlias(List<int> data) {
    final alias = _parseString(data, 3);
    _updateDeviceSettings((settings) => settings.copyWith(version: alias));
    return alias;
  }

  bool parseSetAlias(List<int> data) => _parseBoolean(data, 4);

  String parseGetCo2History(List<int> data) {
    // Implement the logic if needed

    debugPrint('Get CO2 History: ${data.toString()}');

    return '';
  }

  bool parseCalibrateSensors(List<int> data) => _parseBoolean(data, 4);

  bool parseSetContinuosDisplay(List<int> data) => _parseBoolean(data, 4);

  // Helper Methods
  int _parseTwoBytesToInt(List<int> data, int startIndex) =>
      256 + (data[startIndex] & 0xff);

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
  calibrateSensors(0x0D),
  setContinuosDisplayResult(0x0E),
  firmwareVersion(0x13);

  const ResponseCommand(this.value);
  final int value;

  factory ResponseCommand.fromValue(int value) => ResponseCommand.values
      .firstWhere((e) => e.value == value, orElse: () => throw 'Invalid value');
}
