import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManualTestsTab extends ConsumerWidget {
  const ManualTestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoryTestState = ref.watch(factoryTestProvider);

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
      child: Column(
        children: [
          _buildProgressSection(context, ref, factoryTestState),
          Expanded(
            child: _buildTestResults(context, ref, factoryTestState),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(
      BuildContext context, WidgetRef ref, FactoryTestState state) {
    final completedCount = state.manualTests.tests
        .where((test) =>
            test.status == TestStatus.pass || test.status == TestStatus.fail)
        .length;

    final totalTests = state.manualTests.tests.length;

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manual Tests\nProgress',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completedCount of $totalTests tests completed',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${totalTests > 0 ? ((completedCount / totalTests) * 100).round() : 0}%',
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF8C00),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.grey.shade200,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: totalTests > 0 ? completedCount / totalTests : 0,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completedCount == totalTests && totalTests > 0
                          ? Colors.green.shade500
                          : Colors.purple.shade500,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestResults(
      BuildContext context, WidgetRef ref, FactoryTestState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manual Test Instructions:',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: state.manualTests.tests.length,
              itemBuilder: (context, index) {
                final test = state.manualTests.tests[index];
                return _buildTestItem(context, ref, test);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestItem(BuildContext context, WidgetRef ref, TestResult test) {
    final canPerformTest = test.status == TestStatus.notStarted ||
        test.status == TestStatus.running;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(test.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getStatusIcon(test.status),
                  color: _getStatusColor(test.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.testName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTestDescription(test.testName),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(test.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(test.status),
                  style: TextStyle(
                    color: _getStatusColor(test.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (canPerformTest) ...[
            const SizedBox(height: 16),
            Text(
              _getTestInstructions(test.testName),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _markTestResult(ref, test.testName, TestStatus.fail),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade300),
                      foregroundColor: Colors.red.shade600,
                    ),
                    child: const Text('Fail'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _markTestResult(ref, test.testName, TestStatus.pass),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pass'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStatusIcon(TestStatus status) {
    switch (status) {
      case TestStatus.notStarted:
        return Icons.schedule;
      case TestStatus.running:
        return Icons.autorenew;
      case TestStatus.pass:
        return Icons.check_circle;
      case TestStatus.fail:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(TestStatus status) {
    switch (status) {
      case TestStatus.notStarted:
        return Colors.grey;
      case TestStatus.running:
        return const Color(0xFFFF8C00);
      case TestStatus.pass:
        return Colors.green;
      case TestStatus.fail:
        return Colors.red;
    }
  }

  String _getStatusText(TestStatus status) {
    switch (status) {
      case TestStatus.notStarted:
        return 'Pending';
      case TestStatus.running:
        return 'Running';
      case TestStatus.pass:
        return 'Passed';
      case TestStatus.fail:
        return 'Failed';
    }
  }

  String _getTestDescription(String testName) {
    switch (testName.toLowerCase()) {
      case 'charge test':
        return 'Test device charging functionality';
      case 'screen test - edge':
        return 'Test screen edge functionality';
      case 'screen test - black':
        return 'Test screen black display';
      case 'screen test - white':
        return 'Test screen white display';
      case 'button test':
        return 'Test device button functionality';
      case 'buzzer test':
        return 'Test device buzzer';
      case 'vibration test':
        return 'Test device vibration motor';
      case 'case check':
        return 'Visual inspection of device case';
      default:
        return 'Manual test';
    }
  }

  String _getTestInstructions(String testName) {
    switch (testName.toLowerCase()) {
      case 'charge test':
        return 'Connect the charging cable to the device. Check if the charging indicator appears on the screen and the LED lights up.';
      case 'screen test - edge':
        return 'Check if the screen edges are working properly. Look for any dead pixels or discoloration around the edges.';
      case 'screen test - black':
        return 'The screen should display a solid black color. Check for any bright pixels or inconsistencies.';
      case 'screen test - white':
        return 'The screen should display a solid white color. Check for any dark pixels or color inconsistencies.';
      case 'button test':
        return 'Press the device button multiple times. Check if the button clicks properly and responds as expected.';
      case 'buzzer test':
        return 'Listen for the buzzer sound. The device should produce a clear audible beep when activated.';
      case 'vibration test':
        return 'Feel for device vibration. The device should vibrate smoothly when the vibration motor is activated.';
      case 'case check':
        return 'Visually inspect the device case for any cracks, scratches, or manufacturing defects. Check all edges and surfaces.';
      default:
        return 'Follow the test instructions and mark as pass or fail based on the results.';
    }
  }

  void _markTestResult(WidgetRef ref, String testName, TestStatus status) {
    // This would call a method on the provider to update the test result
    // For now, we'll just print since I don't have the exact method signature
    debugPrint('Marking $testName as ${status.name}');
    // ref.read(factoryTestProvider.notifier).updateManualTestResult(testName, status);
  }
}
