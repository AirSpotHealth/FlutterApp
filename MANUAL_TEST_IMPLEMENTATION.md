# Manual Test Implementation - Robust BLE Command System

## Overview

The manual test system has been completely refactored to use a robust BLE command protocol that matches the device's expected command structure. This implementation provides reliable test execution, proper device communication, and enhanced error handling.

## Key Features

### 1. **Robust Command Protocol**

- Proper command structure: `[0xFF, 0xFE, length, command, data, checksum]`
- Automatic checksum calculation for data integrity
- Test type constants matching device firmware
- Separate start and confirmation commands

### 2. **Manual Test Types**

```dart
class ManualTestType {
  static const int MANUAL_TEST_CHARGE = 6;
  static const int MANUAL_TEST_EDGE = 7;
  static const int MANUAL_TEST_BLACK = 8;
  static const int MANUAL_TEST_WHITE = 9;
  static const int MANUAL_TEST_BUTTON = 10;
  static const int MANUAL_TEST_BUZZER = 11;
  static const int MANUAL_TEST_VIBRATION = 12;
  static const int MANUAL_TEST_CASE_CHECK = 13;
}
```

### 3. **Command Structure**

#### Start Test Command (0xD2)

```dart
// Protocol: [0xFF, 0xFE, 0x05, 0xD2, testType, checksum]
List<int> buildStartTestCommand(int testType) {
  return [0xFF, 0xFE, 0x05, 0xD2, testType, calculateChecksum()];
}
```

#### Confirmation Command (0xD3)

```dart
// Protocol: [0xFF, 0xFE, 0x05, 0xD3, passed ? 1 : 0, checksum]
List<int> buildConfirmCommand(bool passed) {
  return [0xFF, 0xFE, 0x05, 0xD3, passed ? 1 : 0, calculateChecksum()];
}
```

## Implementation Details

### 1. **ManualTestCommandBuilder Class**

Located in `lib/features/factory_test/models/factory_test_commands.dart`

**Key Methods:**

- `buildStartTestCommand(int testType)` - Creates start test commands
- `buildConfirmCommand(bool passed)` - Creates confirmation commands
- `calculateChecksum(List<int> command)` - XOR checksum calculation
- Helper methods for each specific test type

**Usage Example:**

```dart
// Start screen edge test
final command = ManualTestCommandBuilder.startScreenEdgeTest();
await _executeCommand(FactoryTestCommand(
  type: FactoryTestCommandType.startManualTest,
  command: command,
));

// Confirm test passed
final confirmCommand = ManualTestCommandBuilder.confirmTestPassed();
await _executeCommand(FactoryTestCommand(
  type: FactoryTestCommandType.confirmManualTest,
  command: confirmCommand,
));
```

### 2. **Enhanced Factory Test Provider**

Located in `lib/features/factory_test/providers/factory_test_provider.dart`

**New Features:**

- Robust error handling with try-catch blocks
- Proper test status updates during execution
- Device response handling for new command protocol
- Comment management system
- Automatic status tracking

**Key Methods:**

```dart
// Start manual tests
Future<void> startChargeTest()
Future<void> startScreenEdgeTest()
Future<void> startScreenBlackTest()
Future<void> startScreenWhiteTest()
Future<void> startButtonTest()
Future<void> startBuzzerTest()
Future<void> startVibrationTest()

// User interaction
Future<void> updateUserConfirmation(String testName, bool confirmed)
void updateTestComment(String testName, String comment)

// Internal helpers
Future<void> _updateTestStatus(String testName, TestStatus status, [String? comment])
void _handleManualTestStartedResponse(List<int> data)
void _handleManualTestConfirmationResponse(List<int> data)
String _getTestNameFromType(int testType)
```

### 3. **Dense UI Implementation**

Located in `lib/features/factory_test/widgets/manual_tests_view.dart`

**Features:**

- Compact card layout similar to automatic tests
- Smart control visibility (only show when needed)
- Contextual button display based on test requirements
- Enhanced comment system with edit dialog
- Visual status indicators and progress tracking

**Test Control Logic:**

```dart
// Tests requiring manual device commands
final needsManualStart = [
  'Screen Edge Test',
  'Screen Black Test',
  'Screen White Test',
  'Buzzer Test',
  'Vibration Test',
  'Button Test'
].contains(test.testName);
```

## Test Flow

### 1. **Starting a Manual Test**

1. User taps "Start" button for a test
2. App sends start command to device: `[0xFF, 0xFE, 0x05, 0xD2, testType, checksum]`
3. Device responds with confirmation: `[0xFF, 0xFE, 0x05, 0xD2, testType, checksum]`
4. Test status updates to "Running" with device response received
5. User performs manual verification
6. Pass/Fail buttons become available

### 2. **Confirming Test Result**

1. User taps "Pass" or "Fail" button
2. App sends confirmation command: `[0xFF, 0xFE, 0x05, 0xD3, passed, checksum]`
3. Device responds with acknowledgment
4. Test status updates to Pass/Fail
5. Comment section becomes available if needed

### 3. **Error Handling**

- Command timeouts with automatic retry logic
- Graceful degradation if device communication fails
- Local state updates even if device commands fail
- Clear error messages and status indicators

## Device Response Handling

### Response Parsing

```dart
void _handleNotification(List<int> data) {
  final commandByte = data[2];

  switch (commandByte) {
    case 0xD2: // Manual test started response
      _handleManualTestStartedResponse(data);
      break;
    case 0xD3: // Manual test confirmation response
      _handleManualTestConfirmationResponse(data);
      break;
    // ... other responses
  }
}
```

### Test Type Mapping

```dart
String _getTestNameFromType(int testType) {
  switch (testType) {
    case ManualTestType.MANUAL_TEST_CHARGE: return 'Charge Test';
    case ManualTestType.MANUAL_TEST_EDGE: return 'Screen Edge Test';
    // ... other mappings
  }
}
```

## Benefits

### 1. **Reliability**

- Proper command checksums prevent data corruption
- Robust error handling with retry logic
- Device acknowledgment for all commands
- Graceful degradation on communication failures

### 2. **User Experience**

- Dense, clean UI similar to automatic tests
- Smart control visibility
- Real-time status updates
- Easy comment management

### 3. **Maintainability**

- Clear separation of concerns
- Proper command abstraction
- Comprehensive error handling
- Easy to extend for new test types

### 4. **Debugging**

- Detailed logging for all commands
- Clear error messages
- Status tracking throughout test lifecycle
- Command/response tracing

## Usage Instructions

1. **Starting Manual Tests:**

   - Navigate to manual tests tab
   - Tests requiring device commands show "Start" button
   - Visual-only tests (Case Check) show immediate Pass/Fail options

2. **Executing Tests:**

   - Tap "Start" to send command to device
   - Wait for device response (spinning indicator)
   - Perform manual verification
   - Tap "Pass" or "Fail" based on results

3. **Adding Comments:**

   - Tap comment section to add notes
   - Required for failed tests
   - Optional for passed tests

4. **Special Controls:**
   - Screen White Test includes "Normal" button to return screen to normal
   - Case Check requires no device commands (visual inspection only)

This implementation provides a robust, reliable, and user-friendly manual test system that properly communicates with the device firmware using the expected command protocol.
