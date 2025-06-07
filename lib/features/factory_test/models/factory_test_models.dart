import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Represents the overall state of factory testing
enum FactoryTestPhase {
  deviceSelection,
  connecting,
  enteringFactoryMode,
  reconnecting,
  runningAutomaticTests,
  runningManualTests,
  completed,
  error
}

/// Represents the connection state during factory testing
enum FactoryTestConnectionState {
  idle,
  scanning,
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
enum TestStatus { notStarted, running, pass, fail }

/// Represents a discovered device during scanning
class FactoryTestDevice {
  final String deviceId;
  final String name;
  final int rssi;
  final BluetoothDevice bluetoothDevice;

  FactoryTestDevice({
    required this.deviceId,
    required this.name,
    required this.rssi,
    required this.bluetoothDevice,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FactoryTestDevice &&
          runtimeType == other.runtimeType &&
          deviceId == other.deviceId;

  @override
  int get hashCode => deviceId.hashCode;
}

/// Represents the result of an individual test
class TestResult {
  final String testName;
  final TestStatus status;
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
    TestStatus? status,
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
      tests.where((test) => test.status == TestStatus.pass).length;
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
      tests.where((test) => test.status == TestStatus.pass).length;
  int get totalCount => tests.length;
  bool get allTestsComplete =>
      tests.every((test) => test.status != TestStatus.notStarted);
}

/// Represents the overall factory test state
class FactoryTestState {
  final FactoryTestPhase phase;
  final FactoryTestConnectionState connectionState;
  final String? selectedDeviceId;
  final List<FactoryTestDevice> availableDevices;
  final AutomaticTestsState automaticTests;
  final ManualTestsState manualTests;
  final String? error;
  final bool isScanning;

  FactoryTestState({
    required this.phase,
    required this.connectionState,
    this.selectedDeviceId,
    required this.availableDevices,
    required this.automaticTests,
    required this.manualTests,
    this.error,
    this.isScanning = false,
  });

  FactoryTestState copyWith({
    FactoryTestPhase? phase,
    FactoryTestConnectionState? connectionState,
    String? selectedDeviceId,
    List<FactoryTestDevice>? availableDevices,
    AutomaticTestsState? automaticTests,
    ManualTestsState? manualTests,
    String? error,
    bool? isScanning,
  }) {
    return FactoryTestState(
      phase: phase ?? this.phase,
      connectionState: connectionState ?? this.connectionState,
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
      availableDevices: availableDevices ?? this.availableDevices,
      automaticTests: automaticTests ?? this.automaticTests,
      manualTests: manualTests ?? this.manualTests,
      error: error ?? this.error,
      isScanning: isScanning ?? this.isScanning,
    );
  }

  bool get canStartTests =>
      phase == FactoryTestPhase.runningAutomaticTests &&
      connectionState == FactoryTestConnectionState.factoryModeReady;

  bool get canProceedToManualTests =>
      automaticTests.isComplete && automaticTests.error == null;

  bool get isTestingComplete =>
      automaticTests.isComplete && manualTests.isComplete;
}
