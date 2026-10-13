import 'native_asc_state.dart';

/// Select the reset from the confirmed sensor policy, never an optimistic toggle.
class SlimSensorReset {
  static bool erasesHistory(String version, NativeAscState? asc) {
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(version);
    if (match == null || version == '0.17.12') {
      throw StateError('Update Slim firmware before resetting calibration.');
    }
    if (!NativeAscState.supported(version)) return false;
    if (asc == null || !asc.verified || asc.error != 0) {
      throw StateError(
          'Confirm the auto-calibration setting before resetting.');
    }
    if (!asc.enabled) return false;
    final major = int.parse(match[1]!);
    final minor = int.parse(match[2]!);
    final patch = int.parse(match[3]!);
    if (major == 0 && minor == 18 && patch < 7) {
      throw StateError(
          'Update Slim firmware to 0.18.7 or later to reset internal calibration history.');
    }
    return true;
  }

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
