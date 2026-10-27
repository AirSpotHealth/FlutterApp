import 'dart:typed_data';

/// First-hour white-blink status, separate from 12-hour recovery guidance.
class InitialSettlingState {
  const InitialSettlingState(this.active, this.remainingSeconds);
  final bool active;
  final int remainingSeconds;

  static bool supported(String version) {
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(version);
    if (match == null) return false;
    final major = int.parse(match[1]!);
    final minor = int.parse(match[2]!);
    final patch = int.parse(match[3]!);
    return major > 0 || minor > 22 || (minor == 22 && patch >= 4);
  }

  static const request = [0xff, 0xaa, 0x3e, 0, 0xe7];

  factory InitialSettlingState.fromFrame(List<int> frame) {
    if (frame.length != 11 ||
        frame.any((b) => b < 0 || b > 255) ||
        frame[0] != 255 ||
        frame[1] != 170 ||
        frame[2] != 0x3e ||
        frame[3] != 6 ||
        frame[4] != 1 ||
        frame[5] > 1 ||
        (frame.take(10).fold<int>(0, (a, b) => a + b) & 255) != frame.last) {
      throw const FormatException('Invalid initial settling status');
    }
    final remaining =
        ByteData.sublistView(Uint8List.fromList(frame)).getUint32(6);
    if (remaining > 3600 || (frame[5] == 1 && remaining == 0)) {
      throw const FormatException('Invalid initial settling progress');
    }
    return InitialSettlingState(frame[5] == 1, remaining);
  }
}
