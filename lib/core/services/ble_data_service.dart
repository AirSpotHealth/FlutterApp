import 'dart:typed_data';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/widget_service.dart';
import 'package:airspothealth/core/utils/app_utils.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:airspothealth/features/device_settings/models/asc_data.dart';
import 'package:airspothealth/features/device_settings/models/device_sensor_config_data.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/ble_device_version_provider.dart';
import 'package:airspothealth/features/device_settings/providers/device_asc_data_provider.dart';
import 'package:airspothealth/features/device_settings/providers/device_asc_day_count_provider.dart';
import 'package:airspothealth/features/device_settings/providers/device_data_download_provider.dart';
import 'package:airspothealth/features/device_settings/providers/device_data_dump_provider.dart';
import 'package:airspothealth/features/device_settings/providers/device_data_erase_provider.dart';
import 'package:airspothealth/features/device_settings/providers/device_reset_sensor_provider.dart';
import 'package:airspothealth/features/device_settings/providers/device_variant_provider.dart';
import 'package:airspothealth/features/device_settings/providers/populate_fake_data_provider.dart';
import 'package:airspothealth/features/device_settings/providers/recalibration_time_provider.dart';
import 'package:airspothealth/features/device_settings/providers/sensor_configuration_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/device_ui_mode_widget.dart';
import 'package:airspothealth/features/devices/providers/device_battery_level_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

/// BLE data utils class to handle BLE data operations
/// This class provides methods to handle BLE data operations.
class BleDataService {
  /// Converts bytes to hex string
  static String? bytesToHexStr(List<int>? bytes) =>
      bytes?.map((byt) => byt.toRadixString(16).padLeft(2, '0')).join();

  /// history data length
  /// 4 byte timestamp + 1 byte record type + 2 byte value + 1 byte reserved
  static const int deviceDataLength = 8;

  /// timestamp from 2000
  static const int timestampFrom2000 = 946684800; // 2000-01-01 00:00:00 UTC

