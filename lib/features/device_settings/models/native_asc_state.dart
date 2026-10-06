/// Authoritative sensor learning policy, returned by Slim firmware 0.18.0+.
class NativeAscState {
  const NativeAscState(
      {required this.mode,
      required this.verified,
      required this.error,
      required this.sensorStatus});
  final int
      mode; // 0: host/manual, 1: native baseline held, 2: native learning.
  final bool verified;
  final int error;
  final int sensorStatus;
  bool get enabled => mode == 2;
  bool get manualAllowed => verified && error == 0 && !enabled;

  static bool supported(String version) {
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(version);
    if (match == null) return false;
    final major = int.parse(match[1]!);
    final minor = int.parse(match[2]!);
    return major > 0 || minor >= 18;
  }

  static bool canCalibrate(String version, NativeAscState? state) {
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) return false;
    if (version == '0.17.12') return false; // Fixed native-ASC experiment.
    return supported(version) ? state?.manualAllowed == true : true;
  }

  factory NativeAscState.fromFrame(List<int> data) {
    if (data.length != 12 ||
        data[0] != 0xff ||
        data[1] != 0xaa ||
        data[2] != 0x38 ||
        data[3] != 7 ||
        data[4] != 1 ||
        data[5] > 2 ||
        data[6] > 1 ||
        (data.take(11).fold<int>(0, (a, b) => a + b) & 255) != data[11]) {
      throw const FormatException('Invalid auto-calibration response');
    }
    final error = (data[7] << 8) | data[8];
    final status = (data[9] << 8) | data[10];
    final matches = ((status & 0x80) == 0) == (data[5] == 2);
    return NativeAscState(
        mode: data[5],
        verified: data[6] == 1 && matches,
        error: error >= 32768 ? error - 65536 : error,
        sensorStatus: status);
  }
}
