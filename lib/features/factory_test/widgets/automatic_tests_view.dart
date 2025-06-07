import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AutomaticTestsView extends ConsumerWidget {
  const AutomaticTestsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoryTestState = ref.watch(factoryTestProvider);
    final automaticTests = factoryTestState.automaticTests;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Automatic Tests',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            automaticTests.isRunning
                ? 'Running automatic tests on the device...'
                : automaticTests.isComplete
                    ? 'All automatic tests completed!'
                    : 'Preparing to run automatic tests...',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Progress indicator
          if (automaticTests.isRunning || automaticTests.isComplete)
            _buildProgressIndicator(automaticTests),

          const SizedBox(height: 24),

          // Test results
          Expanded(
            child: ListView.separated(
              itemCount: automaticTests.tests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final test = automaticTests.tests[index];
                return _buildTestCard(test);
              },
            ),
          ),

          // Continue button
          if (automaticTests.isComplete)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: factoryTestState.canProceedToManualTests
                      ? () {
                          // The provider will automatically transition to manual tests
                          // when automatic tests are complete
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Proceed to Manual Tests',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(AutomaticTestsState automaticTests) {
    final progress = automaticTests.overallProgress;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress: ${automaticTests.passCount}/${automaticTests.totalCount}',
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
            automaticTests.isComplete ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildTestCard(TestResult test) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildStatusIcon(test.status),
            const SizedBox(width: 16),
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
                  if (test.comment != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      test.comment!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  if (test.timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Completed: ${_formatTimestamp(test.timestamp!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildStatusText(test.status),
          ],
        ),
      ),
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

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }
}
