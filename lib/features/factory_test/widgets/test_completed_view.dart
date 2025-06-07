import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestCompletedView extends ConsumerWidget {
  const TestCompletedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoryTestState = ref.watch(factoryTestProvider);
    final automaticTests = factoryTestState.automaticTests;
    final manualTests = factoryTestState.manualTests;

    final totalTests = automaticTests.totalCount + manualTests.totalCount;
    final totalPassed = automaticTests.passCount + manualTests.passCount;
    final allTestsPassed = totalPassed == totalTests;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Success/Failure Icon
          Icon(
            allTestsPassed ? Icons.check_circle : Icons.error,
            size: 80,
            color: allTestsPassed ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            allTestsPassed ? 'Factory Test Completed!' : 'Factory Test Failed',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: allTestsPassed ? Colors.green : Colors.red,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Summary
          Text(
            allTestsPassed
                ? 'All tests passed successfully. The device is ready for use.'
                : 'Some tests failed. Please review the results and retest if necessary.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Test Summary Cards
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTestSummaryCard(
                    'Automatic Tests',
                    automaticTests.passCount,
                    automaticTests.totalCount,
                    automaticTests.tests,
                  ),
                  const SizedBox(height: 16),
                  _buildTestSummaryCard(
                    'Manual Tests',
                    manualTests.passCount,
                    manualTests.totalCount,
                    manualTests.tests,
                  ),
                  const SizedBox(height: 32),
                  _buildOverallSummary(totalPassed, totalTests, allTestsPassed),
                ],
              ),
            ),
          ),

          // Action Buttons
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      ref.read(factoryTestProvider.notifier).resetFactoryTest(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Test Another Device'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        allTestsPassed ? Colors.green : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Exit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestSummaryCard(
      String title, int passed, int total, List<TestResult> tests) {
    final allPassed = passed == total;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allPassed ? Icons.check_circle : Icons.error,
                  color: allPassed ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$passed/$total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: allPassed ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Individual test results
            ...tests.map((test) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        test.status == TestStatus.pass
                            ? Icons.check
                            : Icons.close,
                        color: test.status == TestStatus.pass
                            ? Colors.green
                            : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          test.testName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        test.status == TestStatus.pass ? 'PASS' : 'FAIL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: test.status == TestStatus.pass
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallSummary(int totalPassed, int totalTests, bool allPassed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: allPassed ? Colors.green.shade50 : Colors.red.shade50,
        border: Border.all(
          color: allPassed ? Colors.green : Colors.red,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Overall Result',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: allPassed ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalPassed out of $totalTests tests passed',
            style: TextStyle(
              fontSize: 16,
              color: allPassed ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            allPassed ? 'DEVICE APPROVED' : 'DEVICE REJECTED',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: allPassed ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
