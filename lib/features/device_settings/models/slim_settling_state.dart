import 'dart:typed_data';

/// Firmware guidance only; completion does not certify sensor accuracy.
class SlimSettlingState {
  const SlimSettlingState(this.stage, this.running, this.generation,
      this.resetTime, this.seconds, this.freshSeconds);
  final int stage, generation, resetTime, seconds, freshSeconds;
  final bool running;
  static const settlingSeconds = 43200;
  static const exposureSeconds = 600;
  bool get needsGuidance => stage != 0 && stage != 4;
  static bool supported(String version) {
    final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(version);
    return m != null && (int.parse(m[1]!) > 0 || int.parse(m[2]!) >= 19);
  }

  static bool nativeTestModesSupported(String version) {
    final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(version);
    return m != null && (int.parse(m[1]!) > 0 || int.parse(m[2]!) >= 22);
  }

  static bool continuousRecoverySupported(String version) {
    final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(version);
    return m != null && (int.parse(m[1]!) > 0 || int.parse(m[2]!) >= 21);
  }

  static List<int> request({int? action, int generation = 0}) {
    final bytes = [255, 170, 0x3c, action == null ? 0 : 5];
    if (action != null) {
      bytes.addAll([
        action,
        (generation >> 24) & 255,
        (generation >> 16) & 255,
        (generation >> 8) & 255,
        generation & 255
      ]);
    }
    return [...bytes, bytes.fold<int>(0, (a, b) => a + b) & 255];
  }

  factory SlimSettlingState.fromFrame(List<int> f) {
    if (f.length != 27 ||
        f[0] != 255 ||
        f[1] != 170 ||
        f[2] != 0x3c ||
        f[3] != 22 ||
        f[4] != 1 ||
        f[5] > 5 ||
        f[6] > 1 ||
        f[7] != 0 ||
        (f.take(26).fold<int>(0, (a, b) => a + b) & 255) != f.last) {
      throw const FormatException('Invalid settling status');
    }
    final d = ByteData.sublistView(Uint8List.fromList(f));
    final error = d.getInt16(8);
    if (error != 0) {
      throw StateError(
          'Device could not confirm guidance progress (error $error). Reconnect and retry.');
    }
    final seconds = d.getUint32(18), fresh = d.getUint32(22);
    if (seconds > settlingSeconds || fresh > exposureSeconds) {
      throw const FormatException('Invalid settling progress');
    }
    return SlimSettlingState(
        f[5], f[6] == 1, d.getUint32(10), d.getUint32(14), seconds, fresh);
  }
}
