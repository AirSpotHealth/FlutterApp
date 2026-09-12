import 'dart:async';
import 'package:airspothealth/features/device_settings/service/slim_factory_reset.dart';
import 'package:flutter_test/flutter_test.dart';
import 'slim_test_helpers.dart';

void main() {
  test('waits for successful ACK before completing and releases subscription',
      () async {
    final responses = StreamController<List<int>>.broadcast(sync: true);
    var complete = false;
    final result = SlimFactoryReset.run(
        responses: responses.stream,
        send: () async => true).then((_) => complete = true);
    await Future<void>.delayed(Duration.zero);
    expect(complete, false);
    responses.add(frame(0xfa, [1]));
    await result;
    expect(complete, true);
    expect(responses.hasListener, false);
    await responses.close();
  });
  for (final outcome in [
    'rejected',
    'send-false',
    'send-error',
    'stream-error',
    'closed'
  ]) {
    test('$outcome fails and releases subscription', () async {
      final responses = StreamController<List<int>>.broadcast(sync: true);
      final result = SlimFactoryReset.run(
          responses: responses.stream,
          send: () async {
            switch (outcome) {
              case 'rejected':
                responses.add(frame(0xfa, [0]));
              case 'send-false':
                return false;
              case 'send-error':
                throw StateError('write failed');
              case 'stream-error':
                responses.addError(StateError('Bluetooth off'));
              case 'closed':
                await responses.close();
            }
            return true;
          });
      await expectLater(result, throwsStateError);
      expect(responses.hasListener, false);
      await responses.close();
    });
  }
  test('malformed, wrong command, unknown status and missing ACK time out',
      () async {
    final responses = StreamController<List<int>>.broadcast(sync: true);
    final result = SlimFactoryReset.run(
        responses: responses.stream,
        timeout: const Duration(milliseconds: 10),
        send: () async {
          responses.add(frame(0xfa, [1])..last = 0);
          responses.add(frame(0x13, [1]));
          responses.add(frame(0xfa, [2]));
          responses.add(frame(0xfa, [1, 1]));
          return true;
        });
    await expectLater(result, throwsA(isA<TimeoutException>()));
    expect(responses.hasListener, false);
    await responses.close();
  });
  test('timeout also bounds a stalled send and releases the subscription',
      () async {
    final responses = StreamController<List<int>>.broadcast(sync: true);
    final stalled = Completer<bool>();
    final result = SlimFactoryReset.run(
        responses: responses.stream,
        timeout: const Duration(milliseconds: 10),
        send: () => stalled.future);
    await expectLater(result, throwsA(isA<TimeoutException>()));
    expect(responses.hasListener, false);
    stalled.complete(false);
    await responses.close();
  });
  test('an ACK cannot turn a failed send into success', () async {
    final responses = StreamController<List<int>>.broadcast(sync: true);
    await expectLater(
        SlimFactoryReset.run(
            responses: responses.stream,
            send: () async {
              responses.add(frame(0xfa, [1]));
              return false;
            }),
        throwsStateError);
    expect(responses.hasListener, false);
    await responses.close();
  });
}