  /// Parses the response command based on device ID and data
  static dynamic parseResponseCommand(
    Ref<dynamic> ref,
    BleDevice bleDevice,
    List<int> data,
  ) {
    if (data.length < 6) return null;

    final responseCommand = ResponseCommand.fromValue(data[2]);
    final parser = ResponseCommandParser(bleDevice);
    final deviceId = bleDevice.deviceId;

    final responseParsers = {
      ResponseCommand.co2Value: parser.parseCo2Value,
      ResponseCommand.setAlarmResult: parser.parseAlarm,
      ResponseCommand.setVibrationResult: parser.parseVibration,
      ResponseCommand.setTimeResult: parser.parseSetTimeResult,
      ResponseCommand.setPowerMode: parser.parseSetPowermodeResult,
      ResponseCommand.disconnectResult: parser.parseDisconnect,
      ResponseCommand.setCoo2Ppm: parser.parseSetCo2Ppm,
      ResponseCommand.initialData: parser.parseInitialData,
      ResponseCommand.getAlias: parser.parseAlias,
      ResponseCommand.setAliasResult: parser.parseSetAlias,
      ResponseCommand.getCo2History: parser.parseGetCo2History,
      ResponseCommand.calibrateSensors: parser.parseCalibrateSensors,
      ResponseCommand.setContinuosDisplayResult:
          parser.parseSetContinuosDisplay,
      ResponseCommand.firmwareVersion: parser.parseFirmwareVersion,
      ResponseCommand.recalibrationTime: parser.parseRecalibrationTime,
      ResponseCommand.recalibrationConfirm: parser.parseRecalibrationConfirm,
      ResponseCommand.locateMyAirspot: parser.parseLocateMyAirspot,
      ResponseCommand.dataEraseDone: parser.parseEraseDataDone,
      ResponseCommand.batteryLevel: parser.parseBatteryLevel,
      ResponseCommand.dndMode: (_) => null,
      ResponseCommand.populateFakeData: (_) => null,
      ResponseCommand.resetSensorResult: (_) => parser.parseOneByte(data, 4),
      ResponseCommand.ascData: parser.parseAscData,
      ResponseCommand.getMemoryDump: parser.parseMemoryDump,
      ResponseCommand.ascDayCount: (_) => parser.parseOneByte(data, 4),
      ResponseCommand.getDeviceVariant: (_) => parser.parseOneByte(data, 4),
      ResponseCommand.getSensorDetails: parser.parseSensorDetails,
    };

    final dynamic value = responseParsers[responseCommand]?.call(data);

    switch (responseCommand) {
      case ResponseCommand.co2Value:
        return value as DeviceData;
      case ResponseCommand.recalibrationTime:
        ref
            .read(recalibrationTimeProvider(deviceId).notifier)
            .setRecalibrationTime(value);
        break;
      case ResponseCommand.calibrateSensors:
        // If value is an int (not bool), it's the calibration done message
        if (value is int) {
          ref
              .read(recalibrationTimeProvider(deviceId).notifier)
              .setRecalibrationDone(value);
        }
        break;
      case ResponseCommand.recalibrationConfirm:
        if (value != null) {
          ref
              .read(recalibrationTimeProvider(deviceId).notifier)
              .setRecalibrationDone(value);
        }
        break;
      case ResponseCommand.firmwareVersion:
        ref.read(bleSavedDevicesProvider.notifier).reloadDevices();
        ref.invalidate(bleDeviceProvider(deviceId));
        ref.invalidate(bleDeviceVersionProvider(deviceId));
        break;
      case ResponseCommand.initialData:
        ref.invalidate(deviceSettingsProvider(deviceId));
        break;
      case ResponseCommand.getAlias:
        ref.invalidate(bleSavedDevicesProvider);
        // Update widget device list with the new alias
        WidgetService().refreshDeviceList();
        break;
      case ResponseCommand.dataEraseDone:
        ref.read(isarServiceProvider).write((isar) {
          isar.deviceDatas.where().deviceIdEqualTo(deviceId).deleteAll();
        });
        ref.read(deviceDataEraseProvider(deviceId).notifier).setSuccess();
        break;
      case ResponseCommand.batteryLevel:
        ref
            .read(deviceBatteryLevelProvider(deviceId).notifier)
            .updateBatteryLevel(value);
        break;
      case ResponseCommand.getCo2History:
        // if value is true, then data is downloaded from device
        if (value is bool && value == true) {
          ref
              .read(deviceDataDownloadProvider(deviceId).notifier)
              .setDataDownloadedFromDevice();
          return;
        }

        // else handle new data
        if (ref.read(deviceHistoryDataRequestProvider(deviceId))
            is! AsyncNone) {
          ref
              .read(deviceHistoryDataRequestProvider(deviceId).notifier)
              .handleHistoricalDataResponse(value);
        }

        if (value is List<DeviceData> &&
            ref.read(deviceDataDumpProvider(deviceId)) is AsyncInProgress) {
          ref.read(deviceDataDumpProvider(deviceId).notifier).updateData(
              data.map((e) => e.toRadixString(16).padLeft(2, '0')).join());
        }

        break;
      case ResponseCommand.getMemoryDump:
        ref
            .read(deviceDataDumpProvider(deviceId).notifier)
            .addMemoryDump(value as String);
        break;
      case ResponseCommand.populateFakeData:
        ref
            .read(populateFakeDataProvider(deviceId).notifier)
            .populateFakeDataComplete();
      case ResponseCommand.resetSensorResult:
        ref
            .read(deviceSensorResetProvider(deviceId).notifier)
            .setSensorResetDone(value);
        break;
      case ResponseCommand.ascData:
        ref
            .read(deviceASCDataProvider(deviceId).notifier)
            .setAscData(value as AscData);
        break;
      case ResponseCommand.ascDayCount:
        ref.read(deviceAscDayProvider(deviceId).notifier).setNextAscDate(value);
        break;
      case ResponseCommand.getDeviceVariant:
        ref
            .read(deviceVariantProvider(deviceId).notifier)
            .setDeviceVariant(DeviceVariant.fromValue(value));
        break;
      case ResponseCommand.getSensorDetails:
        if (value is DeviceSensorConfigData) {
          ref
              .read(sensorConfigurationProvider(deviceId).notifier)
              .updateSensorConfigData(value);
        }
        break;
      default:
        break;
    }

    return null;
  }

