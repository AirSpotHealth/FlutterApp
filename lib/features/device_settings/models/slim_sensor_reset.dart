/// Parse acknowledgement of an explicitly requested calibration erase.
class SlimSensorReset {
  /// Zero is success; the dedicated reset returns a signed 16-bit error.
  static int? acknowledgement(List<int> frame) {
    if (frame.length != 7 ||
        frame[0] != 255 ||
        frame[1] != 170 ||
        frame[2] != 0x3a ||
        frame[3] != 2 ||
        (frame.take(6).fold<int>(0, (a, b) => a + b) & 255) != frame[6]) {
      return null;
    }
    final value = (frame[4] << 8) | frame[5];
    return value >= 32768 ? value - 65536 : value;
  }
}
