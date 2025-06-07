import 'dart:async';

import 'package:airspothealth/core/services/ble_service.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_commands.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final factoryTestProvider =
    NotifierProvider.autoDispose<FactoryTestNotifier, FactoryTestState>(
  FactoryTestNotifier.new,
);

class FactoryTestNotifier extends AutoDisposeNotifier<FactoryTestState> {
  final BLEService _bleService = BLEService.instance;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;

  StreamSubscription<List<BluetoothDevice>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;

  Timer? _reconnectionTimer;
  Timer? _commandTimeoutTimer;
  Timer? _automaticTestTimeoutTimer;
  Timer? _scanTimeoutTimer;

  // Command queue for reliable execution
  final List<FactoryTestCommand> _commandQueue = [];
  bool _isProcessingCommand = false;

  @override
  FactoryTestState build() {
    ref.onDispose(() {
      _cleanup();
    });

    return FactoryTestState(
      phase: FactoryTestPhase.deviceSelection,
      connectionState: FactoryTestConnectionState.idle,
      availableDevices: [],
      automaticTests:
          AutomaticTestsState(tests: _createInitialAutomaticTests()),
      manualTests: ManualTestsState(
        tests: _createInitialManualTests(),
        userConfirmations: {},
      ),
    );
  }

  /// Initialize automatic tests list
  List<TestResult> _createInitialAutomaticTests() {
    return [
      TestResult(testName: 'Sensor Test', status: TestStatus.notStarted),
      TestResult(testName: 'Memory Test', status: TestStatus.notStarted),
      TestResult(
          testName: 'Battery Voltage Test', status: TestStatus.notStarted),
      TestResult(testName: 'LF Crystal Test', status: TestStatus.notStarted),
      TestResult(
          testName: 'LCD Controller Test', status: TestStatus.notStarted),
    ];
  }

  /// Initialize manual tests list
  List<TestResult> _createInitialManualTests() {
    return [
      TestResult(testName: 'Charge Test', status: TestStatus.notStarted),
      TestResult(testName: 'Screen Edge Test', status: TestStatus.notStarted),
      TestResult(testName: 'Screen Black Test', status: TestStatus.notStarted),
      TestResult(testName: 'Screen White Test', status: TestStatus.notStarted),
      TestResult(testName: 'Button Test', status: TestStatus.notStarted),
      TestResult(testName: 'Buzzer Test', status: TestStatus.notStarted),
      TestResult(testName: 'Vibration Test', status: TestStatus.notStarted),
      TestResult(testName: 'Case Check', status: TestStatus.notStarted),
    ];
  }

