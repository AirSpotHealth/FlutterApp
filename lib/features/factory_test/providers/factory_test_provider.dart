import 'dart:async';

import 'package:airspothealth/core/services/ble_service.dart';
import 'package:airspothealth/core/services/network_service.dart';
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
      TestResult(testName: 'LCD with OCA?', status: TestStatus.notStarted),
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
    debugPrint('_executeCommand called for: ${command.type}');

    if (_writeCharacteristic == null) {
      debugPrint('ERROR: Write characteristic not available');
      throw 'Write characteristic not available';
    }

    debugPrint('Adding command to queue: ${command.command}');
    _commandQueue.add(command);

    if (!_isProcessingCommand) {
      debugPrint('Starting command queue processing...');
      await _processCommandQueue();
    } else {
      debugPrint('Command queue already processing, command added to queue');
    }
  }

  /// Process the command queue
  Future<void> _processCommandQueue() async {
    debugPrint(
        '_processCommandQueue started, queue length: ${_commandQueue.length}');
    _isProcessingCommand = true;

    while (_commandQueue.isNotEmpty) {
      final command = _commandQueue.removeAt(0);
      debugPrint(
          'Processing command: ${command.type}, bytes: ${command.command}');

      int retryCount = 0;
      bool success = false;

      while (retryCount <= command.maxRetries && !success) {
        try {
          debugPrint(
              'Attempting to write command (attempt ${retryCount + 1})...');
          await _writeCharacteristic!.write(command.command);
          debugPrint('Command sent successfully: ${command.type}');
          success = true;
        } catch (error) {
          retryCount++;
          debugPrint('Command failed (attempt $retryCount): $error');

          if (retryCount <= command.maxRetries) {
            debugPrint('Waiting before retry...');
            await Future.delayed(Duration(milliseconds: 500 * retryCount));
          }
        }
      }

      if (!success) {
        debugPrint(
            'Command ${command.type} failed after ${command.maxRetries} retries');
        throw 'Command ${command.type} failed after ${command.maxRetries} retries';
      }
    }

    debugPrint('Command queue processing complete');
    _isProcessingCommand = false;
  }

  /// Handle incoming notifications from device
  void _handleNotification(List<int> data) {
    debugPrint(
        'Received notification: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

    if (data.length < 3) return;

    final commandByte = data[2];

    switch (commandByte) {
      case 0xD0: // Factory mode stopped from device
        _handleFactoryModeStopped(data);
        break;
      case 0xD2: // Manual test started response
        _handleManualTestStartedResponse(data);
        break;
      case 0xD3: // Manual test confirmation response
        _handleManualTestConfirmationResponse(data);
        break;
      case 0xDD: // Automatic test result
        _handleAutomaticTestResult(data);
        break;
      default:
        debugPrint(
            'Unknown command response: 0x${commandByte.toRadixString(16)}');
        break;
    }
  }

  /// Handle factory mode stopped from device
  void _handleFactoryModeStopped(List<int> data) {
    debugPrint('Factory mode stopped from device');
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

    _cleanup();
  }

  /// Handle automatic test results
  void _handleAutomaticTestResult(List<int> data) {
    final result = FactoryTestResponseParser.parseAutomaticTestResult(data);
    final testName = result['testName'] as String;

    // Check if this is sensor variant detection
    if (testName == 'Sensor Variant Detection') {
      final sensorVariant = result['value'] as int?;

      debugPrint('Detected sensor variant: $sensorVariant');

      // Store the detected sensor variant in state
      state = state.copyWith(selectedDeviceVariant: sensorVariant);

      // This is an informational test, so we don't need to track it in the test list
      // Just log it and continue
      return;
    }

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

      // Auto-start charge test (it's automatically available after automatic tests)
      _autoStartChargeTest();
    }
  }

  /// Handle manual test started response (0xD2 response)
  void _handleManualTestStartedResponse(List<int> data) {
    if (data.length < 5) return;

    final testType = data[4];
    final testName = _getTestNameFromType(testType);

    debugPrint('Manual test started response for: $testName (type: $testType)');

    final updatedTests = state.manualTests.tests.map((test) {
      if (test.testName == testName) {
        return test.copyWith(
          deviceResponseReceived: true,
          timestamp: DateTime.now(),
          comment: '${test.comment ?? ''} - Device response received',
        );
      }
      return test;
    }).toList();

    state = state.copyWith(
      manualTests: state.manualTests.copyWith(tests: updatedTests),
    );
  }

  /// Handle manual test confirmation response (0xD3 response)
  void _handleManualTestConfirmationResponse(List<int> data) {
    if (data.length < 5) return;

    final confirmed = data[4] == 1;

    debugPrint(
        'Manual test confirmation response: ${confirmed ? "PASS" : "FAIL"}');

    // This response confirms that the device received our confirmation command
    // The actual test status update is handled in updateUserConfirmation method
  }

  /// Get test name from test type constant
  String _getTestNameFromType(int testType) {
    switch (testType) {
      case ManualTestType.manualTestCharge:
        return 'Charge Test';
      case ManualTestType.manualTestEdge:
        return 'Screen Edge Test';
      case ManualTestType.manualTestBlackScreen:
        return 'Screen Black Test';
      case ManualTestType.manualTestWhiteScreen:
        return 'Screen White Test';
      case ManualTestType.manualTestButton:
        return 'Button Test';
      case ManualTestType.manualTestBuzzer:
        return 'Buzzer Test';
      case ManualTestType.manualTestVibration:
        return 'Vibration Test';
      case ManualTestType.manualTestCaseCheck:
        return 'Case Check';
      case ManualTestType.manualTestLcdOca:
        return 'LCD with OCA?';
      default:
        return 'Unknown Test';
    }
  }

  /// Auto-start charge test when manual tests phase begins
  void _autoStartChargeTest() {
    debugPrint('Auto-starting charge test...');

    // Update charge test status to running only if it's not already completed
    final updatedTests = state.manualTests.tests.map((test) {
      if (test.testName == 'Charge Test') {
        // Only auto-start if the test hasn't been completed yet
        if (test.status == TestStatus.notStarted) {
          return test.copyWith(
            status: TestStatus.running,
            comment: 'Auto-started after automatic tests completed',
            timestamp: DateTime.now(),
            deviceResponseReceived: true, // Charge test is auto-available
          );
        }
        // If test is already passed/failed, don't change its status
        return test;
      }
      return test;
    }).toList();

    state = state.copyWith(
      manualTests: state.manualTests.copyWith(tests: updatedTests),
    );

    debugPrint('Charge test auto-started and ready for user confirmation');
  }

  // Manual test control methods using new robust protocol
  Future<void> startChargeTest() async {
    try {
      await _updateTestStatus('Charge Test', TestStatus.running);

      final command = FactoryTestCommand(
        type: FactoryTestCommandType.startManualTest,
        command: DeviceCmdUtils.startManualChargeTest(),
        parameters: {'testType': ManualTestType.manualTestCharge},
      );
      await _executeCommand(command);

      debugPrint('Charge test command sent successfully');
    } catch (error) {
      debugPrint('Error starting charge test: $error');
      await _updateTestStatus(
          'Charge Test', TestStatus.fail, 'Failed to start test: $error');
    }
  }

  Future<void> startScreenEdgeTest() async {
    try {
      await _updateTestStatus('Screen Edge Test', TestStatus.running);

      final command = FactoryTestCommand(
        type: FactoryTestCommandType.startManualTest,
        command: DeviceCmdUtils.startManualScreenEdgeTest(),
        parameters: {'testType': ManualTestType.manualTestEdge},
      );
      await _executeCommand(command);

      debugPrint('Screen edge test command sent successfully');
    } catch (error) {
      debugPrint('Error starting screen edge test: $error');
      await _updateTestStatus(
          'Screen Edge Test', TestStatus.fail, 'Failed to start test: $error');
    }
  }

  Future<void> startScreenBlackTest() async {
    try {
      await _updateTestStatus('Screen Black Test', TestStatus.running);

      final command = FactoryTestCommand(
        type: FactoryTestCommandType.startManualTest,
        command: DeviceCmdUtils.startManualScreenBlackTest(),
        parameters: {'testType': ManualTestType.manualTestBlackScreen},
      );
      await _executeCommand(command);

      debugPrint('Screen black test command sent successfully');
    } catch (error) {
      debugPrint('Error starting screen black test: $error');
      await _updateTestStatus(
          'Screen Black Test', TestStatus.fail, 'Failed to start test: $error');
    }
  }

  Future<void> startScreenWhiteTest() async {
    try {
      await _updateTestStatus('Screen White Test', TestStatus.running);

      final command = FactoryTestCommand(
        type: FactoryTestCommandType.startManualTest,
        command: DeviceCmdUtils.startManualScreenWhiteTest(),
        parameters: {'testType': ManualTestType.manualTestWhiteScreen},
      );
      await _executeCommand(command);

      debugPrint('Screen white test command sent successfully');
    } catch (error) {
      debugPrint('Error starting screen white test: $error');
      await _updateTestStatus(
          'Screen White Test', TestStatus.fail, 'Failed to start test: $error');
    }
  }

  Future<void> startButtonTest() async {
    try {
      await _updateTestStatus('Button Test', TestStatus.running);

      final command = FactoryTestCommand(
        type: FactoryTestCommandType.startManualTest,
        command: DeviceCmdUtils.startManualButtonTest(),
        parameters: {'testType': ManualTestType.manualTestButton},
      );
      await _executeCommand(command);

      debugPrint('Button test command sent successfully');
    } catch (error) {
      debugPrint('Error starting button test: $error');
      await _updateTestStatus(
          'Button Test', TestStatus.fail, 'Failed to start test: $error');
    }
  }

  Future<void> startBuzzerTest() async {
    try {
      await _updateTestStatus('Buzzer Test', TestStatus.running);

      final command = FactoryTestCommand(
        type: FactoryTestCommandType.startManualTest,
        command: DeviceCmdUtils.startManualBuzzerTest(),
        parameters: {'testType': ManualTestType.manualTestBuzzer},
      );
      await _executeCommand(command);

      debugPrint('Buzzer test command sent successfully');
    } catch (error) {
      debugPrint('Error starting buzzer test: $error');
      await _updateTestStatus(
          'Buzzer Test', TestStatus.fail, 'Failed to start test: $error');
    }
  }

  Future<void> startVibrationTest() async {
    try {
      await _updateTestStatus('Vibration Test', TestStatus.running);

      final command = FactoryTestCommand(
        type: FactoryTestCommandType.startManualTest,
        command: DeviceCmdUtils.startManualVibrationTest(),
        parameters: {'testType': ManualTestType.manualTestVibration},
      );
      await _executeCommand(command);

      debugPrint('Vibration test command sent successfully');
    } catch (error) {
      debugPrint('Error starting vibration test: $error');
      await _updateTestStatus(
          'Vibration Test', TestStatus.fail, 'Failed to start test: $error');
    }
  }

  /// Helper method to update test status
  Future<void> _updateTestStatus(String testName, TestStatus status,
      [String? comment]) async {
    final updatedTests = state.manualTests.tests.map((test) {
      if (test.testName == testName) {
        return test.copyWith(
          status: status,
          comment: comment ?? test.comment,
          timestamp:
              status != TestStatus.notStarted ? DateTime.now() : test.timestamp,
          // Device doesn't acknowledge start commands, so we assume they're received
          deviceResponseReceived:
              status == TestStatus.running ? true : test.deviceResponseReceived,
        );
      }
      return test;
    }).toList();

    state = state.copyWith(
      manualTests: state.manualTests.copyWith(tests: updatedTests),
    );
  }

  /// Update user confirmation for manual tests with device confirmation
  Future<void> updateUserConfirmation(String testName, bool confirmed) async {
    try {
      debugPrint('=== MANUAL TEST CONFIRMATION START ===');
      debugPrint('Test: $testName, Confirmed: ${confirmed ? "PASS" : "FAIL"}');

      // Send confirmation command to device
      final command = FactoryTestCommand(
        type: FactoryTestCommandType.confirmManualTest,
        command: confirmed
            ? DeviceCmdUtils.confirmManualTestPassed()
            : DeviceCmdUtils.confirmManualTestFailed(),
        parameters: {'testName': testName, 'confirmed': confirmed},
      );

      debugPrint('Command bytes: ${command.command}');
      debugPrint('Executing command...');
      await _executeCommand(command);
      debugPrint('Command executed successfully');

      final updatedConfirmations =
          Map<String, bool>.from(state.manualTests.userConfirmations);
      updatedConfirmations[testName] = confirmed;

      // Update test status based on user confirmation
      final updatedTests = state.manualTests.tests.map((test) {
        if (test.testName == testName) {
          return test.copyWith(
            status: confirmed ? TestStatus.pass : TestStatus.fail,
            comment: confirmed
                ? '${test.comment ?? ''} - User confirmed'
                : '${test.comment ?? ''} - User marked as failed',
            timestamp: DateTime.now(),
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

      debugPrint(
          'User confirmation sent for $testName: ${confirmed ? "PASS" : "FAIL"}');
    } catch (error) {
      debugPrint('Error sending user confirmation for $testName: $error');
      // Still update local state even if device command fails
      final updatedConfirmations =
          Map<String, bool>.from(state.manualTests.userConfirmations);
      updatedConfirmations[testName] = confirmed;

      final updatedTests = state.manualTests.tests.map((test) {
        if (test.testName == testName) {
          return test.copyWith(
            status: confirmed ? TestStatus.pass : TestStatus.fail,
            comment:
                '${test.comment ?? ''} - ${confirmed ? "User confirmed" : "User marked as failed"} (device command failed)',
            timestamp: DateTime.now(),
          );
        }
        return test;
      }).toList();

      state = state.copyWith(
        manualTests: state.manualTests.copyWith(
          tests: updatedTests,
          userConfirmations: updatedConfirmations,
        ),
      );
    }
  }

  /// Update test comment
  void updateTestComment(String testName, String comment) {
    final updatedTests = state.manualTests.tests.map((test) {
      if (test.testName == testName) {
        return test.copyWith(comment: comment);
      }
      return test;
    }).toList();

    state = state.copyWith(
      manualTests: state.manualTests.copyWith(tests: updatedTests),
    );

    debugPrint('Updated comment for $testName: $comment');
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

  /// Send 0xDE command to end factory test mode and restart device in normal mode
  Future<void> endFactoryTestMode() async {
    try {
      debugPrint('Sending 0xDE command to end factory test mode');

      // Send the factory test end command (0xDE)
      final command = FactoryTestCommand(
        type: FactoryTestCommandType.endFactoryTest,
        command: DeviceCmdUtils.factoryTestEnd(),
        timeout: const Duration(seconds: 5),
        maxRetries: 1, // Only try once since device will restart
      );

      await _executeCommand(command);

      // Clean up after sending command
      _cleanup();

      debugPrint('Factory test end command sent successfully');
    } catch (error) {
      debugPrint('Error sending factory test end command: $error');
      // Clean up even if command fails
      _cleanup();
    }
  }

  /// Submit factory test results to the API
  Future<void> submitTestResults({
    required String macAddress,
    required String deviceId,
    required String testedBy,
    required String status,
    String? comment,
    int sensorVariant = 0,
    String deviceType = 'as1',
  }) async {
    // Set submitting state
    state = state.copyWith(
      isSubmittingResults: true,
      submissionError: null,
      resultsSubmitted: false,
    );

    try {
      // Create automatic tests array
      final List<Map<String, dynamic>> automaticTests = [];
      for (final test in state.automaticTests.tests) {
        automaticTests.add({
          'status': test.status.name == 'pass' ? 'Pass' : 'Fail',
          'value': _formatTestValue(test.testName, test.value),
          'testName': test.testName,
        });
      }

      // Create manual tests array
      final List<Map<String, dynamic>> manualTests = [];
      for (final test in state.manualTests.tests) {
        manualTests.add({
          'status': test.status.name == 'pass' ? 'Pass' : 'Fail',
          'value': _formatTestValue(test.testName, test.value),
          'testName': test.testName,
        });
      }

      // Structure test_details as an object with automaticTests and manualTests
      final Map<String, dynamic> testDetails = {
        'automaticTests': automaticTests,
        'manualTests': manualTests,
      };

      // Prepare API payload according to the new structure
      final payload = {
        'mac_address': macAddress,
        'device_id': deviceId,
        'tested_by': testedBy,
        'status': status,
        'comment': comment?.isEmpty == true ? null : comment,
        'sensor_variant': sensorVariant,
        'device_type': deviceType,
        'test_details': testDetails,
      };

      debugPrint('Submitting factory test results: ${payload.toString()}');

      // Get API key from environment
      const apiKey = String.fromEnvironment('API_KEY');

      // Prepare headers
      final headers = <String, String>{};
      if (apiKey.isNotEmpty) {
        headers['x-api-key'] = apiKey;
      }

      // Submit to API with headers
      final response = await NetworkService.instance.post(
        '/device_tests',
        payload,
        headers: headers.isNotEmpty ? headers : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Factory test results submitted successfully');

        // Send 0xDE command to end factory test mode and restart device
        debugPrint(
            'Sending 0xDE command to end factory test mode after successful submission');
        try {
          await endFactoryTestMode();
          debugPrint('Factory test mode ended successfully after submission');
        } catch (commandError) {
          debugPrint(
              'Warning: Failed to send end factory test command after submission: $commandError');
          // Don't fail the submission if the command fails, just log it
        }

        state = state.copyWith(
          isSubmittingResults: false,
          resultsSubmitted: true,
          submissionError: null,
        );
      } else {
        final errorMessage = response.data != null
            ? 'Server error: ${response.data}'
            : 'Server responded with status ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Factory test submission error: $e');
      String errorMessage = 'Submission failed';
      if (e.toString().contains('DioException')) {
        errorMessage =
            'Network error: Please check your internet connection ${e.toString()}';
      } else if (e.toString().contains('Server error')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = 'Submission failed: ${e.toString()}';
      }

      state = state.copyWith(
        isSubmittingResults: false,
        resultsSubmitted: false,
        submissionError: errorMessage,
      );
    }
  }

  /// Get sensor variant from device info
  int getSensorVariant(dynamic device) {
    // Use the detected sensor variant from the device if available
    if (state.selectedDeviceVariant != null) {
      debugPrint(
          'Using detected sensor variant: ${state.selectedDeviceVariant}');
      return state.selectedDeviceVariant!;
    }

    // Fallback: Try to extract sensor variant from device properties
    if (device?.firmwareVersion != null) {
      // Implement logic here to determine sensor variant based on firmware
      return 1;
    }

    // Default sensor variant if not detected
    debugPrint('No sensor variant detected, using default: 1');
    return 1;
  }

  /// Get device type from device info
  String getDeviceType(dynamic device) {
    return 'as1'; // Default device type
  }

  /// Format test value with appropriate suffix based on test name
  dynamic _formatTestValue(String testName, dynamic value) {
    if (value == null) return null;

    switch (testName) {
      case 'Sensor Test':
        return '$value ppm';
      case 'Battery Voltage Test':
        return '${value}mV';
      case 'LF Crystal Test':
        return '$value kHz';
      case 'Memory Test':
      case 'LCD Controller Test':
      case 'Charge Test':
      case 'Screen Edge Test':
      case 'Screen Black Test':
      case 'Screen White Test':
      case 'Button Test':
      case 'Buzzer Test':
      case 'Vibration Test':
      case 'Case Check':
      case 'LCD with OCA?':
        return null; // These tests typically don't have numeric values
      default:
        return value; // Return raw value for unknown tests
    }
  }

  /// Export factory test results in the specified format
  Map<String, dynamic> exportTestResults({
    required String macAddress,
    required String deviceId,
    required String testedBy,
    required String status,
    String? comment,
    int sensorVariant = 0,
    String deviceType = 'as1',
  }) {
    // Create automatic tests array
    final List<Map<String, dynamic>> automaticTests = [];
    for (final test in state.automaticTests.tests) {
      automaticTests.add({
        'status': test.status.name == 'pass' ? 'Pass' : 'Fail',
        'value': _formatTestValue(test.testName, test.value),
        'testName': test.testName,
      });
    }

    // Create manual tests array
    final List<Map<String, dynamic>> manualTests = [];
    for (final test in state.manualTests.tests) {
      manualTests.add({
        'status': test.status.name == 'pass' ? 'Pass' : 'Fail',
        'value': _formatTestValue(test.testName, test.value),
        'testName': test.testName,
      });
    }

    // Structure test_details as an object with automaticTests and manualTests
    final Map<String, dynamic> testDetails = {
      'automaticTests': automaticTests,
      'manualTests': manualTests,
    };

    // Prepare export payload according to the specified structure
    final exportData = {
      'mac_address': macAddress,
      'device_id': deviceId,
      'tested_by': testedBy,
      'status': status,
      'comment': comment?.isEmpty == true ? null : comment,
      'sensor_variant': sensorVariant,
      'device_type': deviceType,
      'test_details': testDetails,
    };

    return exportData;
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
