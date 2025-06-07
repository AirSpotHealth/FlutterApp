# Factory Test Implementation Plan for Airspot Health App

## Overview

This document outlines the implementation plan for the factory test feature that allows testing of Airspot devices during manufacturing. The feature includes both automatic electronic tests and manual test procedures **for the Airspot device itself**, with all tests executed via BLE commands and results stored via API.

**Key Clarification**: All tests (both automatic and manual) are tests **of the Airspot device**, not the app. The app serves as a test orchestrator, sending BLE commands to the device and receiving responses.

## Factory Test Flow

### 4-Part Test Flow Structure:

1. **Hidden Door Entry**: User accesses factory test page through secret method
2. **Device Selection**: Display devices sorted by RSSI, user selects device and clicks "Start FT"
3. **3-Tab Test Interface**:
   - **Tab 1 - Automatic Tests**: Show each test result/comment (auto-executed on "Start FT")
   - **Tab 2 - Manual Tests**: User manually starts/checks each test
   - **Tab 3 - User Info & Submission**: Tester details and result submission

## Current Architecture Analysis

### Existing Infrastructure

- **Flutter App**: Material Design with go_router navigation
- **State Management**: Riverpod for state management
- **Local Database**: Isar database for local data storage
- **Bluetooth**: flutter_blue_plus for BLE communication
- **Network**: Dio HTTP client for API calls
- **Current Cloud**: Basic API endpoint at `https://update.airspothealth.com/api`

### Missing Components

- **Factory Test UI**: Hidden test page with 3-tab interface
- **API Integration**: Extended API for factory test data storage
- **Device Test Commands**: BLE commands for electronic self-tests
- **Robust BLE Provider**: Constant bidirectional communication system for device control
- **Device Command Protocol**: Extended BLE protocol for factory test commands

## Implementation Plan

### Phase 1: Infrastructure Setup

#### 1.1 API Service Extension

**File**: `lib/core/services/factory_test_api_service.dart`

- Extend existing `NetworkService` for factory test endpoints
- Factory test result submission API
- Test session management API
- Error handling and retry logic

**API Endpoints**:

```dart
class FactoryTestApiService {
  // Submit complete factory test results
  Future<ApiResponse> submitFactoryTestResult(FactoryTestResult result);

  // Optional: Track test sessions
  Future<ApiResponse> startTestSession(String deviceId, String testerName);
  Future<ApiResponse> endTestSession(String sessionId, TestResult result);

  // Optional: Get test statistics/history
  Future<ApiResponse> getDeviceTestHistory(String deviceId);
}
```

#### 1.2 Create Robust BLE Factory Test Provider

**File**: `lib/features/factory_test/providers/factory_test_ble_provider.dart`

**Critical Requirements**:

- **Constant Connection Management**: Maintain stable BLE connection throughout test session
- **Command Queue System**: Queue and execute BLE commands sequentially
- **Response Handling**: Parse and validate device responses
- **Retry Mechanism**: Robust retry logic for failed commands
- **Timeout Handling**: Proper timeouts for each command type
- **Connection Recovery**: Automatic reconnection on connection loss
- **State Synchronization**: Keep app and device state synchronized

**Provider Architecture**:

```dart
class FactoryTestBleProvider extends StateNotifier<FactoryTestBleState> {
  // Connection management
  Future<bool> connectToDevice(String deviceId);
  Future<void> disconnectDevice();
  Stream<ConnectionStatus> get connectionStatus;

  // Automatic test execution (triggered by "Start FT")
  Future<void> startFactoryTestSession();
  Future<List<TestResult>> runAllAutomaticTests();

  // Individual automatic tests
  Future<TestResult> runSensorTest();
  Future<TestResult> runMemoryTest();
  Future<TestResult> readBatteryVoltage();
  Future<TestResult> testLFCrystal();
  Future<TestResult> testLCDController();

  // Manual test device commands
  Future<bool> displayScreenTest(ScreenTestType type); // Edge/Black/White
  Future<bool> triggerBuzzer(int beepCount);
  Future<bool> triggerVibration(int pulseCount);
  Future<ChargeStatus> getChargeStatus();
  Future<ButtonPressCount> getButtonPressCount();
  Future<bool> resetButtonCounter();

  // Test orchestration
  Future<void> endTestSession();
  Stream<TestProgress> get testProgress;
}
```

