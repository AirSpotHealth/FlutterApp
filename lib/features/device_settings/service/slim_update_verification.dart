import 'dart:async';

import 'package:airspothealth/core/services/ble_device_communicator.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';

/// Only new, complete NUS notifications count as post-update evidence.
class SlimUpdateVerification {
  SlimUpdateVerification(this.expectedVersion);
  final String expectedVersion;
  String? version;
  bool hasLiveReading = false;
  bool get complete => version == expectedVersion && hasLiveReading;

  void accept(List<int> frame) {
    if (frame.length < 5 ||
        frame[0] != 0xff ||
        frame[1] != 0xaa ||
        frame.length != frame[3] + 5 ||
        (frame.take(frame.length - 1).fold<int>(0, (a, b) => a + b) & 0xff) !=
            frame.last) {
      return;
    }
    if (frame[2] == 0x13) {
      version = String.fromCharCodes(frame.sublist(4, frame.length - 1));
    } else if (frame[2] == 0x01 && frame[3] == 10) {
      final co2 = (frame[8] << 8) | frame[9];
      hasLiveReading = co2 > 0 && co2 != 0xffff;
    }
  }

  static Future<void> verify(
      BleDeviceCommunicator communicator, String version) async {
    if (!await communicator.initialize(duringUpdate: true)) {
      throw StateError('Could not rediscover the device after update');
    }
    final evidence = SlimUpdateVerification(version);
    final subscription = communicator.dataStream.listen(evidence.accept);
    try {
      final deadline = DateTime.now().add(const Duration(seconds: 150));
      do {
        await communicator.sendCommand(DeviceCmdUtils.getFirmVersion(),
            duringUpdate: true);
        await communicator.sendCommand(DeviceCmdUtils.getCO2(),
            duringUpdate: true);
        await Future<void>.delayed(const Duration(seconds: 2));
        if (evidence.complete && communicator.device.isConnected) return;
      } while (DateTime.now().isBefore(deadline));
      throw StateError('Post-update check failed: expected $version, '
          'received ${evidence.version ?? "no version"}; '
          'valid live reading: ${evidence.hasLiveReading}');
    } finally {
      await subscription.cancel();
    }
  }
}
