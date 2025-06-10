import 'dart:convert';
import 'dart:typed_data';

import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:flutter/material.dart';

class DeviceCmdUtils {
  static const int prefixHigh = 0xFF;
  static const int prefixLow = 0xAA;

  // Helper method to add checksum and return the final byte array
  static Uint8List _buildCommand(List<int> commandWithoutChecksum) {
    int checksum =
        _calculateChecksum(Uint8List.fromList(commandWithoutChecksum));
    return Uint8List.fromList([...commandWithoutChecksum, checksum]);
  }

  // Helper method to calculate checksum
  static int _calculateChecksum(Uint8List data) {
    int checksum = 0;
    for (var byte in data) {
      checksum = (checksum + byte) & 0xFF;
    }
    return checksum;
  }

  static Uint8List setTime({int? hour, int? min}) {
    // Get current time or specified time in local time
    final now = DateTime.now();
    final DateTime localTime;

    if (hour != null && min != null) {
      // Set to specified hour and minute of current day in local time
      localTime = DateTime(now.year, now.month, now.day, hour, min);
    } else {
      localTime = now;
    }

    // The device displays time as-is without timezone adjustment,
    // so we need to adjust the timestamp we send to account for the
    // local timezone offset
    final timezoneOffsetSeconds = localTime.timeZoneOffset.inSeconds;

    // Add the timezone offset to compensate (device will show local time)
    final int adjustedSeconds =
        (localTime.millisecondsSinceEpoch ~/ 1000) + timezoneOffsetSeconds;

    debugPrint('Local time: ${localTime.toIso8601String()}');
    debugPrint('Timezone offset (seconds): $timezoneOffsetSeconds');
    debugPrint('Adjusted timestamp: $adjustedSeconds');

    // Convert to bytes
    final bytes = Uint8List(4);
    bytes[0] = (adjustedSeconds >> 24) & 0xFF;
    bytes[1] = (adjustedSeconds >> 16) & 0xFF;
    bytes[2] = (adjustedSeconds >> 8) & 0xFF;
    bytes[3] = adjustedSeconds & 0xFF;

    return _buildCommand([prefixHigh, prefixLow, 0x04, 0x04, ...bytes]);
  }

  // ======= Alias Commands =======
  static Uint8List setAlias(String alias) {
    var nameBytes = utf8.encode(alias);
    return _buildCommand(
        [prefixHigh, prefixLow, 0x0A, nameBytes.length, ...nameBytes]);
  }

  static Uint8List getAlias() {
    return _buildCommand([prefixHigh, prefixLow, 0x09, 1, 1]);
  }

  static Uint8List getDeviceSensorConfig() {
    return _buildCommand([prefixHigh, prefixLow, 0x30, 1, 1]);
  }

  // ======= General Commands =======
  static Uint8List getCO2() {
    return _buildCommand([prefixHigh, prefixLow, 1, 1, 1]);
  }

  static Uint8List getBatteryLevel() {
    return _buildCommand([prefixHigh, prefixLow, 0x20, 1, 1]);
  }

  static Uint8List refreshCO2() {
    return _buildCommand([prefixHigh, prefixLow, 0x21, 1, 1]);
  }

  static Uint8List openAlarm() {
    return _buildCommand([prefixHigh, prefixLow, 2, 1, 1]);
  }

  static Uint8List closeAlarm() {
    return _buildCommand([prefixHigh, prefixLow, 2, 1, 0]);
  }

  static Uint8List findDevice() {
    return _buildCommand([prefixHigh, prefixLow, 0x10, 1, 1]);
  }

  static Uint8List getFirmVersion() {
    return _buildCommand([prefixHigh, prefixLow, 0x13, 1, 1]);
  }

  // ======= Vibration Commands =======
  static Uint8List openVibration() {
    return _buildCommand([prefixHigh, prefixLow, 3, 1, 1]);
  }

  static Uint8List closeVibration() {
    return _buildCommand([prefixHigh, prefixLow, 3, 1, 0]);
  }

  // ======= Power Mode Commands =======
  static Uint8List setPowerOnDemand() {
    return _buildCommand([prefixHigh, prefixLow, 5, 1, 0]);
  }

  static Uint8List setPowerLow() {
    return _buildCommand([prefixHigh, prefixLow, 5, 1, 1]);
  }

  static Uint8List setPowerMed() {
    return _buildCommand([prefixHigh, prefixLow, 5, 1, 2]);
  }

  static Uint8List setPowerHi() {
    return _buildCommand([prefixHigh, prefixLow, 5, 1, 3]);
  }

  // ======= Bluetooth Commands =======
  static Uint8List openBluetooth() {
    return _buildCommand([prefixHigh, prefixLow, 6, 1, 1]);
  }

