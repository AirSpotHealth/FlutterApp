import 'package:airspothealth/core/models/device_data_type.dart';

/// Represents the current sensor error state for a device
class SensorErrorState {
  /// The error code from the device (byte 4 when CO2 = 0xFFFF)
  final int errorCode;
  final bool isSlim;

  /// Number of recovery attempts made (byte 5 when CO2 = 0xFFFF)
  final int recoveryAttempts;

  /// When the error was first detected
  final DateTime timestamp;

  /// Device ID this error belongs to
  final String deviceId;

  const SensorErrorState({
    required this.errorCode,
    this.isSlim = false,
    required this.recoveryAttempts,
    required this.timestamp,
    required this.deviceId,
  });

  /// Whether the sensor is in an error state
  bool get isInError => !isPreparing;

  /// Slim uses 0x40 for conditioning/startup; measurements remain unavailable.
  bool get isPreparing => isSlim && errorCode == 0x40;

  /// Whether recovery attempts are exhausted (max is 3)
  bool get isRecoveryExhausted => !isSlim && recoveryAttempts >= 3;

  /// Human-readable error message from the error code
  String get errorMessage => isSlim && errorCode == 0
      ? 'Sensor reading unavailable'
      : sensorErrorMap[errorCode] ?? 'Unknown Error (code: $errorCode)';

  /// Guidance does not assume live recovery telemetry or erase calibration.
  String get slimRecoveryGuidance =>
      '$errorMessage. Updated Slim firmware retries sensor recovery automatically. '
      'If the error remains after a few minutes, choose Restart device in device settings. '
      'Restarting keeps your readings and calibration. '
      'If the error returns, use Report Issue for help with recovery. '
      'Do not erase sensor calibration or open the device to fix this error.';

  /// Hex representation of error code
  String get errorCodeHex =>
      '0x${errorCode.toRadixString(16).padLeft(2, '0').toUpperCase()}';

  /// Create a pre-filled description for issue reporting
  String get issueDescription => '''
Sensor Error Detected

Error: $errorMessage
Error Code: $errorCodeHex ($errorCode)
${isSlim ? 'Recovery: automatic recovery status is unavailable; inspect device diagnostics.' : 'Recovery Attempts: $recoveryAttempts/3${isRecoveryExhausted ? ' (exhausted)' : ''}'}
Detected At: ${timestamp.toIso8601String()}

The device CO2 sensor has encountered an error. Please review the device diagnostics attached below.
''';

  @override
  String toString() =>
      'SensorErrorState(errorCode: $errorCode, recoveryAttempts: $recoveryAttempts, message: $errorMessage)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensorErrorState &&
          runtimeType == other.runtimeType &&
          errorCode == other.errorCode &&
          isSlim == other.isSlim &&
          recoveryAttempts == other.recoveryAttempts &&
          deviceId == other.deviceId;

  @override
  int get hashCode =>
      isSlim.hashCode ^
      errorCode.hashCode ^
      recoveryAttempts.hashCode ^
      deviceId.hashCode;
}

/// Special CO2 value indicating sensor error (0xFFFF = 65535)
const int sensorErrorCo2Value = 0xFFFF;
