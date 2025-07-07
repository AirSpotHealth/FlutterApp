import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Represents the queue status of a device in the factory test system
enum DeviceQueueStatus {
  queued, // Device is waiting to start
  running, // Device is currently running tests (max 4 concurrent)
  readyToSubmit, // Device has finished tests, ready for result submission
  completed, // Device has finished all tests and results submitted
  error, // Device encountered an error
}

/// Represents the overall state of factory testing
enum DeviceFactoryTestPhase {
  connecting,
  enteringFactoryMode,
  reconnecting,
  runningAutomaticTests,
  runningManualTests,
  completed,
  error
}

/// Represents the connection state during factory testing
enum DeviceFactoryTestConnectionState {
  idle,
  connecting,
  connected,
  enteringFactoryMode,
  deviceRestarting,
  reconnecting,
  factoryModeReady,
  disconnected,
  error
}

/// Represents the status of individual tests
enum DeviceTestStatus { notStarted, running, pass, fail }

/// Represents a discovered device during scanning
class FactoryTestDevice {
  final String deviceId;
  final String name;
  final int rssi;
  final BluetoothDevice bluetoothDevice;
  final DeviceTestStatus status;
  final DeviceQueueStatus queueStatus;
  final DateTime? queuedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int queuePosition; // Position in queue (0-based)