  /// When parsing the timestamp from device, convert to local time
  /// Properly handles Daylight Saving Time transitions
  static DateTime parseDeviceTimestamp(int timestamp) {
    // Since we added the timezone offset when sending the time,
    // we need to subtract it when parsing to get the correct local time
    final nowLocal = DateTime.now();
    final timezoneOffsetSeconds = nowLocal.timeZoneOffset.inSeconds;

    // Subtract the timezone offset to get local time
    final adjustedTimestamp = timestamp - timezoneOffsetSeconds;

    // Convert directly from seconds since Unix epoch to DateTime
    final DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(adjustedTimestamp * 1000);
    debugPrint('Raw device timestamp (seconds): $timestamp');
    debugPrint('Timezone offset (seconds): $timezoneOffsetSeconds');
    debugPrint('Adjusted timestamp (seconds): $adjustedTimestamp');
    debugPrint('Parsed local time: ${dateTime.toIso8601String()}');
    return dateTime;
  }

  /// Debug utility to verify DST handling
  /// Returns a map with information about the timestamp conversion
  static Map<String, dynamic> debugDstHandling(int timestamp) {
    final utcBase2000 = DateTime.utc(2000, 1, 1, 0, 0, 0);
    final deviceTimeUtc = utcBase2000.add(Duration(seconds: timestamp));
    final localTime = deviceTimeUtc.toLocal();

    return {
      'timestamp_seconds': timestamp,
      'utc_time': deviceTimeUtc.toIso8601String(),
      'local_time': localTime.toIso8601String(),
      'is_dst':
          localTime.timeZoneOffset.inHours > utcBase2000.timeZoneOffset.inHours,
      'timezone_offset': localTime.timeZoneOffset.inHours,
    };
  }
}

/// Response command parser class
/// Provides methods to parse response commands
class ResponseCommandParser {
  ResponseCommandParser(this.device);

  final BleDevice device;

  String get deviceId => device.deviceId;

  final IsarService isarService = IsarService();

