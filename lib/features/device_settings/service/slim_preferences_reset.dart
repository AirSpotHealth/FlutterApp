import 'dart:async';

/// An explicit command that never erases calibration or saved readings.
class SlimPreferencesReset {
  static const command = [255, 170, 0x3d, 0, 230];
  static Future<void> run(
      {required Stream<List<int>> responses,
      required Future<bool> Function() send,
      Duration timeout = const Duration(seconds: 15)}) async {
    final ack = Completer<void>();
    final subscription = responses.listen((f) {
      if (f.length != 7 ||
          f[0] != 255 ||
          f[1] != 170 ||
          f[2] != 0x3d ||
          f[3] != 2 ||
          (f.take(6).fold<int>(0, (a, b) => a + b) & 255) != f[6] ||
          ack.isCompleted) {
        return;
      }
      if (f[4] == 0 && f[5] == 0) {
        ack.complete();
      } else {
        ack.completeError(StateError(
            'Device could not reset preferences. Calibration was not erased.'));
      }
    }, onError: (Object e, StackTrace st) {
      if (!ack.isCompleted) ack.completeError(e, st);
    }, onDone: () {
      if (!ack.isCompleted) {
        ack.completeError(StateError(
            'Reset was not confirmed. Reconnect and check settings.'));
      }
    });
    final result = Future.wait<void>([
      ack.future,
      Future<void>(() async {
        if (!await send()) throw StateError('Could not send preferences reset');
      })
    ], eagerError: true);
    try {
      await result.timeout(timeout);
    } finally {
      await subscription.cancel();
      if (!ack.isCompleted) ack.complete();
    }
  }
}