  FactoryTestDevice({
    required this.deviceId,
    required this.name,
    required this.rssi,
    required this.bluetoothDevice,
    this.status = DeviceTestStatus.notStarted,
    this.queueStatus = DeviceQueueStatus.queued,
    this.queuedAt,
    this.startedAt,
    this.completedAt,
    this.queuePosition = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FactoryTestDevice &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId &&
          status == other.status &&
          queueStatus == other.queueStatus;

  @override
  int get hashCode => deviceId.hashCode;

  FactoryTestDevice copyWith({
    DeviceTestStatus? status,
    DeviceQueueStatus? queueStatus,
    DateTime? queuedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int? queuePosition,
  }) {
    return FactoryTestDevice(
      deviceId: deviceId,
      name: name,
      rssi: rssi,
      bluetoothDevice: bluetoothDevice,
      status: status ?? this.status,
      queueStatus: queueStatus ?? this.queueStatus,
      queuedAt: queuedAt ?? this.queuedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      queuePosition: queuePosition ?? this.queuePosition,
    );
  }

  /// Get display name without AirSpot prefix
  String get displayName => name.replaceFirst('AirSpot-', '');

  /// Check if device is currently running tests
  bool get isRunning => queueStatus == DeviceQueueStatus.running;

  /// Check if device is waiting in queue
  bool get isQueued => queueStatus == DeviceQueueStatus.queued;

  /// Check if device is ready to submit results
  bool get isReadyToSubmit => queueStatus == DeviceQueueStatus.readyToSubmit;

  /// Check if device has completed testing and submission
  bool get isCompleted => queueStatus == DeviceQueueStatus.completed;

  /// Check if device has an error
  bool get hasError => queueStatus == DeviceQueueStatus.error;

  /// Get time elapsed since device started testing
  Duration? get runningTime {
    if (startedAt == null) return null;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  /// Get estimated queue wait time (rough calculation)
  String get estimatedWaitTime {
    if (!isQueued) return '';
    if (queuePosition == 0) return 'Starting soon';
    if (queuePosition <= 3) return '< 5 minutes';
    return '${(queuePosition * 2)} - ${(queuePosition * 3)} minutes';
  }
}

/// Represents the result of an individual test
class TestResult {
  final String testName;
  final DeviceTestStatus status;
  final String? comment;
  final dynamic value;
  final DateTime? timestamp;
  final bool deviceResponseReceived;

  TestResult({
    required this.testName,
    required this.status,
    this.comment,
    this.value,
    this.timestamp,
    this.deviceResponseReceived = false,
  });

  TestResult copyWith({
    String? testName,
    DeviceTestStatus? status,
    String? comment,
    dynamic value,
    DateTime? timestamp,
    bool? deviceResponseReceived,
  }) {
    return TestResult(
      testName: testName ?? this.testName,
      status: status ?? this.status,
      comment: comment ?? this.comment,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
      deviceResponseReceived:
          deviceResponseReceived ?? this.deviceResponseReceived,
    );
  }
}

/// Represents the state of automatic tests
class AutomaticTestsState {
  final List<TestResult> tests;
  final bool isRunning;
  final bool isComplete;
  final String? error;

  AutomaticTestsState({
    required this.tests,
    this.isRunning = false,
    this.isComplete = false,
    this.error,
  });

  AutomaticTestsState copyWith({
    List<TestResult>? tests,
    bool? isRunning,
    bool? isComplete,
    String? error,
  }) {
    return AutomaticTestsState(
      tests: tests ?? this.tests,
      isRunning: isRunning ?? this.isRunning,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
    );
  }

  int get passCount =>
      tests.where((test) => test.status == DeviceTestStatus.pass).length;
  int get totalCount => tests.length;
  double get overallProgress => totalCount > 0 ? passCount / totalCount : 0.0;
}

/// Represents the state of manual tests
class ManualTestsState {
  final List<TestResult> tests;
  final Map<String, bool> userConfirmations;
  final bool isComplete;
  final String? error;

  ManualTestsState({
    required this.tests,
    required this.userConfirmations,
    this.isComplete = false,
    this.error,
  });

  ManualTestsState copyWith({
    List<TestResult>? tests,
    Map<String, bool>? userConfirmations,
    bool? isComplete,
    String? error,
  }) {
    return ManualTestsState(
      tests: tests ?? this.tests,
      userConfirmations: userConfirmations ?? this.userConfirmations,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
    );
  }

  int get passCount =>
      tests.where((test) => test.status == DeviceTestStatus.pass).length;
  int get totalCount => tests.length;
  bool get allTestsComplete =>
      tests.every((test) => test.status != DeviceTestStatus.notStarted);
}

/// Represents the overall factory test state
class DeviceFactoryTestState {
  final DeviceFactoryTestPhase phase;
  final DeviceFactoryTestConnectionState connectionState;
  final int? selectedDeviceVariant;
  final AutomaticTestsState automaticTests;
  final ManualTestsState manualTests;
  final String? error;
  final FactoryTestDevice selectedDevice;

  DeviceFactoryTestState({
    required this.phase,
    required this.connectionState,
    this.selectedDeviceVariant,
    required this.automaticTests,
    required this.manualTests,
    this.error,
    required this.selectedDevice,
  });

  static DeviceFactoryTestState emptyState(
    FactoryTestDevice device,
  ) {
    return DeviceFactoryTestState(
      phase: DeviceFactoryTestPhase.connecting,
      connectionState: DeviceFactoryTestConnectionState.idle,
      automaticTests: AutomaticTestsState(tests: initialAutomaticTests),
      manualTests:
          ManualTestsState(tests: initialManualTests, userConfirmations: {}),
      error: null,
      selectedDevice: device,
    );
  }

  DeviceFactoryTestState copyWith({
    DeviceFactoryTestPhase? phase,
    DeviceFactoryTestConnectionState? connectionState,
    int? selectedDeviceVariant,
    AutomaticTestsState? automaticTests,
    ManualTestsState? manualTests,
    String? error,
  }) {
    return DeviceFactoryTestState(
      phase: phase ?? this.phase,
      connectionState: connectionState ?? this.connectionState,
      selectedDevice: selectedDevice,
      selectedDeviceVariant:
          selectedDeviceVariant ?? this.selectedDeviceVariant,
      automaticTests: automaticTests ?? this.automaticTests,
      manualTests: manualTests ?? this.manualTests,
      error: error ?? this.error,
    );
  }

  bool get canStartTests =>
      phase == DeviceFactoryTestPhase.runningAutomaticTests &&
      connectionState == DeviceFactoryTestConnectionState.factoryModeReady;

  bool get canProceedToManualTests =>
      automaticTests.isComplete && automaticTests.error == null;

  bool get isTestingComplete =>
      automaticTests.isComplete && manualTests.isComplete;

  bool get isOverallSuccess =>
      automaticTests.passCount + manualTests.passCount ==
      automaticTests.totalCount + manualTests.totalCount;
}

final initialAutomaticTests = [
  TestResult(testName: 'Sensor Test', status: DeviceTestStatus.notStarted),
  TestResult(testName: 'Memory Test', status: DeviceTestStatus.notStarted),
  TestResult(
      testName: 'Battery Voltage Test', status: DeviceTestStatus.notStarted),
  TestResult(testName: 'LF Crystal Test', status: DeviceTestStatus.notStarted),
  TestResult(
      testName: 'LCD Controller Test', status: DeviceTestStatus.notStarted),
];

final initialManualTests = [
  TestResult(testName: 'Charge Test', status: DeviceTestStatus.notStarted),
  TestResult(testName: 'Screen Edge Test', status: DeviceTestStatus.notStarted),
  TestResult(
      testName: 'Screen Black Test', status: DeviceTestStatus.notStarted),
  TestResult(
      testName: 'Screen White Test', status: DeviceTestStatus.notStarted),
  TestResult(testName: 'Button Test', status: DeviceTestStatus.notStarted),
  TestResult(testName: 'Buzzer Test', status: DeviceTestStatus.notStarted),
  TestResult(testName: 'Vibration Test', status: DeviceTestStatus.notStarted),
  TestResult(testName: 'Case Check', status: DeviceTestStatus.notStarted),
  TestResult(testName: 'LCD with OCA?', status: DeviceTestStatus.notStarted),
];
