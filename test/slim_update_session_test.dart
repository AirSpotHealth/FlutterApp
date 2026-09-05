import 'dart:async';
import 'package:airspothealth/features/device_settings/service/slim_update_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('success waits for app communication to be restored', () async {
    final restored = Completer<void>();
    final events = <String>[];
    var finished = false;
    final result = SlimUpdateSession.run(
      suspend: () async {
        events.add('suspend');
      },
      updateAndVerify: () async {
        events.add('verified');
        return true;
      },
      restore: () async {
        events.add('restore');
        await restored.future;
      },
    ).then((value) {
      finished = true;
      return value;
    });
    await Future<void>.delayed(Duration.zero);
    expect(events, ['suspend', 'verified', 'restore']);
    expect(finished, false);
    restored.complete();
    expect(await result, true);
  });
  for (final phase in ['suspend', 'upload', 'verification']) {
    test('$phase failure always restores normal BLE ownership', () async {
      var restored = false;
      await expectLater(
          SlimUpdateSession.run<void>(
            suspend: () async {
              if (phase == 'suspend') throw StateError(phase);
            },
            updateAndVerify: () async {
              throw StateError(phase);
            },
            restore: () async {
              restored = true;
            },
          ),
          throwsStateError);
      expect(restored, true);
    });
  }
  test('restore failure prevents success', () async {
    await expectLater(
        SlimUpdateSession.run(
          suspend: () async {},
          updateAndVerify: () async => true,
          restore: () async {
            throw StateError('reconnect');
          },
        ),
        throwsStateError);
  });
  test('recovery failure preserves the original upload error', () async {
    final original = StateError('upload rejected');
    await expectLater(
        SlimUpdateSession.run<void>(
          suspend: () async {},
          updateAndVerify: () async {
            throw original;
          },
          restore: () async {
            throw StateError('reconnect');
          },
        ),
        throwsA(same(original)));
  });
}
