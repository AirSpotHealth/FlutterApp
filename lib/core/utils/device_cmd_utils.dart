import 'dart:convert';
import 'dart:typed_data';

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

  // ======= Time Commands =======
  static Uint8List setTime({int? hour, int? min}) {
    int totalSeconds;

    if (hour == null || min == null) {
      DateTime calendar2000 = DateTime(2000, 1, 1, 0, 0, 0);
      int startEpochMillis = calendar2000.millisecondsSinceEpoch;
      int currentEpochMillis = DateTime.now().millisecondsSinceEpoch;
      totalSeconds = (currentEpochMillis - startEpochMillis) ~/ 1000;
    } else {
      totalSeconds = _convertToSeconds(hour, min);
    }

    var byteArray = ByteData(4)..setInt32(0, totalSeconds, Endian.big);
    return _buildCommand(
        [prefixHigh, prefixLow, 0x04, 0x04, ...byteArray.buffer.asUint8List()]);
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

  // Helper method to convert hours and minutes to total seconds
  static int _convertToSeconds(int hours, int minutes) {
    return (hours * 3600) + (minutes * 60);
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

  static Uint8List setCo2PPM(int low, int med) {
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
    return _buildCommand([prefixHigh, prefixLow, 0x0D, 1, 1]);
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

  // ======= Helper Functions =======
  static Uint8List _getHex2Bytes(int value) {
    var byteArray = Uint8List(2);
    byteArray[0] = (value >> 8) & 0xFF;
    byteArray[1] = value & 0xFF;
    return byteArray;
  }

  static Uint8List eraseData() {
    return _buildCommand([prefixHigh, prefixLow, 0xFD, 1, 1]);
  }

  static Uint8List setSensorError(bool high) {
    return _buildCommand([prefixHigh, prefixLow, 0xFF, 1, high ? 1 : 0]);
  }

  static Uint8List getSensorErrors() {
    final DateTime now = DateTime.now();

    int since2000ToStartDate =
        calculateSecondsSince2000(now.subtract(Duration(days: 7)));
    int since2000ToEndDate = calculateSecondsSince2000(now);

    var byteArrayStart = ByteData(4)
      ..setInt32(0, since2000ToStartDate, Endian.big);
    var byteArrayNow = ByteData(4)..setInt32(0, since2000ToEndDate, Endian.big);

    return _buildCommand([
      prefixHigh,
      prefixLow,
      0x0C,
      0x08,
      ...byteArrayStart.buffer.asUint8List(),
      ...byteArrayNow.buffer.asUint8List(),
      3
    ]);
  }
}
