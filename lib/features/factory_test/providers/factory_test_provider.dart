import 'dart:async';

import 'package:airspothealth/core/services/ble_service.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_commands.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_devices_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final factoryTestProvider = NotifierProvider.family<FactoryTestNotifier,
    DeviceFactoryTestState, String>(
  FactoryTestNotifier.new,
);

class FactoryTestNotifier
    extends FamilyNotifier<DeviceFactoryTestState, String> {
  final BLEService _bleService = BLEService.instance;

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _notifyCharacteristic;

  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notificationSubscription;

  Timer? _commandTimeoutTimer;
  Timer? _automaticTestTimeoutTimer;
  Timer? _connectionTimeoutTimer;

  // Command queue for reliable execution
  final List<FactoryTestCommand> _commandQueue = [];
  bool _isProcessingCommand = false;
  bool _isEndingFactoryMode = false;

  @override
  DeviceFactoryTestState build(String deviceId) {
    return DeviceFactoryTestState.emptyState(
      ref.read(factoryTestDevicesProvider).devices.firstWhere(
            (device) => device.deviceId == deviceId,
          ),
    );
  }

  /// Manual cleanup method - call this when done with factory testing
  void dispose() {
    _cleanup();
  }

  /// Connect to selected device and start factory test flow
  Future<void> connectToDeviceAndStartFactoryTest() async {
    debugPrint('=== STARTING FACTORY TEST CONNECTION FLOW ===');
    debugPrint('Selected device: ${state.selectedDevice.name}');

    // Clear any existing timeout
    _clearConnectionTimeout();

    state = state.copyWith(
      phase: DeviceFactoryTestPhase.connecting,
      connectionState: DeviceFactoryTestConnectionState.connecting,
      error: null,
    );
    debugPrint('Updated state to connecting phase');

    // Start connection timeout (30 seconds)
    _startConnectionTimeout();

    try {
      debugPrint('Calling _connectToDevice...');
      await _connectToDevice(state.selectedDevice.bluetoothDevice);
      debugPrint('_connectToDevice completed successfully');
      // Don't call _enterFactoryMode here - it will be called from _onDeviceConnected
    } catch (error) {
      debugPrint('=== CONNECTION ERROR ===');
      debugPrint('Connection error: $error');
      _clearConnectionTimeout();
      state = state.copyWith(
        phase: DeviceFactoryTestPhase.error,
        connectionState: DeviceFactoryTestConnectionState.error,
        error: 'Connection failed: $error',
      );
    }
  }

  /// Connect to the Bluetooth device
  Future<void> _connectToDevice(BluetoothDevice device) async {
    debugPrint('=== STARTING CONNECTION TO DEVICE ===');
    debugPrint('Device: ${device.advName} (${device.remoteId})');

    _connectedDevice = device;
    debugPrint('Set _connectedDevice to: ${_connectedDevice?.advName}');

    try {
      // Start the BLE connection first
      debugPrint('Starting BLE connection...');
      await _bleService.connect(device);
      debugPrint('BLE connection initiated');
      debugPrint(
          '_connectedDevice after BLE connect: ${_connectedDevice?.advName}');

      // Now set up the connection state listener
      _connectionSubscription = device.connectionState.listen(
        (connectionState) {
          debugPrint('Connection state changed: $connectionState');
          debugPrint(
              '_connectedDevice in listener: ${_connectedDevice?.advName}');

          if (connectionState == BluetoothConnectionState.connected) {
            if (state.phase == DeviceFactoryTestPhase.enteringFactoryMode) {
              debugPrint('Ignoring connection during factory mode entry phase');
              return;
            }
            debugPrint(
                'Device connected successfully, calling _onDeviceConnected');
            _onDeviceConnected();
          } else if (connectionState == BluetoothConnectionState.disconnected) {
            // Only handle disconnection if we've moved past the initial connecting phase
            if (state.connectionState ==
                DeviceFactoryTestConnectionState.connecting) {
              debugPrint(
                  'Ignoring disconnection event during initial connection phase');
              return;
            }
            debugPrint('Device disconnected, calling _onDeviceDisconnected');
            _onDeviceDisconnected();
          }
        },
        onError: (error) {
          debugPrint('Connection state listener error: $error');
          state = state.copyWith(
            phase: DeviceFactoryTestPhase.error,
            connectionState: DeviceFactoryTestConnectionState.error,
            error: 'Connection state error: $error',
          );
        },
      );

      // Give the connection a moment to establish
      await Future.delayed(const Duration(milliseconds: 500));

      if (device.isConnected) {
        debugPrint(
            'Device connection verified - ensuring _onDeviceConnected is called');
        debugPrint(
            '_connectedDevice before manual call: ${_connectedDevice?.advName}');
        // Call _onDeviceConnected to ensure setup happens (duplicate prevention is handled in the method)
        await _onDeviceConnected();
      } else {
        debugPrint('Device not connected after connection attempt');
        throw 'Device connection failed - device not connected after connection attempt';
      }
    } catch (error) {
      debugPrint('BLE connection error: $error');
      state = state.copyWith(
        phase: DeviceFactoryTestPhase.error,
        connectionState: DeviceFactoryTestConnectionState.error,
        error: 'BLE connection failed: $error',
      );
      rethrow;
    }
  }

  /// Handle successful device connection
  Future<void> _onDeviceConnected() async {
    debugPrint('=== DEVICE CONNECTED - STARTING SETUP ===');

    // Prevent duplicate calls
    if (state.connectionState == DeviceFactoryTestConnectionState.connected) {
      debugPrint('Device already connected, skipping duplicate setup');
      return;
    }

    // Clear connection timeout since we're now connected
    _clearConnectionTimeout();

    try {
      // Check if device is still available - if not, try to get it from the connection subscription
      if (_connectedDevice == null) {
        debugPrint(
            'ERROR: _connectedDevice is null, trying to get device from state');
        _connectedDevice = state.selectedDevice.bluetoothDevice;

        if (_connectedDevice == null) {
          debugPrint('ERROR: Could not recover device reference');
          throw 'Could not recover device reference';
        }
        debugPrint('Recovered device reference: ${_connectedDevice!.advName}');
      }

      debugPrint('Checking if device is still connected...');
      if (!_connectedDevice!.isConnected) {
        debugPrint('ERROR: Device is no longer connected');
        throw 'Device is no longer connected';
      }
      debugPrint('Device connection verified');

      state = state.copyWith(
        connectionState: DeviceFactoryTestConnectionState.connected,
      );
      debugPrint('Updated connection state to connected');

      // Discover services and characteristics
      debugPrint('Starting service discovery...');
      final services = await _connectedDevice!.discoverServices();
      debugPrint('Services discovered: ${services.length} services found');

      try {
        debugPrint('Checking Constants.serviceUuid: ${Constants.serviceUuid}');

        for (final service in services) {
          debugPrint('Service UUID: ${service.uuid}');
        }

        final service = services.firstWhere(
          (s) => s.uuid.toString().toUpperCase() == Constants.serviceUuid,
          orElse: () =>
              throw 'Service not found - looking for ${Constants.serviceUuid}',
        );
        debugPrint('Target service found: ${service.uuid}');

        debugPrint('Checking service.characteristics...');
        if (service.characteristics.isEmpty) {
          debugPrint('ERROR: Service has no characteristics');
          throw 'Service has no characteristics';
        }

        debugPrint('Looking for characteristics...');
        for (final char in service.characteristics) {
          debugPrint('Characteristic UUID: ${char.uuid}');
        }

        debugPrint('Looking for write characteristic: ${Constants.writeUuid}');
        _writeCharacteristic = service.characteristics.firstWhere(
          (c) => c.uuid.toString().toUpperCase() == Constants.writeUuid,
          orElse: () =>
              throw 'Write characteristic not found - looking for ${Constants.writeUuid}',
        );
        debugPrint('Write characteristic found: ${_writeCharacteristic!.uuid}');

        debugPrint(
            'Looking for notify characteristic: ${Constants.notifyUuid}');
        _notifyCharacteristic = service.characteristics.firstWhere(
          (c) => c.uuid.toString().toUpperCase() == Constants.notifyUuid,
          orElse: () =>
              throw 'Notify characteristic not found - looking for ${Constants.notifyUuid}',
        );
        debugPrint(
            'Notify characteristic found: ${_notifyCharacteristic!.uuid}');
      } catch (serviceError) {
        debugPrint('ERROR in service/characteristic discovery: $serviceError');
        rethrow;
      }

      // Setup notifications
      try {
        debugPrint('Setting up notifications...');
        debugPrint('Notify characteristic is: $_notifyCharacteristic');

        if (_notifyCharacteristic == null) {
          throw 'Notify characteristic is null';
        }

        debugPrint('Calling setNotifyValue(true)...');
        await _notifyCharacteristic!.setNotifyValue(true);
        debugPrint('setNotifyValue completed');

        debugPrint('Setting up notification listener...');
        _notificationSubscription =
            _notifyCharacteristic!.onValueReceived.listen(
          _handleNotification,
          onError: (error) {
            debugPrint('Notification error: $error');
          },
        );
        debugPrint('Notifications setup complete');
      } catch (notificationError) {
        debugPrint('ERROR in notification setup: $notificationError');
        rethrow;
      }

      debugPrint('Device connected and characteristics setup complete');

      // Handle different connection scenarios
      if (state.phase == DeviceFactoryTestPhase.connecting) {
        debugPrint('Initial connection - proceeding to enter factory mode...');
        await _enterFactoryMode();
      } else if (state.phase == DeviceFactoryTestPhase.reconnecting) {
        debugPrint(
            'Device auto-reconnected after factory mode - starting automatic tests...');
        state = state.copyWith(
          connectionState: DeviceFactoryTestConnectionState.factoryModeReady,
          phase: DeviceFactoryTestPhase.runningAutomaticTests,
        );
        debugPrint('Updated phase to runningAutomaticTests');
        await _startAutomaticTests();
      } else {
        debugPrint('Connection in unexpected phase: ${state.phase}');
      }
    } catch (error) {
      debugPrint('=== ERROR DURING DEVICE SETUP ===');
      debugPrint('Error setting up device: $error');
      state = state.copyWith(
        phase: DeviceFactoryTestPhase.error,
        connectionState: DeviceFactoryTestConnectionState.error,
        error: 'Device setup failed: $error',
      );
    }
  }

  /// Handle device disconnection
  void _onDeviceDisconnected() {
    debugPrint('Device disconnected - Current state: ${state.phase}');

    if (_isEndingFactoryMode) {
      // Expected disconnection when ending factory test mode - device will restart in normal mode
      debugPrint(
          'Expected disconnection during factory test end - device restarting in normal mode');
      _isEndingFactoryMode = false;
      // Don't update state or show error - this is expected behavior

      _cleanup();
      return;
    } else if (state.connectionState ==
        DeviceFactoryTestConnectionState.enteringFactoryMode) {
      // Expected disconnection during factory mode entry - device will auto-reconnect
      debugPrint(
          'Expected disconnection during factory mode entry - waiting for auto-reconnect');
      state = state.copyWith(
        connectionState: DeviceFactoryTestConnectionState.deviceRestarting,
        phase: DeviceFactoryTestPhase.reconnecting,
      );
    } else if (state.phase == DeviceFactoryTestPhase.runningAutomaticTests &&
        state.automaticTests.isRunning) {
      // Unexpected disconnection during automatic tests
      debugPrint(
          'Device disconnected during automatic tests - connection lost');
      _clearAutomaticTestTimeout();
      _handleAutomaticTestTimeout(); // Handle as timeout since connection is lost
    } else {
      // Other unexpected disconnection
      debugPrint('Unexpected disconnection in phase: ${state.phase}');
      state = state.copyWith(
        connectionState: DeviceFactoryTestConnectionState.disconnected,
        error: 'Device unexpectedly disconnected',
      );
    }
  }

  /// Enter factory test mode
  Future<void> _enterFactoryMode() async {
    debugPrint('=== ENTERING FACTORY MODE ===');

    state = state.copyWith(
      phase: DeviceFactoryTestPhase.enteringFactoryMode,
      connectionState: DeviceFactoryTestConnectionState.enteringFactoryMode,
    );
    debugPrint('Updated state to enteringFactoryMode phase');

    try {
      debugPrint('Creating factory mode command...');
      final command = FactoryTestCommand(
        type: FactoryTestCommandType.enterFactoryMode,
        command: DeviceCmdUtils.enterFactoryTestMode(),
        timeout: const Duration(seconds: 5),
      );
      debugPrint('Command created: ${command.command}');

      debugPrint('Executing factory mode command...');
      await _executeCommand(command);

      debugPrint(
          'Factory mode command sent successfully, waiting for device restart...');
    } catch (error) {
      debugPrint('=== FACTORY MODE ERROR ===');
      debugPrint('Error entering factory mode: $error');
      state = state.copyWith(
        phase: DeviceFactoryTestPhase.error,
        connectionState: DeviceFactoryTestConnectionState.error,
        error: 'Failed to enter factory mode: $error',
      );
    }
  }

  /// Start automatic tests
  Future<void> _startAutomaticTests() async {
    debugPrint('=== STARTING AUTOMATIC TESTS ===');
    debugPrint('Current phase before starting tests: ${state.phase}');

    try {
      final command = FactoryTestCommand(
        type: FactoryTestCommandType.startAutomaticTests,
        command: DeviceCmdUtils.startFactoryAutoTests(),
        timeout: const Duration(seconds: 30),
      );

      debugPrint('Sending automatic tests command...');
      await _executeCommand(command);

      // Update test state to running
      final updatedTests = state.automaticTests.tests
          .map((test) => test.copyWith(status: DeviceTestStatus.running))
          .toList();

      debugPrint('Updating state with running tests...');
      state = state.copyWith(
        phase: DeviceFactoryTestPhase
            .runningAutomaticTests, // Ensure phase is correct
        automaticTests: state.automaticTests.copyWith(
          tests: updatedTests,
          isRunning: true,
        ),
      );

      debugPrint(
          'State updated - Phase: ${state.phase}, Tests running: ${state.automaticTests.isRunning}');

      // Start timeout timer for automatic tests (1 minute)
      _startAutomaticTestTimeout();

      debugPrint('Automatic tests started successfully');
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
    state = DeviceFactoryTestState.emptyState(state.selectedDevice);

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
          status: result['status'] == 'Pass'
              ? DeviceTestStatus.pass
              : DeviceTestStatus.fail,
          comment: result['comment'] as String?,
          value: result['value'],
          timestamp: DateTime.now(),
          deviceResponseReceived: true,
        );
      }
      return test;
    }).toList();

    final allComplete = updatedTests.every((test) =>
        test.status == DeviceTestStatus.pass ||
        test.status == DeviceTestStatus.fail);

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
      state = state.copyWith(phase: DeviceFactoryTestPhase.runningManualTests);

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
        if (test.status == DeviceTestStatus.notStarted) {
          return test.copyWith(
            status: DeviceTestStatus.running,
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
      await _updateTestStatus('Charge Test', DeviceTestStatus.running);

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
          'Charge Test', DeviceTestStatus.fail, 'Failed to start test: $error');
    }
  }

  Future<void> startScreenEdgeTest() async {
    try {
      await _updateTestStatus('Screen Edge Test', DeviceTestStatus.running);

      final command = FactoryTestCommand(
        type: FactoryTestCommandType.startManualTest,
        command: DeviceCmdUtils.startManualScreenEdgeTest(),
        parameters: {'testType': ManualTestType.manualTestEdge},
      );
      await _executeCommand(command);

      debugPrint('Screen edge test command sent successfully');
    } catch (error) {
      debugPrint('Error starting screen edge test: $error');
      await _updateTestStatus('Screen Edge Test', DeviceTestStatus.fail,
          'Failed to start test: $error');
    }
  }

  Future<void> startScreenBlackTest() async {
    try {
      await _updateTestStatus('Screen Black Test', DeviceTestStatus.running);

      final command = FactoryTestCommand(
        type: FactoryTestCommandType.startManualTest,
        command: DeviceCmdUtils.startManualScreenBlackTest(),
        parameters: {'testType': ManualTestType.manualTestBlackScreen},
      );
      await _executeCommand(command);

      debugPrint('Screen black test command sent successfully');
    } catch (error) {
      debugPrint('Error starting screen black test: $error');
      await _updateTestStatus('Screen Black Test', DeviceTestStatus.fail,
          'Failed to start test: $error');
    }
  }

  Future<void> startScreenWhiteTest() async {
    try {
      await _updateTestStatus('Screen White Test', DeviceTestStatus.running);

      final command = FactoryTestCommand(
        type: FactoryTestCommandType.startManualTest,
        command: DeviceCmdUtils.startManualScreenWhiteTest(),
        parameters: {'testType': ManualTestType.manualTestWhiteScreen},
      );
      await _executeCommand(command);

      debugPrint('Screen white test command sent successfully');
    } catch (error) {
      debugPrint('Error starting screen white test: $error');
      await _updateTestStatus('Screen White Test', DeviceTestStatus.fail,
          'Failed to start test: $error');
    }
  }

  Future<void> startButtonTest() async {
    try {
      await _updateTestStatus('Button Test', DeviceTestStatus.running);

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
          'Button Test', DeviceTestStatus.fail, 'Failed to start test: $error');
    }
  }

  Future<void> startBuzzerTest() async {
    try {
      await _updateTestStatus('Buzzer Test', DeviceTestStatus.running);

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
          'Buzzer Test', DeviceTestStatus.fail, 'Failed to start test: $error');
    }
  }

  Future<void> startVibrationTest() async {
    try {
      await _updateTestStatus('Vibration Test', DeviceTestStatus.running);

      final command = FactoryTestCommand(
        type: FactoryTestCommandType.startManualTest,
        command: DeviceCmdUtils.startManualVibrationTest(),
        parameters: {'testType': ManualTestType.manualTestVibration},
      );
      await _executeCommand(command);

      debugPrint('Vibration test command sent successfully');
    } catch (error) {
      debugPrint('Error starting vibration test: $error');
      await _updateTestStatus('Vibration Test', DeviceTestStatus.fail,
          'Failed to start test: $error');
    }
  }

  /// Helper method to update test status
  Future<void> _updateTestStatus(String testName, DeviceTestStatus status,
      [String? comment]) async {
    final updatedTests = state.manualTests.tests.map((test) {
      if (test.testName == testName) {
        return test.copyWith(
          status: status,
          comment: comment ?? test.comment,
          timestamp: status != DeviceTestStatus.notStarted
              ? DateTime.now()
              : test.timestamp,
          // Device doesn't acknowledge start commands, so we assume they're received
          deviceResponseReceived: status == DeviceTestStatus.running
              ? true
              : test.deviceResponseReceived,
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
            status: confirmed ? DeviceTestStatus.pass : DeviceTestStatus.fail,
            comment: confirmed
                ? '${test.comment ?? ''} - User confirmed'
                : '${test.comment ?? ''} - User marked as failed',
            timestamp: DateTime.now(),
          );
        }
        return test;
      }).toList();

      final allComplete = updatedTests.every((test) =>
          test.status == DeviceTestStatus.pass ||
          test.status == DeviceTestStatus.fail);

      state = state.copyWith(
        manualTests: state.manualTests.copyWith(
          tests: updatedTests,
          userConfirmations: updatedConfirmations,
          isComplete: allComplete,
        ),
      );

      // If all tests are complete, move to completed phase
      if (allComplete && state.automaticTests.isComplete) {
        state = state.copyWith(phase: DeviceFactoryTestPhase.completed);
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
            status: confirmed ? DeviceTestStatus.pass : DeviceTestStatus.fail,
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
    // Reset automatic tests state
    state = state.copyWith(
      automaticTests: AutomaticTestsState(tests: initialAutomaticTests),
      phase: DeviceFactoryTestPhase.connecting,
      connectionState: DeviceFactoryTestConnectionState.connecting,
      error: null,
    );

    // Find and reconnect to the device
    try {
      await _connectToDevice(state.selectedDevice.bluetoothDevice);
    } catch (error) {
      debugPrint('Retry connection error: $error');
      state = state.copyWith(
        phase: DeviceFactoryTestPhase.error,
        connectionState: DeviceFactoryTestConnectionState.error,
        error: 'Retry connection failed: $error',
      );
    }
  }

  /// Send 0xDE command to end factory test mode and restart device in normal mode
  Future<void> endFactoryTestMode({bool putDeviceToSleep = false}) async {
    try {
      debugPrint('Sending 0xDE command to end factory test mode');

      // Set flag to indicate we're ending factory mode (expected disconnection)
      _isEndingFactoryMode = true;

      // Send the factory test end command (0xDE) directly without retry logic
      if (_writeCharacteristic == null) {
        debugPrint('ERROR: Write characteristic not available');
        throw 'Write characteristic not available';
      }

      final commandBytes =
          DeviceCmdUtils.factoryTestEnd(putDeviceToSleep: putDeviceToSleep);

      try {
        await _writeCharacteristic!.write(commandBytes);
        debugPrint('Factory test end command sent successfully');
      } catch (error) {
        debugPrint(
            'Expected error sending factory test end command (device disconnecting): $error');
        // This is expected - device will disconnect immediately after receiving this command
      }

      // Clean up after sending command (device will disconnect)
      _cleanup();

      debugPrint('Factory test end sequence completed');
    } catch (error) {
      debugPrint('Error in factory test end sequence: $error');
      _isEndingFactoryMode = false;
      // Clean up even if command fails
      _cleanup();
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

  /// Reset factory test to start over
  void resetFactoryTest() {
    _clearAutomaticTestTimeout(); // Clear timeout before cleanup
    _cleanup();

    state = DeviceFactoryTestState.emptyState(state.selectedDevice);

    _cleanup();
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

  /// Start connection timeout timer (30 seconds)
  void _startConnectionTimeout() {
    _clearConnectionTimeout(); // Clear any existing timer

    _connectionTimeoutTimer = Timer(const Duration(seconds: 30), () {
      debugPrint(
          'Connection timeout - 30 seconds elapsed without successful connection');
      _handleConnectionTimeout();
    });
  }

  /// Clear connection timeout timer
  void _clearConnectionTimeout() {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
  }

  /// Handle connection timeout
  void _handleConnectionTimeout() {
    if (state.phase != DeviceFactoryTestPhase.connecting &&
        state.phase != DeviceFactoryTestPhase.enteringFactoryMode &&
        state.phase != DeviceFactoryTestPhase.reconnecting) {
      return; // Already connected/completed, ignore timeout
    }

    debugPrint('Connection timed out after 30 seconds');

    state = state.copyWith(
      phase: DeviceFactoryTestPhase.error,
      connectionState: DeviceFactoryTestConnectionState.error,
      error:
          'Connection timed out after 30 seconds. Please check that the device is powered on and nearby, then try again.',
    );

    // Clean up connection
    _cleanup();
  }

  /// Handle automatic test timeout (device connection likely lost)
  void _handleAutomaticTestTimeout() {
    if (state.automaticTests.isComplete) return; // Already completed, ignore

    debugPrint(
        'Automatic tests timed out after 1 minute - device connection appears to be lost');

    // Mark all running tests as failed due to timeout
    final updatedTests = state.automaticTests.tests.map((test) {
      if (test.status == DeviceTestStatus.running ||
          test.status == DeviceTestStatus.notStarted) {
        return test.copyWith(
          status: DeviceTestStatus.fail,
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
      phase: DeviceFactoryTestPhase.error,
      connectionState: DeviceFactoryTestConnectionState.error,
      error:
          'Device connection lost during automatic tests. Please reconnect and try again.',
    );

    // Clean up connection
    _cleanup();
  }

  /// Cleanup resources
  void _cleanup() {
    debugPrint('=== CLEANUP CALLED ===');
    debugPrint('Current _connectedDevice: ${_connectedDevice?.advName}');

    _connectionSubscription?.cancel();
    _notificationSubscription?.cancel();
    _commandTimeoutTimer?.cancel();
    _automaticTestTimeoutTimer?.cancel();
    _connectionTimeoutTimer?.cancel();

    if (_connectedDevice?.isConnected == true) {
      debugPrint('Disconnecting device: ${_connectedDevice?.advName}');
      _connectedDevice?.disconnect();
    }

    debugPrint('Setting _connectedDevice to null');
    _connectedDevice = null;
    _writeCharacteristic = null;
    _notifyCharacteristic = null;
    _commandQueue.clear();
    _isProcessingCommand = false;
    _isEndingFactoryMode = false;
    debugPrint('Cleanup completed');
  }
}
