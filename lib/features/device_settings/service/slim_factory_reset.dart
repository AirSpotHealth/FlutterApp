import 'dart:async';

/// A GATT write only delivers the request. Local data must survive until Slim
/// acknowledges that its history erase and settings transaction both succeeded.
class SlimFactoryReset {
  static Future<void> run({
    required Stream<List<int>> responses,
    required Future<bool> Function() send,
    Duration timeout = const Duration(seconds: 120),
  }) async {
    final acknowledged = Completer<void>();
    final subscription = responses.listen((frame) {
      if (frame.length != 6 ||
          frame[0] != 0xff ||
          frame[1] != 0xaa ||
          frame[2] != 0xfa ||
          frame[3] != 1 ||
          (frame.take(5).fold<int>(0, (sum, byte) => sum + byte) & 0xff) !=
              frame.last ||
          acknowledged.isCompleted) {
        return;
      }
      if (frame[4] == 1) {
        acknowledged.complete();
      } else if (frame[4] == 0) {
        acknowledged.completeError(
            StateError('Device could not complete factory reset'));
      }
    }, onError: (Object error, StackTrace stack) {
      if (!acknowledged.isCompleted) acknowledged.completeError(error, stack);
    }, onDone: () {
      if (!acknowledged.isCompleted) {
        acknowledged.completeError(
            StateError('Device disconnected before reset confirmation'));
      }
    });
    // Install the response error handler before send can emit synchronously.
    final result = Future.wait<void>([
      acknowledged.future,
      Future<void>(() async {
        if (!await send()) {
          throw StateError('Could not send factory reset request');
        }
      }),
    ], eagerError: true);
    try {
      await result.timeout(timeout);
    } finally {
      await subscription.cancel();
      if (!acknowledged.isCompleted) acknowledged.complete();
    }
  }
}