#### 1.3 Create Data Models

**File**: `lib/core/models/factory_test_result.dart`

- Model for automatic test results
- Model for manual test results
- Combined factory test result model
- Isar annotations for local storage backup

#### 1.4 BLE Command Protocol Extension

**File**: `lib/features/factory_test/models/ble_commands.dart`

**Extended BLE Command Set**:

```dart
enum FactoryTestCommandType {
  // Session management
  startFactoryTestMode,
  endFactoryTestMode,

  // Electronic self-tests (automatic)
  sensorRead,
  memoryTest,
  batteryVoltageRead,
  lfCrystalTest,
  lcdControllerTest,

  // Manual test device commands
  displayScreenEdgeTest,
  displayScreenBlackTest,
  displayScreenWhiteTest,
  displayNormalScreen,
  triggerBuzzerTest,
  triggerVibrationTest,
  getChargeStatus,
  getButtonPressCount,
  resetButtonCounter,
}

class BleCommand {
  final FactoryTestCommandType type;
  final Map<String, dynamic>? parameters;
  final Duration timeout;
  final int maxRetries;
}

class CommandResponse {
  final bool success;
  final Map<String, dynamic> data;
  final String? error;
}
```

#### 1.5 Environment Configuration

**File**: `lib/core/utils/factory_test_config.dart`

- API endpoints for factory test data
- Test parameters and thresholds
- BLE command timeouts and retry settings
- Environment-specific settings

### Phase 2: Factory Test UI Implementation

#### 2.1 Hidden Door Entry Method

**File**: `lib/features/home/homepage.dart` (modify existing)

**Implementation**: Secret gesture on home page

```dart
// Add to existing HomePage widget
int _tapCount = 0;
Timer? _resetTimer;

void _onLogoTap() {
  _tapCount++;
  _resetTimer?.cancel();

  if (_tapCount >= 5) {
    _showFactoryTestDialog();
    _tapCount = 0;
  } else {
    _resetTimer = Timer(Duration(seconds: 2), () => _tapCount = 0);
  }
}

void _showFactoryTestDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Factory Test Mode'),
      content: Text('Enter factory test mode?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.go('/factory-test');
          },
          child: Text('Enter'),
        ),
      ],
    ),
  );
}
```

#### 2.2 Factory Test Main Page Structure

**File**: `lib/features/factory_test/factory_test_page.dart`

**4-Part Structure**:

```dart
class FactoryTestPage extends StatefulWidget {
  @override
  _FactoryTestPageState createState() => _FactoryTestPageState();
}

class _FactoryTestPageState extends State<FactoryTestPage> {
  FactoryTestPhase _currentPhase = FactoryTestPhase.deviceSelection;
  int _currentTabIndex = 0;
  String? _selectedDeviceId;

  @override
  Widget build(BuildContext context) {
    switch (_currentPhase) {
      case FactoryTestPhase.deviceSelection:
        return DeviceSelectionView(
          onDeviceSelected: _onDeviceSelected,
        );
      case FactoryTestPhase.testing:
        return TestingTabView(
          deviceId: _selectedDeviceId!,
          currentTabIndex: _currentTabIndex,
          onTabChanged: (index) => setState(() => _currentTabIndex = index),
          onTestComplete: _onTestComplete,
        );
    }
  }
}

enum FactoryTestPhase {
  deviceSelection,
  testing,
}
```

#### 2.3 Device Selection View (Part 1)

**File**: `lib/features/factory_test/widgets/device_selection_view.dart`

**Features**:

- Display devices sorted by RSSI (strongest signal first)
- Real-time RSSI updates
- Device connection status
- "Start FT" button that triggers automatic tests

```dart
class DeviceSelectionView extends ConsumerWidget {
  final Function(String deviceId) onDeviceSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(factoryTestDeviceScannerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Factory Test - Select Device')),
      body: Column(
        children: [
          // Scanning status
          ScanningStatusWidget(),

          // Device list sorted by RSSI
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return DeviceListTile(
                  device: device,
                  onStartFactoryTest: () => onDeviceSelected(device.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DeviceListTile extends StatelessWidget {
  final BleDevice device;
  final VoidCallback onStartFactoryTest;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(device.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RSSI: ${device.rssi} dBm'),
            Text('ID: ${device.id}'),
            RSSIIndicator(rssi: device.rssi),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onStartFactoryTest,
          child: Text('Start FT'),
        ),
      ),
    );
  }
}
```