  /// Start device scanning
  void startScanning() {
    if (state.isScanning) return;

    // Clear any existing scan timeout
    _scanTimeoutTimer?.cancel();

    state = state.copyWith(
      isScanning: true,
      connectionState: FactoryTestConnectionState.scanning,
      error: null, // Clear any previous errors
    );

    _bleService.startScan();

    // Use scan results with ScanResult to get RSSI
    FlutterBluePlus.scanResults.listen(
      (scanResults) {
        final factoryTestDevices = scanResults
            .where((scanResult) =>
                scanResult.device.advName.startsWith('AirSpot-'))
            .map((scanResult) => FactoryTestDevice(
                  deviceId: scanResult.device.remoteId.str,
                  name: scanResult.device.advName,
                  rssi: scanResult.rssi,
                  bluetoothDevice: scanResult.device,
                ))
            .toList();

        // Sort by RSSI (strongest signal first)
        factoryTestDevices.sort((a, b) => b.rssi.compareTo(a.rssi));

        state = state.copyWith(availableDevices: factoryTestDevices);
      },
      onError: (error) {
        debugPrint('Scan error: $error');
        state = state.copyWith(
          isScanning: false,
          error: 'Scan error: $error',
        );
        _scanTimeoutTimer?.cancel();
      },
    );

    // Auto-stop scanning after 30 seconds to prevent forever scanning
    _scanTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (state.isScanning) {
        debugPrint('Auto-stopping scan after 30 seconds timeout');
        stopScanning();
      }
    });
  }

  /// Stop device scanning
  void stopScanning() {
    if (!state.isScanning) return;

    _bleService.stopScan();
    _scanSubscription?.cancel();
    _scanTimeoutTimer?.cancel();

    state = state.copyWith(
      isScanning: false,
      connectionState: FactoryTestConnectionState.idle,
    );
  }

  /// Connect to selected device and start factory test flow
  Future<void> connectToDeviceAndStartFactoryTest(String deviceId) async {
    final device = state.availableDevices.firstWhere(
        (d) => d.deviceId == deviceId,
        orElse: () => throw 'Device not found');

    stopScanning();

    state = state.copyWith(
      selectedDeviceId: deviceId,
      phase: FactoryTestPhase.connecting,
      connectionState: FactoryTestConnectionState.connecting,
      error: null,
    );

    try {
      await _connectToDevice(device.bluetoothDevice);
      // Don't call _enterFactoryMode here - it will be called from _onDeviceConnected
    } catch (error) {
      debugPrint('Connection error: $error');
      state = state.copyWith(
        phase: FactoryTestPhase.error,
        connectionState: FactoryTestConnectionState.error,
        error: 'Connection failed: $error',
      );
    }
  }

  /// Connect to the Bluetooth device
  Future<void> _connectToDevice(BluetoothDevice device) async {
    _connectedDevice = device;

    // Listen to connection state changes
    _connectionSubscription = device.connectionState.listen(
      (connectionState) {
        debugPrint('Connection state: $connectionState');

        if (connectionState == BluetoothConnectionState.connected) {
          _onDeviceConnected();
        } else if (connectionState == BluetoothConnectionState.disconnected) {
          _onDeviceDisconnected();
        }
      },
    );

    // Connect to device
    await _bleService.connect(device);
  }

  /// Handle successful device connection
  Future<void> _onDeviceConnected() async {
    try {
      state = state.copyWith(
        connectionState: FactoryTestConnectionState.connected,
      );

      // Discover services and characteristics
      final services = await _connectedDevice!.discoverServices();

      final service = services.firstWhere(
        (s) => s.uuid.toString().toUpperCase() == Constants.serviceUuid,
        orElse: () => throw 'Service not found',
      );

      _writeCharacteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString().toUpperCase() == Constants.writeUuid,
        orElse: () => throw 'Write characteristic not found',
      );

      _notifyCharacteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString().toUpperCase() == Constants.notifyUuid,
        orElse: () => throw 'Notify characteristic not found',
      );

      // Setup notifications
      await _notifyCharacteristic!.setNotifyValue(true);
      _notificationSubscription = _notifyCharacteristic!.onValueReceived.listen(
        _handleNotification,
        onError: (error) {
          debugPrint('Notification error: $error');
        },
      );

      debugPrint('Device connected and characteristics setup complete');

      // If we're in the initial connection phase, proceed to enter factory mode
      if (state.phase == FactoryTestPhase.connecting) {
        await _enterFactoryMode();
      }
    } catch (error) {
      debugPrint('Error setting up device: $error');
      state = state.copyWith(
        phase: FactoryTestPhase.error,
        connectionState: FactoryTestConnectionState.error,
        error: 'Device setup failed: $error',
      );
    }
  }

  /// Handle device disconnection
  void _onDeviceDisconnected() {
    debugPrint('Device disconnected');

    if (state.connectionState ==
        FactoryTestConnectionState.enteringFactoryMode) {
      // Expected disconnection during factory mode entry
      state = state.copyWith(
        connectionState: FactoryTestConnectionState.deviceRestarting,
      );

      // Wait for device restart and try to reconnect
      _startReconnectionProcess();
    } else if (state.phase == FactoryTestPhase.runningAutomaticTests &&
        state.automaticTests.isRunning) {
      // Unexpected disconnection during automatic tests
      debugPrint(
          'Device disconnected during automatic tests - connection lost');
      _clearAutomaticTestTimeout();
      _handleAutomaticTestTimeout(); // Handle as timeout since connection is lost
    } else {
      // Other unexpected disconnection
      state = state.copyWith(
        connectionState: FactoryTestConnectionState.disconnected,
        error: 'Device unexpectedly disconnected',
      );
    }
  }

  /// Start reconnection process after device restart
  void _startReconnectionProcess() {
    state = state.copyWith(
      connectionState: FactoryTestConnectionState.reconnecting,
    );

    // Wait a bit for device to restart
    _reconnectionTimer = Timer(const Duration(seconds: 2), () {
      _attemptReconnection();
    });
  }

  /// Attempt to reconnect to the device
  void _attemptReconnection() async {
    if (_connectedDevice == null) return;

    try {
      debugPrint('Attempting to reconnect...');

      // Try to reconnect
      await _bleService.connect(_connectedDevice!);

      // Wait for connection state to update
      await Future.delayed(const Duration(seconds: 1));

      if (_connectedDevice!.isConnected) {
        debugPrint('Reconnection successful');
        state = state.copyWith(
          connectionState: FactoryTestConnectionState.factoryModeReady,
          phase: FactoryTestPhase.runningAutomaticTests,
        );

        // Start automatic tests
        await _startAutomaticTests();
      } else {
        throw 'Reconnection failed';
      }
    } catch (error) {
      debugPrint('Reconnection error: $error');

      // Retry reconnection up to 3 times
      state = state.copyWith(
        error: 'Reconnection attempt failed: $error',
      );

      // TODO: Add retry logic with exponential backoff
    }
  }

  /// Enter factory test mode
  Future<void> _enterFactoryMode() async {
    state = state.copyWith(
      phase: FactoryTestPhase.enteringFactoryMode,
      connectionState: FactoryTestConnectionState.enteringFactoryMode,
    );

    try {
      final command = FactoryTestCommand(
        type: FactoryTestCommandType.enterFactoryMode,
        command: DeviceCmdUtils.enterFactoryTestMode(),
        timeout: const Duration(seconds: 5),
      );

      await _executeCommand(command);

      debugPrint('Factory mode command sent, waiting for device restart...');
    } catch (error) {
      debugPrint('Error entering factory mode: $error');
      state = state.copyWith(
        phase: FactoryTestPhase.error,
        connectionState: FactoryTestConnectionState.error,
        error: 'Failed to enter factory mode: $error',
      );
    }
  }

  /// Start automatic tests
  Future<void> _startAutomaticTests() async {
    try {
      final command = FactoryTestCommand(
        type: FactoryTestCommandType.startAutomaticTests,
        command: DeviceCmdUtils.startFactoryAutoTests(),
        timeout: const Duration(seconds: 30),
      );

      await _executeCommand(command);

      // Update test state to running
      final updatedTests = state.automaticTests.tests
          .map((test) => test.copyWith(status: TestStatus.running))
          .toList();

      state = state.copyWith(
        automaticTests: state.automaticTests.copyWith(
          tests: updatedTests,
          isRunning: true,
        ),
      );

      // Start timeout timer for automatic tests (1 minute)
      _startAutomaticTestTimeout();

      debugPrint('Automatic tests started');
    } catch (error) {
      debugPrint('Error starting automatic tests: $error');
      state = state.copyWith(
        automaticTests: state.automaticTests.copyWith(
          error: 'Failed to start automatic tests: $error',
        ),
      );
    }
  }

  /// Execute a BLE command with timeout and retry logic
  Future<void> _executeCommand(FactoryTestCommand command) async {
    if (_writeCharacteristic == null) {
      throw 'Write characteristic not available';
    }

    _commandQueue.add(command);

    if (!_isProcessingCommand) {
      await _processCommandQueue();
    }
  }

  /// Process the command queue
  Future<void> _processCommandQueue() async {
    _isProcessingCommand = true;

    while (_commandQueue.isNotEmpty) {
      final command = _commandQueue.removeAt(0);

      int retryCount = 0;
      bool success = false;

      while (retryCount <= command.maxRetries && !success) {
        try {
          await _writeCharacteristic!.write(command.command);
          debugPrint('Command sent: ${command.type}');
          success = true;
        } catch (error) {
          retryCount++;
          debugPrint('Command failed (attempt $retryCount): $error');

          if (retryCount <= command.maxRetries) {
            await Future.delayed(Duration(milliseconds: 500 * retryCount));
          }
        }
      }

      if (!success) {
        throw 'Command ${command.type} failed after ${command.maxRetries} retries';
      }
    }

    _isProcessingCommand = false;
  }

  /// Handle incoming notifications from device
  void _handleNotification(List<int> data) {
    debugPrint(
        'Received notification: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

    if (data.length < 3) return;

    final commandByte = data[2];

    switch (commandByte) {
      case 0xDD: // Automatic test result
        _handleAutomaticTestResult(data);
        break;
      case 0xDA: // Charge status
        _handleChargeStatusResult(data);
        break;
      case 0xD9: // Button press count
        _handleButtonPressResult(data);
        break;
      case 0xDC: // Screen test result
        _handleScreenTestResult(data);
        break;
      case 0xDB: // Buzzer test result
        _handleBuzzerTestResult(data);
        break;
      default:
        debugPrint(
            'Unknown command response: 0x${commandByte.toRadixString(16)}');
        break;
    }
  }

  /// Handle automatic test results
  void _handleAutomaticTestResult(List<int> data) {
    final result = FactoryTestResponseParser.parseAutomaticTestResult(data);
    final testName = result['testName'] as String;

    final updatedTests = state.automaticTests.tests.map((test) {
      if (test.testName == testName) {
        return test.copyWith(
          status:
              result['status'] == 'Pass' ? TestStatus.pass : TestStatus.fail,
          comment: result['comment'] as String?,
          value: result['value'],
          timestamp: DateTime.now(),
          deviceResponseReceived: true,
        );
      }
      return test;
    }).toList();

    final allComplete = updatedTests.every((test) =>
        test.status == TestStatus.pass || test.status == TestStatus.fail);

    state = state.copyWith(
      automaticTests: state.automaticTests.copyWith(
        tests: updatedTests,
        isRunning: !allComplete,
        isComplete: allComplete,
      ),
    );

    // If all automatic tests are complete, clear timeout and move to manual tests
    if (allComplete) {
      _clearAutomaticTestTimeout();
      state = state.copyWith(phase: FactoryTestPhase.runningManualTests);
    }
  }

  /// Handle charge status result
  void _handleChargeStatusResult(List<int> data) {
    final chargeStatus = FactoryTestResponseParser.parseChargeStatus(data);

    final updatedTests = state.manualTests.tests.map((test) {
      if (test.testName == 'Charge Test') {
        return test.copyWith(
          status: chargeStatus.isCharging || chargeStatus.isDisconnected
              ? TestStatus.pass
              : TestStatus.fail,
          comment: chargeStatus.description,
          timestamp: DateTime.now(),
          deviceResponseReceived: true,
        );
      }
      return test;
    }).toList();

    state = state.copyWith(
      manualTests: state.manualTests.copyWith(tests: updatedTests),
    );
  }

  /// Handle button press result
  void _handleButtonPressResult(List<int> data) {
    final buttonCount = FactoryTestResponseParser.parseButtonPressCount(data);

    final updatedTests = state.manualTests.tests.map((test) {
      if (test.testName == 'Button Test') {
        return test.copyWith(
          status: buttonCount.count >= 3 ? TestStatus.pass : TestStatus.fail,
          comment: 'Button pressed ${buttonCount.count} times',
          value: buttonCount.count,
          timestamp: DateTime.now(),
          deviceResponseReceived: true,
        );
      }
      return test;
    }).toList();

    state = state.copyWith(
      manualTests: state.manualTests.copyWith(tests: updatedTests),
    );
  }

  /// Handle screen test result
  void _handleScreenTestResult(List<int> data) {
    final success = FactoryTestResponseParser.parseGenericResponse(data);
    // Screen test success is handled by user confirmation
  }

  /// Handle buzzer test result
  void _handleBuzzerTestResult(List<int> data) {
    final success = FactoryTestResponseParser.parseGenericResponse(data);

    final updatedTests = state.manualTests.tests.map((test) {
      if (test.testName == 'Buzzer Test') {
        return test.copyWith(
          deviceResponseReceived: true,
          timestamp: DateTime.now(),
        );
      }
      return test;
    }).toList();

    state = state.copyWith(
      manualTests: state.manualTests.copyWith(tests: updatedTests),
    );
  }

  // Manual test control methods
  Future<void> startChargeTest() async {
    final command = FactoryTestCommand(
      type: FactoryTestCommandType.getChargeStatus,
      command: DeviceCmdUtils.getChargeStatus(),
    );
    await _executeCommand(command);
  }

  Future<void> startScreenEdgeTest() async {
    final command = FactoryTestCommand(
      type: FactoryTestCommandType.displayScreenTest,
      command: DeviceCmdUtils.displayScreenTest(ScreenTestType.edge.value),
    );
    await _executeCommand(command);
  }

  Future<void> startScreenBlackTest() async {
    final command = FactoryTestCommand(
      type: FactoryTestCommandType.displayScreenTest,
      command: DeviceCmdUtils.displayScreenTest(ScreenTestType.black.value),
    );
    await _executeCommand(command);
  }

  Future<void> startScreenWhiteTest() async {
    final command = FactoryTestCommand(
      type: FactoryTestCommandType.displayScreenTest,
      command: DeviceCmdUtils.displayScreenTest(ScreenTestType.white.value),
    );
    await _executeCommand(command);
  }

  Future<void> returnToNormalScreen() async {
    final command = FactoryTestCommand(
      type: FactoryTestCommandType.displayScreenTest,
      command: DeviceCmdUtils.displayScreenTest(ScreenTestType.normal.value),
    );
    await _executeCommand(command);
  }

  Future<void> startButtonTest() async {
    // Reset button counter first
    final resetCommand = FactoryTestCommand(
      type: FactoryTestCommandType.resetButtonCounter,
      command: DeviceCmdUtils.resetButtonCounter(),
    );
    await _executeCommand(resetCommand);

    // Wait a bit then get button count
    await Future.delayed(const Duration(seconds: 1));

    final getCommand = FactoryTestCommand(
      type: FactoryTestCommandType.getButtonPressCount,
      command: DeviceCmdUtils.getButtonPressCount(),
    );
    await _executeCommand(getCommand);
  }

  Future<void> startBuzzerTest() async {
    final command = FactoryTestCommand(
      type: FactoryTestCommandType.buzzerTest,
      command: DeviceCmdUtils.buzzerTest(3), // 3 beeps
    );
    await _executeCommand(command);
  }

  Future<void> startVibrationTest() async {
    final command = FactoryTestCommand(
      type: FactoryTestCommandType.vibrationTest,
      command: DeviceCmdUtils.openVibration(), // Use existing vibration command
    );
    await _executeCommand(command);

    // Turn off vibration after a delay
    Timer(const Duration(seconds: 2), () async {
      final stopCommand = FactoryTestCommand(
        type: FactoryTestCommandType.vibrationTest,
        command: DeviceCmdUtils.closeVibration(),
      );
      await _executeCommand(stopCommand);
    });
  }

  /// Update user confirmation for manual tests
  void updateUserConfirmation(String testName, bool confirmed) {
    final updatedConfirmations =
        Map<String, bool>.from(state.manualTests.userConfirmations);
    updatedConfirmations[testName] = confirmed;

    // Update test status if user confirmed and device responded
    final updatedTests = state.manualTests.tests.map((test) {
      if (test.testName == testName && confirmed) {
        return test.copyWith(
          status: TestStatus.pass,
          comment: '${test.comment ?? ''} - User confirmed',
        );
      }
      return test;
    }).toList();

    final allComplete = updatedTests.every((test) =>
        test.status == TestStatus.pass || test.status == TestStatus.fail);

    state = state.copyWith(
      manualTests: state.manualTests.copyWith(
        tests: updatedTests,
        userConfirmations: updatedConfirmations,
        isComplete: allComplete,
      ),
    );

    // If all tests are complete, move to completed phase
    if (allComplete && state.automaticTests.isComplete) {
      state = state.copyWith(phase: FactoryTestPhase.completed);
    }
  }

  /// Retry automatic tests after timeout/failure
  Future<void> retryAutomaticTests() async {
    if (state.selectedDeviceId == null) return;

    // Reset automatic tests state
    state = state.copyWith(
      automaticTests:
          AutomaticTestsState(tests: _createInitialAutomaticTests()),
      phase: FactoryTestPhase.connecting,
      connectionState: FactoryTestConnectionState.connecting,
      error: null,
    );

    // Find and reconnect to the device
    final device = state.availableDevices.firstWhere(
      (d) => d.deviceId == state.selectedDeviceId,
      orElse: () => throw 'Device not found',
    );

    try {
      await _connectToDevice(device.bluetoothDevice);
    } catch (error) {
      debugPrint('Retry connection error: $error');
      state = state.copyWith(
        phase: FactoryTestPhase.error,
        connectionState: FactoryTestConnectionState.error,
        error: 'Retry connection failed: $error',
      );
    }
  }

  /// Reset factory test to start over
  void resetFactoryTest() {
    _clearAutomaticTestTimeout(); // Clear timeout before cleanup
    _cleanup();

    state = FactoryTestState(
      phase: FactoryTestPhase.deviceSelection,
      connectionState: FactoryTestConnectionState.idle,
      availableDevices: [],
      automaticTests:
          AutomaticTestsState(tests: _createInitialAutomaticTests()),
      manualTests: ManualTestsState(
        tests: _createInitialManualTests(),
        userConfirmations: {},
      ),
    );
  }

  /// Start timeout timer for automatic tests (1 minute)
  void _startAutomaticTestTimeout() {
    _clearAutomaticTestTimeout(); // Clear any existing timer

    _automaticTestTimeoutTimer = Timer(const Duration(minutes: 1), () {
      debugPrint('Automatic tests timeout - assuming device connection lost');
      _handleAutomaticTestTimeout();
    });
  }

  /// Clear automatic test timeout timer
  void _clearAutomaticTestTimeout() {
    _automaticTestTimeoutTimer?.cancel();
    _automaticTestTimeoutTimer = null;
  }

  /// Handle automatic test timeout (device connection likely lost)
  void _handleAutomaticTestTimeout() {
    if (state.automaticTests.isComplete) return; // Already completed, ignore

    debugPrint(
        'Automatic tests timed out after 1 minute - device connection appears to be lost');

    // Mark all running tests as failed due to timeout
    final updatedTests = state.automaticTests.tests.map((test) {
      if (test.status == TestStatus.running ||
          test.status == TestStatus.notStarted) {
        return test.copyWith(
          status: TestStatus.fail,
          comment: 'Test failed - device connection lost',
          timestamp: DateTime.now(),
        );
      }
      return test;
    }).toList();

    state = state.copyWith(
      automaticTests: state.automaticTests.copyWith(
        tests: updatedTests,
        isRunning: false,
        isComplete: true,
        error:
            'Automatic tests failed - device connection lost after 1 minute. The device may have restarted due to an issue.',
      ),
      phase: FactoryTestPhase.error,
      connectionState: FactoryTestConnectionState.error,
      error:
          'Device connection lost during automatic tests. Please reconnect and try again.',
    );

    // Clean up connection
    _cleanup();
  }

  /// Cleanup resources
  void _cleanup() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _notificationSubscription?.cancel();
    _reconnectionTimer?.cancel();
    _commandTimeoutTimer?.cancel();
    _automaticTestTimeoutTimer?.cancel();
    _scanTimeoutTimer?.cancel();

    if (_connectedDevice?.isConnected == true) {
      _connectedDevice?.disconnect();
    }

    _connectedDevice = null;
    _writeCharacteristic = null;
    _notifyCharacteristic = null;
    _commandQueue.clear();
    _isProcessingCommand = false;
  }
}
