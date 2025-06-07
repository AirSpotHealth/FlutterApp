import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManualTestsView extends ConsumerWidget {
  const ManualTestsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoryTestState = ref.watch(factoryTestProvider);
    final manualTests = factoryTestState.manualTests;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manual Tests',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            manualTests.isComplete
                ? 'All manual tests completed!'
                : 'Follow the instructions to perform manual tests on the device.',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Progress indicator
          _buildProgressIndicator(manualTests),

          const SizedBox(height: 24),

          // Test list
          Expanded(
            child: ListView.separated(
              itemCount: manualTests.tests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final test = manualTests.tests[index];
                return _buildManualTestCard(context, ref, test);
              },
            ),
          ),

          // Complete button
          if (manualTests.isComplete)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // The provider will automatically transition to completed phase
                    // when all tests are complete
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'All Tests Complete!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ManualTestsState manualTests) {
    final progress = manualTests.totalCount > 0
        ? manualTests.passCount / manualTests.totalCount
        : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress: ${manualTests.passCount}/${manualTests.totalCount}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            manualTests.isComplete ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildManualTestCard(
      BuildContext context, WidgetRef ref, TestResult test) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(test.status),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    test.testName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusText(test.status),
              ],
            ),
            const SizedBox(height: 16),

            // Test instructions and controls
            _buildTestInstructions(context, ref, test),

            if (test.comment != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  test.comment!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestInstructions(
      BuildContext context, WidgetRef ref, TestResult test) {
    switch (test.testName) {
      case 'Charge Test':
        return _buildChargeTestInstructions(context, ref, test);
      case 'Screen Edge Test':
        return _buildScreenEdgeTestInstructions(context, ref, test);
      case 'Screen Black Test':
        return _buildScreenBlackTestInstructions(context, ref, test);
      case 'Screen White Test':
        return _buildScreenWhiteTestInstructions(context, ref, test);
      case 'Button Test':
        return _buildButtonTestInstructions(context, ref, test);
      case 'Buzzer Test':
        return _buildBuzzerTestInstructions(context, ref, test);
      case 'Vibration Test':
        return _buildVibrationTestInstructions(context, ref, test);
      case 'Case Check':
        return _buildCaseCheckInstructions(context, ref, test);
      default:
        return const Text('Unknown test');
    }
  }

  Widget _buildChargeTestInstructions(
      BuildContext context, WidgetRef ref, TestResult test) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. Connect the device to a USB charger'),
        const Text('2. Check the charging indicator'),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: test.status == TestStatus.notStarted
                  ? () =>
                      ref.read(factoryTestProvider.notifier).startChargeTest()
                  : null,
              child: const Text('Test Charge Status'),
            ),
            const SizedBox(width: 12),
            if (test.deviceResponseReceived)
              _buildConfirmationButtons(context, ref, test),
          ],
        ),
      ],
    );
  }

  Widget _buildScreenEdgeTestInstructions(
      BuildContext context, WidgetRef ref, TestResult test) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. Tap "Start Test" to display edge pattern'),
        const Text('2. Check if all edges of the screen are visible'),
        const Text('3. Confirm if the test passes'),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: test.status == TestStatus.notStarted
                  ? () => ref
                      .read(factoryTestProvider.notifier)
                      .startScreenEdgeTest()
                  : null,
              child: const Text('Start Test'),
            ),
            const SizedBox(width: 12),
            if (test.deviceResponseReceived)
              _buildConfirmationButtons(context, ref, test),
          ],
        ),
      ],
    );
  }

  Widget _buildScreenBlackTestInstructions(
      BuildContext context, WidgetRef ref, TestResult test) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. Tap "Start Test" to display black screen'),
        const Text('2. Check for any bright pixels or defects'),
        const Text('3. Confirm if the screen is completely black'),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: test.status == TestStatus.notStarted
                  ? () => ref
                      .read(factoryTestProvider.notifier)
                      .startScreenBlackTest()
                  : null,
              child: const Text('Start Test'),
            ),
            const SizedBox(width: 12),
            if (test.deviceResponseReceived)
              _buildConfirmationButtons(context, ref, test),
          ],
        ),
      ],
    );
  }

  Widget _buildScreenWhiteTestInstructions(
      BuildContext context, WidgetRef ref, TestResult test) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. Tap "Start Test" to display white screen'),
        const Text('2. Check for any dark pixels or defects'),
        const Text('3. Confirm if the screen is completely white'),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: test.status == TestStatus.notStarted
                  ? () => ref
                      .read(factoryTestProvider.notifier)
                      .startScreenWhiteTest()
                  : null,
              child: const Text('Start Test'),
            ),
            const SizedBox(width: 12),
            if (test.deviceResponseReceived)
              _buildConfirmationButtons(context, ref, test),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () =>
                  ref.read(factoryTestProvider.notifier).returnToNormalScreen(),
              child: const Text('Return to Normal'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtonTestInstructions(
      BuildContext context, WidgetRef ref, TestResult test) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. Tap "Start Test" to begin button test'),
        const Text('2. Press the device button at least 3 times'),
        const Text(
            '3. The test will automatically pass when enough presses are detected'),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: test.status == TestStatus.notStarted
              ? () => ref.read(factoryTestProvider.notifier).startButtonTest()
              : null,
          child: const Text('Start Test'),
        ),
      ],
    );
  }

  Widget _buildBuzzerTestInstructions(
      BuildContext context, WidgetRef ref, TestResult test) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. Tap "Start Test" to play buzzer sounds'),
        const Text('2. Listen for 3 beeps from the device'),
        const Text('3. Confirm if you heard the sounds clearly'),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: test.status == TestStatus.notStarted
                  ? () =>
                      ref.read(factoryTestProvider.notifier).startBuzzerTest()
                  : null,
              child: const Text('Start Test'),
            ),
            const SizedBox(width: 12),
            if (test.deviceResponseReceived)
              _buildConfirmationButtons(context, ref, test),
          ],
        ),
      ],
    );
  }

  Widget _buildVibrationTestInstructions(
      BuildContext context, WidgetRef ref, TestResult test) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. Tap "Start Test" to activate vibration'),
        const Text('2. Feel for vibration from the device'),
        const Text('3. Confirm if the vibration works properly'),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              onPressed: test.status == TestStatus.notStarted
                  ? () => ref
                      .read(factoryTestProvider.notifier)
                      .startVibrationTest()
                  : null,
              child: const Text('Start Test'),
            ),
            const SizedBox(width: 12),
            if (test.deviceResponseReceived)
              _buildConfirmationButtons(context, ref, test),
          ],
        ),
      ],
    );
  }

  Widget _buildCaseCheckInstructions(
      BuildContext context, WidgetRef ref, TestResult test) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. Visually inspect the device case'),
        const Text('2. Check for cracks, scratches, or defects'),
        const Text('3. Ensure all parts are properly assembled'),
        const SizedBox(height: 12),
        _buildConfirmationButtons(context, ref, test),
      ],
    );
  }

  Widget _buildConfirmationButtons(
      BuildContext context, WidgetRef ref, TestResult test) {
    if (test.status == TestStatus.pass) {
      return const Text(
        'PASSED',
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      children: [
        ElevatedButton(
          onPressed: () => ref
              .read(factoryTestProvider.notifier)
              .updateUserConfirmation(test.testName, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Pass'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => ref
              .read(factoryTestProvider.notifier)
              .updateUserConfirmation(test.testName, false),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Fail'),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(TestStatus status) {
    switch (status) {
      case TestStatus.notStarted:
        return const Icon(
          Icons.radio_button_unchecked,
          color: Colors.grey,
          size: 24,
        );
      case TestStatus.running:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        );
      case TestStatus.pass:
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 24,
        );
      case TestStatus.fail:
        return const Icon(
          Icons.error,
          color: Colors.red,
          size: 24,
        );
    }
  }

  Widget _buildStatusText(TestStatus status) {
    switch (status) {
      case TestStatus.notStarted:
        return const Text(
          'Pending',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        );
      case TestStatus.running:
        return const Text(
          'Running...',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        );
      case TestStatus.pass:
        return const Text(
          'PASS',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        );
      case TestStatus.fail:
        return const Text(
          'FAIL',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }
}
