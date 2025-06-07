import 'dart:typed_data';

/// Factory test BLE command types
enum FactoryTestCommandType {
  enterFactoryMode,
  startAutomaticTests,
  endFactoryTest,
  displayScreenTest,
  buzzerTest,
  vibrationTest,
  getChargeStatus,
  getButtonPressCount,
  resetButtonCounter,
}

/// Factory test BLE command with timeout and retry configuration
class FactoryTestCommand {
  final FactoryTestCommandType type;
  final Uint8List command;
  final Duration timeout;
  final int maxRetries;
  final Map<String, dynamic>? parameters;

  FactoryTestCommand({
    required this.type,
    required this.command,
    this.timeout = const Duration(seconds: 10),
    this.maxRetries = 3,
    this.parameters,
  });
}

/// Factory test command response
class FactoryTestResponse {
  final FactoryTestCommandType commandType;
  final bool success;
  final Map<String, dynamic> data;
  final String? error;
  final DateTime timestamp;

  FactoryTestResponse({
    required this.commandType,
    required this.success,
    required this.data,
    this.error,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Screen test types for display testing
enum ScreenTestType {
  edge(0),
  black(1),
  white(2),
  normal(3);

  const ScreenTestType(this.value);
  final int value;
}

/// Charge status from device
class ChargeStatus {
  final bool isCharging;
  final bool isDisconnected;
  final String description;

  ChargeStatus({
    required this.isCharging,
    required this.isDisconnected,
    required this.description,
  });

  factory ChargeStatus.fromByte(int statusByte) {
    switch (statusByte) {
      case 0:
        return ChargeStatus(
          isCharging: false,
          isDisconnected: true,
          description: 'Disconnected',
        );
      case 1:
        return ChargeStatus(
          isCharging: true,
          isDisconnected: false,
          description: 'Charging',
        );
      case 2:
        return ChargeStatus(
          isCharging: false,
          isDisconnected: false,
          description: 'Connected but not charging',
        );
      default:
        return ChargeStatus(
          isCharging: false,
          isDisconnected: true,
          description: 'Unknown status',
        );
    }
  }
}

/// Button press count from device
class ButtonPressCount {
  final int count;
  final DateTime timestamp;

  ButtonPressCount({
    required this.count,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Factory test response command parser
class FactoryTestResponseParser {
  /// Parse factory test automatic test results
  static Map<String, dynamic> parseAutomaticTestResult(List<int> data) {
    if (data.length < 5) return {'error': 'Invalid response length'};

    final testType = data[4];
    final result = data.length > 5 ? data[5] : 0;

    switch (testType) {
      case 1: // Sensor test
        if (data.length >= 8) {
          final co2Value = (data[6] << 8) | data[7];
          return {
            'testName': 'Sensor Test',
            'status': result == 1 ? 'Pass' : 'Fail',
            'comment': result == 1 ? '${co2Value}ppm' : 'Sensor test failed',
            'value': co2Value,
          };
        }
        return {
          'testName': 'Sensor Test',
          'status': result == 1 ? 'Pass' : 'Fail',
          'comment': result == 1 ? 'Sensor OK' : 'Sensor test failed',
        };

      case 2: // Battery voltage test

        if (data.length >= 8) {
          final voltage = (data[6] << 8) | data[7];
          return {
            'testName': 'Battery Voltage Test',
            'status': result == 1 ? 'Pass' : 'Fail',
            'comment': '${voltage}mV',
            'value': voltage,
          };
        }
        return {
          'testName': 'Battery Voltage Test',
          'status': result == 1 ? 'Pass' : 'Fail',
          'comment': result == 1 ? 'Battery OK' : 'Battery test failed',
        };

      case 3: // Memory test

        return {
          'testName': 'Memory Test',
          'status': result == 0 ? 'Pass' : 'Fail',
          'comment': result == 0 ? 'Memory OK' : 'Memory test failed',
          'value': result == 1
              ? 'Erase failed'
              : result == 2
                  ? 'Write failed'
                  : result == 3
                      ? 'Read failed'
                      : null,
        };

      case 4: // LF Crystal test
        if (data.length >= 8) {
          final frequency = ((data[6] << 8) | data[7]) / 1000.0;
          return {
            'testName': 'LF Crystal Test',
            'status': result == 1 ? 'Pass' : 'Fail',
            'comment': '${frequency.toStringAsFixed(3)}KHz',
            'value': frequency,
          };
        }
        return {
          'testName': 'LF Crystal Test',
          'status': result == 1 ? 'Pass' : 'Fail',
          'comment': result == 1 ? 'Crystal OK' : 'Crystal test failed',
        };

      case 5: // LCD Controller test
        return {
          'testName': 'LCD Controller Test',
          'status': result == 1 ? 'Pass' : 'Fail',
          'comment': result == 1 ? 'LCD OK' : 'LCD test failed',
        };

      default:
        return {
          'testName': 'Unknown Test',
          'status': 'Fail',
          'comment': 'Unknown test type: $testType',
        };
    }
  }

  /// Parse charge status response
  static ChargeStatus parseChargeStatus(List<int> data) {
    if (data.length < 5) {
      return ChargeStatus(
        isCharging: false,
        isDisconnected: true,
        description: 'Invalid response',
      );
    }

    return ChargeStatus.fromByte(data[4]);
  }

  /// Parse button press count response
  static ButtonPressCount parseButtonPressCount(List<int> data) {
    if (data.length < 5) {
      return ButtonPressCount(count: 0);
    }

    return ButtonPressCount(count: data[4]);
  }

  /// Parse generic success/failure response
  static bool parseGenericResponse(List<int> data) {
    if (data.length < 5) return false;
    return data[4] == 1;
  }
}
