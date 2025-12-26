import 'package:airspothealth/core/models/device_data_type.dart';

/// Represents the current sensor error state for a device
class SensorErrorState {
  /// The error code from the device (byte 4 when CO2 = 0xFFFF)
  final int errorCode;

  /// Number of recovery attempts made (byte 5 when CO2 = 0xFFFF)
  final int recoveryAttempts;

  /// When the error was first detected
  final DateTime timestamp;

  /// Device ID this error belongs to
  final String deviceId;

  const SensorErrorState({
    required this.errorCode,
    required this.recoveryAttempts,
    required this.timestamp,
    required this.deviceId,
  });

  /// Whether the sensor is in an error state
  bool get isInError => true;

  /// Whether recovery attempts are exhausted (max is 3)
  bool get isRecoveryExhausted => recoveryAttempts >= 3;

  /// Human-readable error message from the error code
  String get errorMessage =>
      sensorErrorMap[errorCode] ?? 'Unknown Error (code: $errorCode)';

  /// Hex representation of error code
  String get errorCodeHex =>
      '0x${errorCode.toRadixString(16).padLeft(2, '0').toUpperCase()}';

  /// Create a pre-filled description for issue reporting
  String get issueDescription => '''
Sensor Error Detected

Error: $errorMessage
Error Code: $errorCodeHex ($errorCode)
Recovery Attempts: $recoveryAttempts/3${isRecoveryExhausted ? ' (exhausted)' : ''}
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
          recoveryAttempts == other.recoveryAttempts &&
          deviceId == other.deviceId;

  @override
  int get hashCode =>
      errorCode.hashCode ^ recoveryAttempts.hashCode ^ deviceId.hashCode;
}

/// Special CO2 value indicating sensor error (0xFFFF = 65535)
const int sensorErrorCo2Value = 0xFFFF;