#### 2.4 Testing Tab View (Parts 2-4)

**File**: `lib/features/factory_test/widgets/testing_tab_view.dart`

**3-Tab Interface**:

```dart
class TestingTabView extends ConsumerStatefulWidget {
  final String deviceId;
  final int currentTabIndex;
  final Function(int) onTabChanged;
  final VoidCallback onTestComplete;

  @override
  _TestingTabViewState createState() => _TestingTabViewState();
}

class _TestingTabViewState extends ConsumerState<TestingTabView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Start automatic tests immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(factoryTestBleProvider.notifier)
        .startAutomaticTests(widget.deviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Factory Test - ${widget.deviceId}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Automatic Tests'),
            Tab(text: 'Manual Tests'),
            Tab(text: 'Submit Results'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AutomaticTestsTab(deviceId: widget.deviceId),
          ManualTestsTab(deviceId: widget.deviceId),
          SubmissionTab(deviceId: widget.deviceId),
        ],
      ),
    );
  }
}
```

### Phase 3: Tab Implementation

#### 3.1 Tab 1 - Automatic Tests

**File**: `lib/features/factory_test/widgets/automatic_tests_tab.dart`

**Features**:

- Auto-start when "Start FT" is clicked
- Real-time test progress
- Show each test result with comments
- Pass/Fail indicators

```dart
class AutomaticTestsTab extends ConsumerWidget {
  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(automaticTestsProvider);

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Overall progress
          LinearProgressIndicator(
            value: testState.overallProgress,
          ),
          SizedBox(height: 16),

          // Test results list
          Expanded(
            child: ListView(
              children: [
                AutomaticTestResultCard(
                  testName: 'Sensor Test',
                  testResult: testState.sensorTest,
                ),
                AutomaticTestResultCard(
                  testName: 'CO2 Reading Test',
                  testResult: testState.co2Test,
                ),
                AutomaticTestResultCard(
                  testName: 'Memory Test',
                  testResult: testState.memoryTest,
                ),
                AutomaticTestResultCard(
                  testName: 'Battery Voltage Test',
                  testResult: testState.batteryTest,
                ),
                AutomaticTestResultCard(
                  testName: 'LF Crystal Test',
                  testResult: testState.lfCrystalTest,
                ),
                AutomaticTestResultCard(
                  testName: 'LCD Controller Test',
                  testResult: testState.lcdTest,
                ),
              ],
            ),
          ),

          // Navigation
          if (testState.isComplete)
            ElevatedButton(
              onPressed: () => _moveToManualTests(context),
              child: Text('Continue to Manual Tests'),
            ),
        ],
      ),
    );
  }
}

class AutomaticTestResultCard extends StatelessWidget {
  final String testName;
  final TestResult? testResult;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(testName),
        subtitle: testResult != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${testResult!.status}'),
                if (testResult!.comment.isNotEmpty)
                  Text('Comment: ${testResult!.comment}'),
                if (testResult!.value != null)
                  Text('Value: ${testResult!.value}'),
              ],
            )
          : Text('Running...'),
        trailing: testResult != null
          ? Icon(
              testResult!.status == 'Pass'
                ? Icons.check_circle
                : Icons.error,
              color: testResult!.status == 'Pass'
                ? Colors.green
                : Colors.red,
            )
          : CircularProgressIndicator(),
      ),
    );
  }
}
```

#### 3.2 Tab 2 - Manual Tests

**File**: `lib/features/factory_test/widgets/manual_tests_tab.dart`

**Features**:

- User manually starts each test
- BLE commands to device for each test
- User confirmation checkboxes
- Step-by-step instructions

