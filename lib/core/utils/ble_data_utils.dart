/// BLE data utils class to handle BLE data operations
/// This class provides methods to handle BLE data operations.
class BleDataUtils {
  /// Method to convert bytes to hex string
  static String? bytesToHexStr(List<int>? bytes) {
    if (bytes == null || bytes.isEmpty) {
      return null;
    }
    final stringBuilder = StringBuffer();
    for (int byte in bytes) {
      stringBuilder.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return stringBuilder.toString();
  }

  /// method to parse data
  static dynamic parse(List<int> data) {
    if (data.length < 6) {
      return;
    }

    final type = data[2];
    if (type case 1) {
      final co2Value = data[4] * 256 + (data[5] & 0xff);
      return co2Value;
    } else {
      return null;
    }
  }
}