  static Uint8List closeBluetooth() {
    return _buildCommand([prefixHigh, prefixLow, 6, 1, 0]);
  }

  static Uint8List initBluetooth() {
    return _buildCommand([prefixHigh, prefixLow, 8, 1, 1]);
  }

  static Uint8List forgetDevice() {
    return _buildCommand([prefixHigh, prefixLow, 6, 1, 1]);
  }

  // ======= Device Light Commands =======
  static Uint8List setScreenOnContinuously() {
    return _buildCommand([prefixHigh, prefixLow, 0x0e, 1, 1]);
  }

  static Uint8List resetScreenOnContinuously() {
    return _buildCommand([prefixHigh, prefixLow, 0x0e, 1, 2]);
  }

  // ======= CO2 History and Value Commands =======
  static int calculateSecondsSince2000(DateTime targetDate) {
    DateTime startDate2000 = DateTime(2000, 1, 1);
    return targetDate.difference(startDate2000).inSeconds;
  }

  static Uint8List getCurrentFlashPage() {
    return _buildCommand([prefixHigh, prefixLow, 0x0B, 1, 0]);
  }

  static Uint8List getCo2HistoryOld(
      {required DateTime startDate, required DateTime endDate}) {
    // Calculate the total seconds since January 1, 2000, to today start and current time
    int since2000ToStartDate = calculateSecondsSince2000(startDate);
    int since2000ToEndDate = calculateSecondsSince2000(endDate);

    // Convert the calculated seconds to byte arrays
    var byteArrayStart = ByteData(4)
      ..setInt32(0, since2000ToStartDate, Endian.big);
    var byteArrayNow = ByteData(4)..setInt32(0, since2000ToEndDate, Endian.big);

    // Construct the BLE command
    return _buildCommand([
      ...[prefixHigh, prefixLow, 0x0C, 0x08],
      ...byteArrayStart.buffer.asUint8List(),
      ...byteArrayNow.buffer.asUint8List()
    ]);
  }

  static Uint8List getCo2History(int pageNumber) {
    if (pageNumber < 0 || pageNumber > Constants.maxFlashPageCount - 1) {
      throw Exception(
          'Page offset must be between 0 and ${Constants.maxFlashPageCount - 1}');
    }

    var byteArray = ByteData(2)..setInt16(0, pageNumber, Endian.big);
    return _buildCommand(
        [prefixHigh, prefixLow, 0x0C, 0x02, ...byteArray.buffer.asUint8List()]);
  }

  static Uint8List setGraphThreshold(int low, int med) {
    var lowBytes = _getHex2Bytes(low);
    var medBytes = _getHex2Bytes(med);
    return _buildCommand(
        [prefixHigh, prefixLow, 0x07, 0x04, ...lowBytes, ...medBytes]);
  }

  // ======= Device Name Commands =======
  static Uint8List setDeviceName(String param) {
    var nameBytes = utf8.encode(param);
    return _buildCommand(
        [prefixHigh, prefixLow, 0x0A, nameBytes.length, ...nameBytes]);
  }

  // ======= Get Initial Data =======
  static Uint8List getInitialData() {
    return _buildCommand([prefixHigh, prefixLow, 0x08, 1, 1]);
  }

  // ======= Device Calibration Commands =======
  static Uint8List setCalibrationAuto() {
    return _buildCommand([prefixHigh, prefixLow, 0x11, 1, 1]);
  }

  static Uint8List setCalibrationManual() {
    return _buildCommand([prefixHigh, prefixLow, 0x11, 1, 0]);
  }

  static Uint8List startRecalibration() {
    return _buildCommand([prefixHigh, prefixLow, 0x0D, 0]);
  }

  // ======= DND Commands =======
  static Uint8List setDND(DateTime? startTime, DateTime? endTime) {
    if (startTime == null || endTime == null) {
      throw Exception('Start and end time must be provided');
    }

    debugPrint('Start Time: $startTime, End Time: $endTime');

    // format should be h,m, h,m
    return _buildCommand([
      prefixHigh,
      prefixLow,
      0x22,
      0x05,
      1,
      startTime.hour.toUnsigned(8),
      startTime.minute.toUnsigned(8),
      endTime.hour.toUnsigned(8),
      endTime.minute.toUnsigned(8),
    ]);
  }

  static Uint8List resetDND() {
    return _buildCommand([prefixHigh, prefixLow, 0x22, 1, 0]);
  }

  // ======= Device Power Commands =======
  static Uint8List powerOff() {
    return _buildCommand([prefixHigh, prefixLow, 0xEE, 1, 1]);
  }

  // ======= Other Commands =======
  static Uint8List populateFakeData() {
    return _buildCommand([prefixHigh, prefixLow, 0x23, 1, 1]);
  }