```dart
class ManualTestsTab extends ConsumerWidget {
  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manualTestState = ref.watch(manualTestsProvider);

    return Padding(
      padding: EdgeInsets.all(16),
      child: ListView(
        children: [
          ManualTestCard(
            testName: 'Charge Test',
            instructions: 'Disconnect and reconnect USB cable',
            onStartTest: () => ref.read(manualTestsProvider.notifier)
              .startChargeTest(),
            testResult: manualTestState.chargeTest,
          ),

          ManualTestCard(
            testName: 'Screen Edge Test',
            instructions: 'Check that device displays fine outline and all edges are visible',
            onStartTest: () => ref.read(manualTestsProvider.notifier)
              .startScreenEdgeTest(),
            testResult: manualTestState.screenEdgeTest,
            hasUserConfirmation: true,
            confirmationText: 'All edges are visible',
          ),

          ManualTestCard(
            testName: 'Screen Black Test',
            instructions: 'Check that device screen displays all black',
            onStartTest: () => ref.read(manualTestsProvider.notifier)
              .startScreenBlackTest(),
            testResult: manualTestState.screenBlackTest,
            hasUserConfirmation: true,
            confirmationText: 'Screen is all black',
          ),

          ManualTestCard(
            testName: 'Screen White Test',
            instructions: 'Check that device screen displays all white',
            onStartTest: () => ref.read(manualTestsProvider.notifier)
              .startScreenWhiteTest(),
            testResult: manualTestState.screenWhiteTest,
            hasUserConfirmation: true,
            confirmationText: 'Screen is all white',
          ),

          ManualTestCard(
            testName: 'Button Test',
            instructions: 'Press device button 3 times',
            onStartTest: () => ref.read(manualTestsProvider.notifier)
              .startButtonTest(),
            testResult: manualTestState.buttonTest,
            hasUserConfirmation: true,
            confirmationText: 'Button feels good and registered 3 presses',
          ),

          ManualTestCard(
            testName: 'Buzzer Test',
            instructions: 'Listen for 3 beeps from device',
            onStartTest: () => ref.read(manualTestsProvider.notifier)
              .startBuzzerTest(),
            testResult: manualTestState.buzzerTest,
            hasUserConfirmation: true,
            confirmationText: 'Buzzer sounds good',
          ),

          ManualTestCard(
            testName: 'Vibration Test',
            instructions: 'Feel for 3 vibrations from device',
            onStartTest: () => ref.read(manualTestsProvider.notifier)
              .startVibrationTest(),
            testResult: manualTestState.vibrationTest,
            hasUserConfirmation: true,
            confirmationText: 'Vibration feels good',
          ),

          ManualTestCard(
            testName: 'Case Check',
            instructions: 'Visual inspection: clean, no scratches, USB aligns with hole',
            onStartTest: null, // No BLE command needed
            testResult: manualTestState.caseCheck,
            hasUserConfirmation: true,
            confirmationText: 'Case looks good',
            isVisualOnly: true,
          ),

          SizedBox(height: 32),

          if (manualTestState.allTestsComplete)
            ElevatedButton(
              onPressed: () => _moveToSubmission(context),
              child: Text('Continue to Submission'),
            ),
        ],
      ),
    );
  }
}

class ManualTestCard extends StatefulWidget {
  final String testName;
  final String instructions;
  final VoidCallback? onStartTest;
  final TestResult? testResult;
  final bool hasUserConfirmation;
  final String? confirmationText;
  final bool isVisualOnly;

  @override
  _ManualTestCardState createState() => _ManualTestCardState();
}

class _ManualTestCardState extends State<ManualTestCard> {
  bool _userConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.testName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(widget.instructions),
            SizedBox(height: 16),

            // Start test button
            if (widget.onStartTest != null && widget.testResult?.status != 'Pass')
              ElevatedButton(
                onPressed: widget.testResult?.status == 'Running'
                  ? null
                  : widget.onStartTest,
                child: Text(
                  widget.testResult?.status == 'Running'
                    ? 'Running...'
                    : 'Start Test'
                ),
              ),

            // Visual only test button
            if (widget.isVisualOnly && widget.testResult?.status != 'Pass')
              ElevatedButton(
                onPressed: () => setState(() => _userConfirmed = true),
                child: Text('Mark as Inspected'),
              ),

            // User confirmation checkbox
            if (widget.hasUserConfirmation &&
                (widget.testResult?.deviceResponseReceived == true || widget.isVisualOnly))
              CheckboxListTile(
                title: Text(widget.confirmationText ?? ''),
                value: _userConfirmed,
                onChanged: (value) => setState(() => _userConfirmed = value ?? false),
              ),

            // Test status
            if (widget.testResult != null)
              Row(
                children: [
                  Icon(
                    widget.testResult!.status == 'Pass'
                      ? Icons.check_circle
                      : widget.testResult!.status == 'Running'
                        ? Icons.hourglass_empty
                        : Icons.error,
                    color: widget.testResult!.status == 'Pass'
                      ? Colors.green
                      : widget.testResult!.status == 'Running'
                        ? Colors.orange
                        : Colors.red,
                  ),
                  SizedBox(width: 8),
                  Text('Status: ${widget.testResult!.status}'),
                ],
              ),

            if (widget.testResult?.comment?.isNotEmpty == true)
              Text('Comment: ${widget.testResult!.comment}'),
          ],
        ),
      ),
    );
  }
}
```

