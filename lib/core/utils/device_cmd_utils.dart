import 'dart:convert';
import 'dart:typed_data';

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
  // Method to set the time with an option for custom hours and minutes
  static Uint8List setTime({int? hour, int? min}) {
    int totalSeconds;

    if (hour == null || min == null) {
      // Use current time
      DateTime calendar2000 = DateTime(2000, 1, 1, 0, 0, 0);
      int startEpochMillis = calendar2000.millisecondsSinceEpoch;
      int currentEpochMillis = DateTime.now().millisecondsSinceEpoch;
      totalSeconds = (currentEpochMillis - startEpochMillis) ~/ 1000;
    } else {
      totalSeconds = _convertToSeconds(hour, min);
    }

    // Convert seconds to byte array (big-endian format)
    var byteArray = ByteData(4)..setInt32(0, totalSeconds, Endian.big);

    // Prefix data
    Uint8List prefixData =
        Uint8List.fromList([prefixHigh, prefixLow, 0x04, 0x04]);

    // Combine prefix and byte array
    Uint8List combinedArrayWithoutChecksum =
        Uint8List.fromList([...prefixData, ...byteArray.buffer.asUint8List()]);

    // Calculate checksum
    int checksum = _calculateChecksum(combinedArrayWithoutChecksum);

    // Combine array with checksum
    Uint8List combinedArrayWithChecksum =
        Uint8List.fromList([...combinedArrayWithoutChecksum, checksum]);

    return combinedArrayWithChecksum;
  }

  // ======= Alias Commands =======
  static Uint8List setAlias(String alias) {
    var nameBytes = utf8.encode(alias);
    Uint8List prefixData =
        Uint8List.fromList([prefixHigh, prefixLow, 0x0A, nameBytes.length]);

    Uint8List combinedArrayWithoutChecksum =
        Uint8List.fromList([...prefixData, ...nameBytes]);

    int checksum = _calculateChecksum(combinedArrayWithoutChecksum);

    Uint8List combinedArrayWithChecksum =
        Uint8List.fromList([...combinedArrayWithoutChecksum, checksum]);

    return combinedArrayWithChecksum;
  }

  static Uint8List getAlias() {
    return _buildCommand([prefixHigh, prefixLow, 0x09, 1, 1, 0xb4]);
  }

  // Helper method to convert hours and minutes to total seconds
  static int _convertToSeconds(int hours, int minutes) {
    return (hours * 3600) + (minutes * 60);
  }

  // ======= General Commands =======

  static Uint8List getCO2() {
    return _buildCommand([prefixHigh, prefixLow, 1, 1, 1, 0xAC]);
  }

  static Uint8List openAlarm() {
    return _buildCommand([prefixHigh, prefixLow, 2, 1, 1, 0xAD]);
  }

  static Uint8List closeAlarm() {
    return _buildCommand([prefixHigh, prefixLow, 2, 1, 0, 0xAC]);
  }

  static Uint8List findDevice() {
    return _buildCommand([prefixHigh, prefixLow, 0x10, 1, 1, 0xBB]);
  }

  // Get firmware version
  static Uint8List getFirmVersion() {
    return _buildCommand([prefixHigh, prefixLow, 0x13, 1, 1, 0xBE]);
  }

  // ======= Vibration Commands =======

  static Uint8List openVibration() {
    return _buildCommand([prefixHigh, prefixLow, 3, 1, 1, 0xAE]);
  }

  static Uint8List closeVibration() {
    return _buildCommand([prefixHigh, prefixLow, 3, 1, 0, 0xAD]);
  }

  // ======= Power Mode Commands =======

  static Uint8List setPowerLow() {
    return _buildCommand([prefixHigh, prefixLow, 5, 1, 0, 0xAF]);
  }

  static Uint8List setPowerMed() {
    return _buildCommand([prefixHigh, prefixLow, 5, 1, 1, 0xB0]);
  }

  static Uint8List setPowerHi() {
    return _buildCommand([prefixHigh, prefixLow, 5, 1, 2, 0xB1]);
  }

  static Uint8List openPowerMode() {
    return _buildCommand([prefixHigh, prefixLow, 5, 1, 1, 0xB0]);
  }

  static Uint8List closePowerMode() {
    return _buildCommand([prefixHigh, prefixLow, 5, 1, 0, 0xAF]);
  }

  // ======= Bluetooth Commands =======

  static Uint8List openBluetooth() {
    return _buildCommand([prefixHigh, prefixLow, 6, 1, 1, 0xB1]);
  }

  static Uint8List closeBluetooth() {
    return _buildCommand([prefixHigh, prefixLow, 6, 1, 0, 0xB0]);
  }

  static Uint8List initBluetooth() {
    return _buildCommand([prefixHigh, prefixLow, 8, 1, 1, 0xB3]);
  }

  static Uint8List forgetDevice() {
    return _buildCommand([prefixHigh, prefixLow, 6, 1, 1, 0xB1]);
  }

  // ======= Device Light Commands =======

  static Uint8List keepDeviceLight() {
    return _buildCommand([prefixHigh, prefixLow, 0x0e, 1, 1, 0xb9]);
  }

  static Uint8List closeDeviceLight() {
    return _buildCommand([prefixHigh, prefixLow, 0x0e, 1, 2, 0xba]);
  }

  // ======= CO2 History and Value Commands =======

  static Uint8List setCo2Notify() {
    return _buildCommand([prefixHigh, prefixLow, 6, 1, 1, 0x6f]);
  }

  static int calculateSecondsSince2000(DateTime targetDate) {
    DateTime startDate2000 = DateTime(2000, 1, 1);
    return targetDate.difference(startDate2000).inSeconds;
  }

  static Uint8List getCo2History() {
    DateTime currentDate = DateTime.now();
    DateTime todayStart =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    // Calculate the total seconds since January 1, 2000, to today start and current time
    int since2000ToYesterday0 = calculateSecondsSince2000(todayStart);
    int since2000ToYesterdayNow = calculateSecondsSince2000(currentDate);

    // Convert the calculated seconds to byte arrays
    var byteArrayStart = ByteData(4)
      ..setInt32(0, since2000ToYesterday0, Endian.big);
    var byteArrayNow = ByteData(4)
      ..setInt32(0, since2000ToYesterdayNow, Endian.big);

    // Construct the BLE command
    return _buildCommand([
      ...[prefixHigh, prefixLow, 0x0C, 0x08],
      ...byteArrayStart.buffer.asUint8List(),
      ...byteArrayNow.buffer.asUint8List()
    ]);
  }

  static Uint8List stopCo2History() {
    return _buildCommand([prefixHigh, prefixLow, 0x0C, 1, 0, 0xB6]);
  }

  static Uint8List setCo2PPM(int low, int med) {
    var lowBytes = _getHex2Bytes(low);
    var medBytes = _getHex2Bytes(med);
    return _buildCommand([
      ...[prefixHigh, prefixLow, 0x07, 0x04],
      ...lowBytes,
      ...medBytes
    ]);
  }

  // ======= Device Name Commands =======

  static Uint8List getDeviceName() {
    return _buildCommand([prefixHigh, prefixLow, 0x09, 1, 1, 0xb4]);
  }

  static Uint8List setDeviceName(String param) {
    var nameBytes = utf8.encode(param);
    return _buildCommand([
      ...[prefixHigh, prefixLow, 0x0A, nameBytes.length],
      ...nameBytes
    ]);
  }

  // ======= Get Initial Data =======
  static Uint8List getInitialData() {
    return _buildCommand([prefixHigh, prefixLow, 0x08, 1, 1, 0xb3]);
  }

  // ======= Device Calibration Commands =======
  static Uint8List setCalibrationAuto() {
    return _buildCommand([prefixHigh, prefixLow, 0x11, 1, 1, 0xBC]);
  }

  static Uint8List setCalibrationManual() {
    return _buildCommand([prefixHigh, prefixLow, 0x11, 1, 0, 0xBB]);
  }

  static Uint8List startRecalibration() {
    return _buildCommand([prefixHigh, prefixLow, 0x0D, 1, 1, 0xB8]);
  }
  // ======= Helper Functions =======

  static Uint8List _getHex2Bytes(int value) {
    var byteArray = Uint8List(2);
    byteArray[0] = (value >> 8) & 0xFF;
    byteArray[1] = value & 0xFF;
    return byteArray;
  }
}
