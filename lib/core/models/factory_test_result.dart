import 'package:isar/isar.dart';

part 'factory_test_result.g.dart';

@Collection(ignore: {'copyWith'})
class FactoryTestResult {
  @Id()
  final int id;

  /// Device MAC address/ID
  final String deviceId;

  /// When the test was completed
  final DateTime completedAt;

  /// Overall test status
  final String status; // 'PASS' or 'FAIL'

  /// Person who tested the device
  final String testedBy;

  /// Optional comment about the test
  final String? comment;

  /// Device variant/sensor type
  final int sensorVariant;

  /// Device type
  final String deviceType;

  /// Automatic test results as JSON string
  final String automaticTestsJson;

  /// Manual test results as JSON string
  final String manualTestsJson;

  /// Total number of tests
  final int totalTests;

  /// Number of passed tests
  final int passedTests;

  FactoryTestResult({
    required this.id,
    required this.deviceId,
    required this.completedAt,
    required this.status,
    required this.testedBy,
    this.comment,
    required this.sensorVariant,
    required this.deviceType,
    required this.automaticTestsJson,
    required this.manualTestsJson,
    required this.totalTests,
    required this.passedTests,
  });

  FactoryTestResult copyWith({
    int? id,
    String? deviceId,
    DateTime? completedAt,
    String? status,
    String? testedBy,
    String? comment,
    int? sensorVariant,
    String? deviceType,
    String? automaticTestsJson,
    String? manualTestsJson,
    int? totalTests,
    int? passedTests,
  }) {
    return FactoryTestResult(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      testedBy: testedBy ?? this.testedBy,
      comment: comment ?? this.comment,
      sensorVariant: sensorVariant ?? this.sensorVariant,
      deviceType: deviceType ?? this.deviceType,
      automaticTestsJson: automaticTestsJson ?? this.automaticTestsJson,
      manualTestsJson: manualTestsJson ?? this.manualTestsJson,
      totalTests: totalTests ?? this.totalTests,
      passedTests: passedTests ?? this.passedTests,
    );
  }

  /// Get device display name without prefix
  String get displayDeviceId => deviceId.replaceFirst('AirSpot-', '');

  /// Check if all tests passed
  bool get allTestsPassed => passedTests == totalTests;

  /// Get pass rate as percentage
  double get passRate => totalTests > 0 ? (passedTests / totalTests) * 100 : 0;

  @override
  String toString() {
    return 'FactoryTestResult(deviceId: $deviceId, status: $status, testedBy: $testedBy, totalTests: $totalTests, passedTests: $passedTests)';
  }
}