  /// Parse CO2 value response
  /// When CO2 = 0xFFFF (65535), sensor has failed - bytes 4-5 contain error info
  /// 
  /// Supported formats:
  /// - Short format (6 bytes): CO2 only
  /// - Standard format (11 bytes): Timestamp + CO2
  /// - Extended format (15 bytes): Timestamp + CO2 + Temperature + Humidity (length byte = 0x0A)
  DeviceData parseCo2Value(List<int> data) {
    // Check for new extended format (15 bytes with length byte = 0x0A)
    if (data.length >= 15 && data[3] == 0x0A) {
      // Extended format: Header (2) + Command (1) + Length (1) + Timestamp (4) + CO2 (2) + Temperature (2) + Humidity (2) + Checksum (1)
      // Bytes: 0-1: Header, 2: Command, 3: Length (0x0A), 4-7: Timestamp, 8-9: CO2, 10-11: Temperature, 12-13: Humidity, 14: Checksum
      
      final co2Value = (data[8] << 8) | (data[9] & 0xFF);
      
      // Check for sensor error (0xFFFF = 65535)
      if (co2Value == 0xFFFF) {
        final errorCode = data[4];
        final recoveryAttempts = data[5];
        debugPrint(
            'SENSOR ERROR detected (extended format): CO2 = 0xFFFF, errorCode = $errorCode, recoveryAttempts = $recoveryAttempts');

        return DeviceData(
          deviceId: deviceId,
          dateTime: DateTime.now(),
          value: errorCode,
          type: DeviceDataType.sensorError.index,
          isLiveCo2: true,
        );
      }

      // Parse timestamp (bytes 4-7, Big Endian)
      int datetimeMillis =
          (data[4] << 24) | (data[5] << 16) | (data[6] << 8) | data[7];
      final datetime = BleDataService.parseDeviceTimestamp(datetimeMillis);

      // Parse temperature (bytes 10-11, signed 16-bit Big Endian, divide by 100.0)
      final tempRaw = (data[10] << 8) | (data[11] & 0xFF);
      final temperature = _parseSigned16Bit(tempRaw) / 100.0;

      // Parse humidity (bytes 12-13, unsigned 16-bit Big Endian, divide by 100.0)
      final humRaw = (data[12] << 8) | (data[13] & 0xFF);
      final humidity = humRaw / 100.0;

      debugPrint(
          'CO2 Value: $co2Value, Temperature: ${temperature.toStringAsFixed(2)}°C, Humidity: ${humidity.toStringAsFixed(2)}%, DateTime: ${datetime.toIso8601String()}');

      return DeviceData(
        deviceId: deviceId,
        dateTime: datetime,
        value: co2Value,
        type: DeviceDataType.co2.index,
        isLiveCo2: true,
        temperature: temperature,
        humidity: humidity,
      );
    }

    // Short format (6 bytes)
    if (data.length < 10) {
      final value = (data[4] * 256 + (data[5] & 0xff));
      final datetime = DateTime.now();

      // Check for sensor error (0xFFFF = 65535)
      if (value == 0xFFFF) {
        debugPrint('SENSOR ERROR detected (short format): CO2 = 0xFFFF');
        return DeviceData(
          deviceId: deviceId,
          dateTime: datetime,
          value: 0, // Error code not available in short format
          type: DeviceDataType.sensorError.index,
          isLiveCo2: true,
        );
      }

      return DeviceData(
        deviceId: deviceId,
        dateTime: datetime,
        value: value,
        type: DeviceDataType.co2.index,
        isLiveCo2: true,
      );
    }

    // Standard format (11 bytes)
    // When CO2 = 0xFFFF, bytes 4-7 contain error info instead of timestamp:
    // byte 4 = error code, byte 5 = recovery attempts, bytes 6-7 = reserved
    final co2Value = (data[8] * 256 + (data[9] & 0xff));

    // Check for sensor error (0xFFFF = 65535)
    if (co2Value == 0xFFFF) {
      final errorCode = data[4];
      final recoveryAttempts = data[5];
      debugPrint(
          'SENSOR ERROR detected: CO2 = 0xFFFF, errorCode = $errorCode, recoveryAttempts = $recoveryAttempts');

      return DeviceData(
        deviceId: deviceId,
        dateTime: DateTime.now(),
        // Store error code in value, recovery attempts info will be handled by provider
        value: errorCode,
        type: DeviceDataType.sensorError.index,
        isLiveCo2: true,
      );
    }

    // Normal CO2 reading
    int datetimeMillis =
        (data[4] << 24) | (data[5] << 16) | (data[6] << 8) | data[7];
    final datetime = BleDataService.parseDeviceTimestamp(datetimeMillis);

    debugPrint(
        'CO2 Value: $co2Value, DateTime: ${datetime.toIso8601String()}, millis: $datetimeMillis');

    return DeviceData(
      deviceId: deviceId,
      dateTime: datetime,
      value: co2Value,
      type: DeviceDataType.co2.index,
      isLiveCo2: true,
    );
  }

  /// Parse signed 16-bit integer from unsigned value
  /// Handles two's complement representation
  int _parseSigned16Bit(int unsignedValue) {
    // If the MSB is set, it's negative
    if (unsignedValue & 0x8000 != 0) {
      // Convert from two's complement
      return unsignedValue - 0x10000;
    }
    return unsignedValue;
  }

  bool parseAlarm(List<int> data) => _parseBoolean(data, 4);

  bool parseVibration(List<int> data) => _parseBoolean(data, 4);

  bool parseSetTimeResult(List<int> data) => _parseBoolean(data, 4);

  bool parseSetPowermodeResult(List<int> data) => _parseBoolean(data, 4);

  bool parseDisconnect(List<int> data) => _parseBoolean(data, 4);

  BatteryState parseBatteryLevel(List<int> data) =>
      BatteryState(data[4], data[5] == 0x01);

  bool parseSetCo2Ppm(List<int> data) => _parseBoolean(data, 4);

  String parseFirmwareVersion(List<int> data) {
    final firmwareVersion = _parseString(data, 3);

    isarService.write((isar) {
      final device =
          isar.bleDevices.where().deviceIdEqualTo(deviceId).findFirst();
      if (device == null) {
        return;
      }

      isar.bleDevices.put(device.copyWith(firmwareVersion: firmwareVersion));
    });

    return firmwareVersion;
  }

