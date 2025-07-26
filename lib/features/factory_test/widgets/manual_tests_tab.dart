import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManualTestsTab extends ConsumerWidget {
  const ManualTestsTab({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoryTestState = ref.watch(factoryTestProvider(deviceId));
    final manualTests = factoryTestState.manualTests;

    if (!factoryTestState.automaticTests.isComplete) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Complete Automatic Tests First',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manual tests will be available after automatic tests are completed',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            manualTests.isComplete
                ? 'All manual tests completed! Results will be saved locally.'
                : 'Follow the instructions to perform manual tests on the device.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: manualTests.tests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final test = manualTests.tests[index];
                return _buildManualTestCard(context, ref, test);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualTestCard(
      BuildContext context, WidgetRef ref, TestResult test) {
    final isChargeTest = test.testName == 'Charge Test';
    final isCaseCheck = test.testName == 'Case Check';
    final needsManualStart = !isChargeTest && !isCaseCheck;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Main test row - dense layout
            Row(
              children: [
                _buildStatusIcon(test.status),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.testName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getTestDescription(test.testName),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusText(test.status),
              ],
            ),

            // Test controls
            if (test.status != DeviceTestStatus.pass &&
                test.status != DeviceTestStatus.fail) ...[
              const SizedBox(height: 10),
              _buildTestControls(
                  context, ref, test, isChargeTest, needsManualStart),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestControls(BuildContext context, WidgetRef ref,
      TestResult test, bool isChargeTest, bool needsManualStart) {
    // Charge Test: Auto-started, show Pass/Fail immediately
    if (isChargeTest) {
      return _buildPassFailButtons(context, ref, test);
    }

    // Case Check: Visual only, show Pass/Fail immediately
    if (test.testName == 'Case Check') {
      return _buildPassFailButtons(context, ref, test);
    }

    // Other tests: Need manual start first
    if (needsManualStart) {
      if (test.status == DeviceTestStatus.notStarted) {
        return _buildStartButton(ref, test);
      } else {
        return _buildPassFailButtons(context, ref, test);
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildStartButton(WidgetRef ref, TestResult test) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _startTest(ref, test.testName),
        icon: const Icon(Icons.play_arrow, size: 18),
        label: const Text('Start Test'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPassFailButtons(
      BuildContext context, WidgetRef ref, TestResult test) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => ref
                .read(factoryTestProvider(deviceId).notifier)
                .updateUserConfirmation(test.testName, true),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Pass'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showFailDialog(context, ref, test),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Fail'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  void _startTest(WidgetRef ref, String testName) {
    final notifier = ref.read(factoryTestProvider(deviceId).notifier);

    switch (testName) {
      case 'Screen Edge Test':
        notifier.startScreenEdgeTest();
        break;
      case 'Screen Black Test':
        notifier.startScreenBlackTest();
        break;
      case 'Screen White Test':
        notifier.startScreenWhiteTest();
        break;
      case 'Button Test':
        notifier.startButtonTest();
        break;
      case 'Buzzer Test':
        notifier.startBuzzerTest();
        break;
      case 'Vibration Test':
        notifier.startVibrationTest();
        break;
    }
  }

  void _showFailDialog(BuildContext context, WidgetRef ref, TestResult test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark ${test.testName} as Failed'),
        content: const Text(
          'Are you sure you want to mark this test as failed? You can add a comment to explain the issue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(factoryTestProvider(deviceId).notifier)
                  .updateUserConfirmation(test.testName, false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Mark as Failed',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getTestDescription(String testName) {
    switch (testName) {
      case 'Charge Test':
        return 'Connect charger and verify connection/disconnection';
      case 'Screen Edge Test':
        return 'Check if all screen edges are visible clearly';
      case 'Screen Black Test':
        return 'Look for any bright pixels on black screen';
      case 'Screen White Test':
        return 'Look for any dark pixels on white screen';
      case 'Button Test':
        return 'Press device button 3+ times to test responsiveness';
      case 'Buzzer Test':
        return 'Listen for clear beeps from device buzzer';
      case 'Vibration Test':
        return 'Feel for smooth vibration from device motor';
      case 'Case Check':
        return 'Visual inspection: no scratches, cracks, or defects';
      default:
        return 'Manual test';
    }
  }

  Widget _buildStatusIcon(DeviceTestStatus status) {
    switch (status) {
      case DeviceTestStatus.notStarted:
        return const Icon(
          Icons.radio_button_unchecked,
          color: Colors.grey,
          size: 22,
        );
      case DeviceTestStatus.running:
        return const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        );
      case DeviceTestStatus.pass:
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 22,
        );
      case DeviceTestStatus.fail:
        return const Icon(
          Icons.error,
          color: Colors.red,
          size: 22,
        );
    }
  }

  Widget _buildStatusText(DeviceTestStatus status) {
    switch (status) {
      case DeviceTestStatus.notStarted:
        return const Text(
          'Pending',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
      case DeviceTestStatus.running:
        return const Text(
          'Running...',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
      case DeviceTestStatus.pass:
        return const Text(
          'PASS',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
      case DeviceTestStatus.fail:
        return const Text(
          'FAIL',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        );
    }
  }
}