#### 3.3 Tab 3 - User Info & Submission

**File**: `lib/features/factory_test/widgets/submission_tab.dart`

**Features**:

- Tester name input
- Test summary display
- Submit to API
- Generate report option

```dart
class SubmissionTab extends ConsumerStatefulWidget {
  final String deviceId;

  @override
  _SubmissionTabState createState() => _SubmissionTabState();
}

class _SubmissionTabState extends ConsumerState<SubmissionTab> {
  final TextEditingController _testerNameController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final automaticTests = ref.watch(automaticTestsProvider);
    final manualTests = ref.watch(manualTestsProvider);
    final submissionState = ref.watch(testSubmissionProvider);

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Summary',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),

          // Test summary cards
          TestSummaryCard(
            title: 'Automatic Tests',
            passCount: automaticTests.passCount,
            totalCount: automaticTests.totalCount,
          ),

          TestSummaryCard(
            title: 'Manual Tests',
            passCount: manualTests.passCount,
            totalCount: manualTests.totalCount,
          ),

          SizedBox(height: 24),

          // Tester information
          Text(
            'Tester Information',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 16),

          TextField(
            controller: _testerNameController,
            decoration: InputDecoration(
              labelText: 'Tester Name *',
              border: OutlineInputBorder(),
            ),
          ),

          SizedBox(height: 16),

          TextField(
            controller: _commentsController,
            decoration: InputDecoration(
              labelText: 'Additional Comments',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          Spacer(),

          // Submission buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _generateReport,
                  child: Text('Generate Report'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _canSubmit() ? _submitResults : null,
                  child: submissionState.isLoading
                    ? CircularProgressIndicator()
                    : Text('Submit Results'),
                ),
              ),
            ],
          ),

          if (submissionState.hasError)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'Error: ${submissionState.error}',
                style: TextStyle(color: Colors.red),
              ),
            ),

          if (submissionState.isSuccess)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'Results submitted successfully!',
                style: TextStyle(color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  bool _canSubmit() {
    return _testerNameController.text.isNotEmpty &&
           ref.read(automaticTestsProvider).isComplete &&
           ref.read(manualTestsProvider).isComplete;
  }

  void _submitResults() {
    final result = FactoryTestResult(
      deviceId: widget.deviceId,
      testerName: _testerNameController.text,
      comments: _commentsController.text,
      automaticTests: ref.read(automaticTestsProvider).results,
      manualTests: ref.read(manualTestsProvider).results,
      testDate: DateTime.now(),
    );

    ref.read(testSubmissionProvider.notifier).submitResults(result);
  }

  void _generateReport() {
    // Generate PDF/text report
    ref.read(factoryTestReportProvider.notifier)
      .generateReport(widget.deviceId);
  }
}

class TestSummaryCard extends StatelessWidget {
  final String title;
  final int passCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final isAllPass = passCount == totalCount;

    return Card(
      color: isAllPass ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isAllPass ? Icons.check_circle : Icons.error,
              color: isAllPass ? Colors.green : Colors.red,
              size: 32,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('$passCount/$totalCount tests passed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Phase 4: Robust BLE Communication System

#### 4.1 Connection Management

**File**: `lib/features/factory_test/services/ble_connection_manager.dart`

**Key Features**:

- **Persistent Connection**: Maintain stable connection throughout test session
- **Connection Quality Monitoring**: RSSI tracking, packet loss detection
- **Automatic Reconnection**: Recovery from connection drops
- **Session Management**: Proper connection lifecycle management

#### 4.2 Command Queue System

**File**: `lib/features/factory_test/services/ble_command_queue.dart`

**Features**:

- **Sequential Command Execution**: Prevent command conflicts
- **Priority Queue**: Critical commands get priority
- **Response Correlation**: Match commands with responses
- **Timeout Management**: Per-command timeout handling
- **Retry Logic**: Intelligent retry with backoff

#### 4.3 API Integration

**File**: `lib/features/factory_test/services/factory_test_api_service.dart`

**API Endpoints**:

```dart
class FactoryTestApiService extends NetworkService {
  static const String _baseEndpoint = '/factory-test';