  dynamic parseInitialData(List<int> data) {
    _updateDeviceSettings(
      (settings) {
        final bool alarmEnabled = _parseBoolean(data, 4);
        final bool vibrationEnabled = _parseBoolean(data, 5);
        final PowerMode powerMode = PowerMode.fromValue(data[6]);
        final DeviceThresholds thresholds = DeviceThresholds(
          greenUpperLimit: _parseTwoBytesToInt(data, 7),
          yellowUpperLimit: _parseTwoBytesToInt(data, 9),
        );
        final bool continuosScreenEnabled = _parseBoolean(data, 11);
        final bool autoCalibration = _parseBoolean(data, 12);

        final bool dndEnabled =
            data.length > 13 ? _parseBoolean(data, 13) : false;
        final int dndStartHour = data.length > 14 ? data[14] : 0;
        final int dndStartMinute = data.length > 15 ? data[15] : 0;
        final int dndEndHour = data.length > 16 ? data[16] : 0;
        final int dndEndMinute = data.length > 17 ? data[17] : 0;

        final int recalibrationTarget =
            data.length > 19 ? _parseTwoBytesToInt(data, 18) : 426;
        final UIMode uiMode =
            data.length > 20 ? UIMode.fromValue(data[20]) : UIMode.graph;
        final int graphMaxValue =
            data.length > 22 ? _parseTwoBytesToInt(data, 21) : 1600;
        final int graphMinValue =
            data.length > 24 ? _parseTwoBytesToInt(data, 23) : 0;

        bool finalScreenOnAlarm = true;
        bool finalAlarmOnCo2Fall = false;
        List<AlarmLevel> finalAlarmLevels = defaultAlarmLevels;
        bool flightMode = false;

        if (data.length >= 25 + 42) {
          int offset = 25;
          finalScreenOnAlarm = _parseBoolean(data, offset++);
          finalAlarmOnCo2Fall = _parseBoolean(data, offset++);

          List<AlarmLevel> parsedLevels = [];
          for (int i = 0; i < 10; i++) {
            if (offset + 3 < data.length) {
              final co2MsbByte = data[offset++] & 0xFF;
              final co2LsbByte = data[offset++] & 0xFF;
              final co2Threshold = (co2MsbByte << 8) | co2LsbByte;
              final repeatCount = data[offset++];
              final enabled = _parseBoolean(data, offset++);

              parsedLevels.add(AlarmLevel(
                id: i,
                co2Threshold: co2Threshold,
                repeatCount: repeatCount,
                enabled: enabled,
              ));
            } else {
              parsedLevels.addAll(defaultAlarmLevels.sublist(i));
              break;
            }
          }
          finalAlarmLevels = parsedLevels;
          debugPrint(
              'InitialData: Successfully parsed advanced alarm settings from initial data.');
        } else {
          debugPrint(
              'InitialData: Data too short for advanced alarm settings (length ${data.length}, needed >= ${25 + 42}). Using all default advanced alarm settings.');
          debugPrint(
              'InitialData: Remaining data after parsing other settings: ${data.sublist(25).map((e) => e.toRadixString(16)).join()}');
        }

        // check if the scaling is present in the data
        // it is a 4 byte float value
        if (data.length >= 25 + 42 + 4) {
          final scaling = parseFloatFromBytes(data, 25 + 42);
          debugPrint('InitialData: Scaling: $scaling');

          settings = settings.copyWith(scaling: scaling);
        }

        // check if the flight mode is present in the data
        if (data.length >= 25 + 42 + 4 + 1) {
          flightMode = _parseBoolean(data, 25 + 42 + 4);
          debugPrint('InitialData: Flight Mode: $flightMode');
        }

        debugPrint(
            'InitialData Final Values -> ScreenOnAlarm: $finalScreenOnAlarm, AlarmOnCo2Fall: $finalAlarmOnCo2Fall');

        return settings.copyWith(
          deviceId: deviceId,
          alarmEnabled: alarmEnabled,
          vibrationEnabled: vibrationEnabled,
          powerMode: powerMode,
          thresholds: thresholds,
          continuosScreenEnabled: continuosScreenEnabled,
          autoCalibration: autoCalibration,
          dndEnabled: dndEnabled,
          dndStartTime: DateTime(0, 0, 0, dndStartHour, dndStartMinute),
          dndEndTime: DateTime(0, 0, 0, dndEndHour, dndEndMinute),
          recalibrationTarget: recalibrationTarget,
          uiMode: uiMode,
          graphMaxValue: graphMaxValue,
          graphMinValue: graphMinValue,
          screenOnAlarm: finalScreenOnAlarm,
          alarmOnCo2Fall: finalAlarmOnCo2Fall,
          alarmLevels: finalAlarmLevels,
          flightMode: flightMode,
        );
      },
    );
    return true;
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

  dynamic parseGetCo2History(List<int> data) {
    // Check if it is a page number response
    if (data.length == 7 && data[3] == 0x01) {
      // return the 4th and 5th bytes are the current page number as uint16_t
      return (data[4] << 8) | data[5];
    }

    // check if it is a co2 history done command
    if (data.length == 6 && data[3] == 0x01 && data[5] == 0xb8) {
      return true;
    }

    // check if the firmware is less than v3.0.0
    // if so, parse it in old format
    if (!AppUtils.isNewFirmwareVersion(device.firmwareVersion)) {
      _parseCo2OldHistoryData(data);

      // return null to indicate that the data is not a page number and has been parsed and saved
      return null;
    }

    // check if the record count is 00
    if (data[3] == 0x00) {
      return [];
    }

    // Check if the data length is valid
    // 5 bytes for the frame headers and checksum
    // 2 bytes for the page number
    if (data.length < 9 ||
        (data.length - 7) % BleDataService.deviceDataLength != 0) {
      debugPrint('Invalid data length');
      return [];
    }

    // Extract the CO2 history data (ignore header and checksum (1 byte), page number (2bytes))
    final List<int> historyData = List.from(data.sublist(4, data.length - 3));

    final List<DeviceData> deviceData = [];

    // Parse each record (6 bytes per record: 4 bytes timestamp, 2 bytes CO₂ value)
    for (var i = 0;
        i < historyData.length;
        i += BleDataService.deviceDataLength) {
      // Extract the timestamp (4 bytes)
      final timestamp = _byteArrayToInt(historyData, i, i + 3);
      final date = BleDataService.parseDeviceTimestamp(timestamp);

      debugPrint('DATE: ${date.toIso8601String()}');

      // Extract the value (2 bytes)
      final highByte = historyData[i + 4] & 0xFF;
      final lowByte = historyData[i + 5] & 0xFF;
      final value = (highByte << 8) | lowByte;

      /// Extract the type (1 byte)
      final type = historyData[i + 6];
      final parsedType = DeviceDataType.fromByte(type).index;

      debugPrint(
          'TYPE: $parsedType, value: $value, date: ${date.toIso8601String()}');

      final deviceData0 = DeviceData(
        deviceId: deviceId,
        dateTime: date,
        value: // if value is > 63000 and less than 65535, then it is a negative value
            (parsedType != DeviceDataType.flightMode.index &&
                    value > 33000 &&
                    value <= 65535)
                ? value - 65536
                : value,
        type: parsedType,
      );

      deviceData.add(deviceData0);
    }

    // isarService.write((isar) {
    //   isar.deviceDatas.putAll(deviceData);
    // });

    return deviceData;
  }

  bool _parseCo2OldHistoryData(List<int> data) {
    // Check if the data length is at least 6 bytes (minimum valid length)
    if (data.length < 6) return false;

    // check if it is a co2 history done command
    if (data.length == 6 && data[3] == 0x01 && data[5] == 0xb8) {
      return true;
    }

    // total data count (3rd byte)
    int dataCount = data[3];

    if (dataCount == 0) {
      return false;
    }

    if (data.length < dataCount + 4) {
      return false;
    }

    // Extract the timestamp (6th to 9th bytes)
    int timestamp = _byteArrayToInt(data, 4, 7);

    // Calculate the timestamp from 2000-01-01 00:00:00 UTC
    int timestampFrom2000 =
        BleDataService.parseDeviceTimestamp(timestamp).millisecondsSinceEpoch;

    // Extract the mode (9th byte)
    int mode = data[8];

    // Calculate the mute time based on the mode
    int muteTime = 0;

    switch (mode) {
      case 0:
        muteTime = 3 * 60;
        break;
      case 1:
        muteTime = 1 * 60;
        break;
      case 2:
        muteTime = 5;
        break;
    }

    // Extract the CO2 data count (10th byte)
    int co2DataCount = dataCount - 5;

    // Extract the CO2 data bytes
    final co2DataBytes = data.sublist(9, 9 + co2DataCount);

    // Extract the CO2 data values
    final co2Data = <DateTime, int>{};

    // if co2 data count is 1, the it is a single value and we don't need to loop
    if (co2DataCount == 1) {
      final value = co2DataBytes[0];
      co2Data.putIfAbsent(
        DateTime.fromMillisecondsSinceEpoch(timestampFrom2000 * 1000),
        () => value,
      );
    } else {
      for (var i = 0; i < co2DataCount; i += 2) {
        // Extract two bytes and combine them into a single value
        final highByte = co2DataBytes[i] & 0xFF;
        final lowByte = co2DataBytes[i + 1] & 0xFF;
        final combinedValue = (highByte << 8) | lowByte;

        // Increment the timestamp after every 2 values
        timestampFrom2000 += muteTime;

        // Store the CO₂ data
        co2Data.putIfAbsent(
          DateTime.fromMillisecondsSinceEpoch(timestampFrom2000 * 1000),
          () => combinedValue,
        );
      }
    }

    final List<DeviceData> dd = co2Data.entries.map((e) {
      return DeviceData(
        deviceId: deviceId,
        dateTime: e.key,
        value: e.value,
      );
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    debugPrint('LogData: ${dd.map((e) => e.toString()).toList()}');

    isarService.write((isar) {
      isar.deviceDatas.putAll(dd);
    });
    // Note: Zone cache will be invalidated automatically when data count changes

    return false;
  }

  int _byteArrayToInt(List<int> data, int startIndex, int endIndex) {
    int result = 0;
    for (var i = startIndex; i <= endIndex; i++) {
      result =
          (result << 8) | (data[i] & 0xFF); // Combine bytes into an integer
    }
    return result;
  }

  dynamic parseCalibrateSensors(List<int> data) {
    // Check if this is a calibration done message (byte[3] == 0x01)
    if (data.length >= 8 && data[3] == 0x01) {
      // Parse correction value from bytes 4-5
      int frc = (data[4] << 8) | data[5];

      // Check sign in byte 6 (0x00 = positive, 0x01 = negative)
      if (data[6] == 0x01) {
        frc = -frc;
      }

      return frc;
    }
    // Otherwise it's a start command, return boolean
    return _parseBoolean(data, 4);
  }

  bool parseSetContinuosDisplay(List<int> data) => _parseBoolean(data, 4);

  int parseRecalibrationTime(List<int> data) => (data[4] << 8) | data[5];

  int? parseRecalibrationConfirm(List<int> data) {
    if (data.length < 8) return null;

    // combine the 5th and 6th bytes to get the recalibration time
    int frc = (data[4] << 8) | data[5];

    // if the 7th byte is 0x00 then it is negative value else positive
    if (data[6] == 0x01) {
      frc = -frc;
    }

    return frc;
  }

  AscData parseAscData(List<int> data) {
    final count = (data[4] << 8) | data[5];
    int correction = (data[6] << 8) | data[7];
    if (data[8] == 0x01) {
      correction = -correction;
    }
    return AscData(
      count: count,
      correction: correction,
    );
  }

  bool parseLocateMyAirspot(List<int> data) => _parseBoolean(data, 4);

  bool parseEraseDataDone(List<int> data) => _parseBoolean(data, 4);

  String parseMemoryDump(List<int> data) {
    final dumpData = data.sublist(4, data.length - 1);
    final dumpString = dumpData.map((e) => e.toRadixString(16)).join();
    debugPrint('Memory Dump: $dumpString');
    return dumpString;
  }

  int parseOneByte(List<int> data, int index) => data[index];

  // Helper Methods
  int _parseTwoBytesToInt(List<int> data, int startIndex) =>
      _byteArrayToInt(data, startIndex, startIndex + 1);

  bool _parseBoolean(List<int> data, int index) => data[index] == 0x01;

  String _parseString(List<int> data, int sizeIndex) {
    final size = data[sizeIndex];
    final contentArray = data.sublist(4, size + 4);
    return String.fromCharCodes(contentArray);
  }

  double parseFloatFromBytes(List<int> data, int startIndex) {
    final bytes = data.sublist(startIndex, startIndex + 4);
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    return byteData.getFloat32(0, Endian.big); // Big-endian from C code
  }

  void _updateDeviceSettings(DeviceSettings Function(DeviceSettings) update) {
    try {
      isarService.write((isar) {
        final settings =
            isar.deviceSettings.where().deviceIdEqualTo(deviceId).findFirst();

        final updatedSettings =
            update(settings ?? DeviceSettings.empty(deviceId: deviceId));

        debugPrint('UPDATED SETTINGS: ${updatedSettings.toJson()}');

        isar.deviceSettings.put(updatedSettings);
      });
    } catch (e) {
      debugPrint('Error updating device settings: $e');
    } finally {
      debugPrint(
          'Device settings: ${isarService.read((isar) => isar.deviceSettings.where().findAll())}');
    }
  }

  DeviceSensorConfigData parseSensorDetails(List<int> data) {
    if (data.length < 21) {
      // Basic check for minimum length
      throw Exception(
          'Invalid data length for SensorDetails. Expected at least 21 bytes, got ${data.length}');
    }

    int offset = 4; // Start of payload after ffaa3010

    var rawTempOffset = (data[offset++] << 8) | data[offset++];
    // Convert this to actual temperature using the formula:
    // T_offset [°C] = word[0] * (175 / (2^16 - 1))
    // word[0] is rawTempOffset (a 16-bit integer)
    // (2^16 - 1) is 65535
    final double actualTempOffset = rawTempOffset * (175.0 / 65535.0);

    final altitude = (data[offset++] << 8) | data[offset++];
    final ambientPressureMbar = (data[offset++] << 8) | data[offset++];
    final ascEnabled = data[offset++] == 0x01;
    final ascTarget = (data[offset++] << 8) | data[offset++];

    final serialNoBytes = data.sublist(offset, offset + 6);
    offset += 6;
    final serialNumber = serialNoBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();

    final sensorVariantByte = data[offset++];
    final sensorVariant =
        "SCD4$sensorVariantByte"; // User's change incorporated

    // Note: Checksum is at data[offset] or data[data.length-1]
    // We are not verifying checksum here but it's good practice to do so.

    return DeviceSensorConfigData(
      temperatureOffset: actualTempOffset, // Use the converted double value
      sensorAltitude: altitude,
      ambientPressure: ambientPressureMbar,
      ascEnabled: ascEnabled,
      ascTarget: ascTarget,
      serialNumber: serialNumber,
      sensorVariant: sensorVariant,
    );
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
  getAlias(0x09),
  setAliasResult(0x0A),
  getCo2History(0x0C),
  calibrateSensors(0x0D),
  setContinuosDisplayResult(0x0E),
  firmwareVersion(0x13),
  recalibrationTime(0x0F),
  recalibrationConfirm(0x1F),
  locateMyAirspot(0x10),
  dataEraseDone(0xFD),
  batteryLevel(0x20),
  dndMode(0x22),
  populateFakeData(0x23),
  resetSensorResult(0x24),
  ascData(0x25),
  getMemoryDump(0x26),
  ascDayCount(0x2A),
  getDeviceVariant(0x2B),
  getAdvancedAlarmSettings(0x2F),
  getSensorDetails(0x30);

  const ResponseCommand(this.value);
  final int value;

  factory ResponseCommand.fromValue(int value) =>
      ResponseCommand.values.firstWhere((e) => e.value == value,
          orElse: () => throw 'Invalid value: $value');
}