  static Uint8List turnOffBluetooth() {
    return _buildCommand([prefixHigh, prefixLow, 0x06, 1, 1]);
  }

  static Uint8List resetSensor() {
    return _buildCommand([prefixHigh, prefixLow, 0x24, 1, 1]);
  }

  static Uint8List getAscData() {
    return _buildCommand([prefixHigh, prefixLow, 0x25, 1, 1]);
  }

  static Uint8List getMemoryDump() {
    return _buildCommand([prefixHigh, prefixLow, 0x26, 1, 1]);
  }

  static Uint8List restartDevice() {
    return _buildCommand([prefixHigh, prefixLow, 0x27, 1, 1]);
  }

  static Uint8List setGraphMode(
      int uiMode, int graphMaxValue, int graphMinValue) {
    return _buildCommand([
      prefixHigh,
      prefixLow,
      0x28,
      5,
      uiMode,
      ..._getHex2Bytes(graphMaxValue),
      ..._getHex2Bytes(graphMinValue),
    ]);
  }

  static Uint8List setAscDuration(int duration) {
    return _buildCommand([
      prefixHigh,
      prefixLow,
      0x29,
      0x02,
      ..._getHex2Bytes(duration),
    ]);
  }

  static Uint8List getAscDayCount() {
    return _buildCommand([prefixHigh, prefixLow, 0x2A, 1, 1]);
  }

  static Uint8List getDeviceVariant() {
    return _buildCommand([prefixHigh, prefixLow, 0x2B, 1, 1]);
  }

  // ======= Advanced Alarm Settings Commands =======
  static Uint8List setAdvancedAlarmLevels(int index, AlarmLevel alarmLevel) {
    if (index < 0 || index > 9) {
      throw Exception('Index must be between 0 and 9');
    }

    var thresholdBytes = _getHex2Bytes(alarmLevel.co2Threshold);

    // repeatCount should be a single byte
    int repeatCountByte = alarmLevel.repeatCount & 0xFF;

    // enabled should be a single byte (0 or 1)
    int enabledByte = alarmLevel.enabled ? 1 : 0;

    return _buildCommand([
      prefixHigh,
      prefixLow,
      0x2C,
      5,
      index,
      ...thresholdBytes,
      repeatCountByte,
      enabledByte
    ]);
  }

  static Uint8List resetAdvancedAlarmsToDefault() {
    return _buildCommand([
      prefixHigh,
      prefixLow,
      0x2F, // Command for Reset to default alarm config
      0 // Length of payload (no additional data needed beyond command)
    ]);
  }

  static Uint8List setScreenOnAlarm(bool enabled) {
    return _buildCommand([
      prefixHigh,
      prefixLow,
      0x2D, // Command for Set screen_on_alarm
      1, // Length of payload (enabled status)
      enabled ? 1 : 0
    ]);
  }

  static Uint8List setAlarmOnCo2Fall(bool enabled) {
    return _buildCommand([
      prefixHigh,
      prefixLow,
      0x2E, // Command for Set alarm on CO2 falling
      1, // Length of payload (enabled status)
      enabled ? 1 : 0
    ]);
  }

  static Uint8List setScaleFactor(double scaling) {
    return _buildCommand([
      prefixHigh,
      prefixLow,
      0x31, // Command for set scale factor
      0x04, // Length of payload (4 bytes float value)
      ...getFloat32Bytes(scaling),
    ]);
  }

  static Uint8List setFlightMode(bool flightMode) {
    return _buildCommand([
      prefixHigh,
      prefixLow,
      0x32, // Command for set flight mode
      1, // Length of payload (1 byte)
      flightMode ? 1 : 0
    ]);
  }

  // ======= Helper Functions =======
  static Uint8List _getHex2Bytes(int value) {
    var byteArray = Uint8List(2);
    byteArray[0] = (value >> 8) & 0xFF;
    byteArray[1] = value & 0xFF;
    return byteArray;
  }

  static Uint8List getFloat32Bytes(double value) {
    final byteData = ByteData(4);
    byteData.setFloat32(
        0,
        value,
        Endian
            .big); // use Endian.little if your BLE peripheral expects little-endian
    return byteData.buffer.asUint8List();
  }

  static Uint8List setRecalibrationTarget(int target) {
    return _buildCommand(
        [prefixHigh, prefixLow, 0x0D, 0x02, ..._getHex2Bytes(target)]);
  }

  static Uint8List eraseData() {
    return _buildCommand([prefixHigh, prefixLow, 0xFD, 1, 1]);
  }

  static Uint8List factoryReset() {
    return _buildCommand([prefixHigh, prefixLow, 0xFA, 1, 1]);
  }

  static Uint8List setSensorError(bool high) {
    return _buildCommand([prefixHigh, prefixLow, 0xFF, 1, high ? 1 : 0]);
  }
}