  Future<ApiResponse> submitTestResults(FactoryTestResult result) async {
    return await post('$_baseEndpoint/results', result.toJson());
  }

  Future<ApiResponse> getTestHistory(String deviceId) async {
    return await get('$_baseEndpoint/history/$deviceId', {});
  }
}
```

**Expected JSON Format for API**:

```json
{
  "deviceId": "AirSpot-ABC123",
  "deviceSerial": "SCD40A1B2C3D4E5F6",
  "testDate": "2025-01-15T10:30:00Z",
  "testerName": "John Doe",
  "overallStatus": "Pass",
  "testDurationSeconds": 285,
  "automaticTests": [
    {
      "testName": "Sensor Read",
      "status": "Pass",
      "comment": "Serial: SCD40A1B2C3D4E5F6, Type: SCD40",
      "value": null
    },
    {
      "testName": "Memory Read/Write",
      "status": "Pass",
      "comment": "",
      "value": null
    },
    {
      "testName": "Battery voltage Read",
      "status": "Pass",
      "comment": "3400mV",
      "value": 3400
    },
    {
      "testName": "LF Xtal Status",
      "status": "Pass",
      "comment": "37.768KHz",
      "value": 37.768
    }
  ],
  "manualTests": [
    {
      "testName": "Charge Test",
      "status": "Pass",
      "comment": "Charging and Disconnecting detected",
      "userConfirmed": true
    },
    {
      "testName": "Screen Edge Test",
      "status": "Pass",
      "comment": "All Edges are clear",
      "userConfirmed": true
    },
    {
      "testName": "Screen Black Test",
      "status": "Pass",
      "comment": "All Black",
      "userConfirmed": true
    },
    {
      "testName": "Screen White Test",
      "status": "Pass",
      "comment": "All White",
      "userConfirmed": true
    },
    {
      "testName": "Button Test",
      "status": "Pass",
      "comment": "Button working - 3 presses detected",
      "userConfirmed": true
    }
  ],
  "comments": "Additional tester notes here"
}
```

## Updated Implementation Timeline

### Week 1-2: Infrastructure

- [ ] Extend API service for factory test endpoints
- [ ] Create robust BLE factory test provider
- [ ] Create basic data models and command protocol
- [ ] Set up hidden door entry method

### Week 3-4: Core UI Flow

- [ ] Create device selection view with RSSI sorting
- [ ] Implement 3-tab interface structure
- [ ] Basic BLE connection and device communication
- [ ] Automatic test execution framework

### Week 5-6: Test Implementation

- [ ] Implement automatic tests tab with real-time results
- [ ] Create manual tests tab with BLE device commands
- [ ] Implement submission tab with API integration
- [ ] Test validation and error handling

### Week 7-8: Polish and Integration

- [ ] Robust BLE communication with retry logic
- [ ] API integration and data synchronization
- [ ] Report generation and sharing
- [ ] Comprehensive error handling

### Week 9-10: Testing and Deployment

- [ ] Factory environment testing
- [ ] Performance optimization
- [ ] Final testing with real devices
- [ ] Documentation and deployment

## Technical Considerations (Updated)

### BLE Communication Reliability

- **Connection Stability**: Maintain robust connection throughout 5+ minute test session
- **Command Reliability**: 99.9% successful command execution rate
- **Response Time**: < 2 second average response time per command
- **Error Recovery**: Automatic recovery from communication failures

### User Experience Flow

- **Seamless Progression**: Clear progression from device selection → automatic tests → manual tests → submission
- **Real-time Feedback**: Immediate visual feedback for all test results
- **Error Handling**: Clear error messages and recovery options
- **Fast Execution**: Complete test cycle within 5 minutes

### API Integration

- **Reliable Uploads**: Retry mechanism for failed API calls
- **Offline Support**: Local storage backup when API is unavailable
- **Data Validation**: Ensure data integrity before submission
- **Performance**: Fast submission without blocking UI

This updated plan now reflects the specific 4-part flow you outlined and uses API integration instead of Supabase, providing a clear, structured approach to factory testing.
