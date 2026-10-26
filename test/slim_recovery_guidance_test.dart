import 'package:airspothealth/core/models/sensor_error_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Slim guidance preserves calibration and does not claim live recovery', () {
    final error = SensorErrorState(
      errorCode: 0x43,
      isSlim: true,
      recoveryAttempts: 255,
      timestamp: DateTime(2026),
      deviceId: '81A9DC',
    );
    expect(error.isRecoveryExhausted, isFalse);
    expect(error.slimRecoveryGuidance, contains('Restart device'));
    expect(error.slimRecoveryGuidance, contains('keeps your readings and calibration'));
    expect(error.slimRecoveryGuidance, contains('Report Issue'));
    expect(error.slimRecoveryGuidance, isNot(contains('Reset Sensor')));
  });
}
