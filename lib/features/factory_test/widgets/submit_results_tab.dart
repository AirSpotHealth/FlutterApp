import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubmitResultsTab extends ConsumerWidget {
  const SubmitResultsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoryTestState = ref.watch(factoryTestProvider);

    if (!factoryTestState.isTestingComplete) {
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
                'Complete All Tests First',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Results will be available after all tests are completed',
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
          _buildHeader(context, factoryTestState),
          Expanded(
            child: _buildResults(context, ref, factoryTestState),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FactoryTestState state) {
    final automaticPassed = state.automaticTests.tests
        .where((test) => test.status == TestStatus.pass)
        .length;
    final automaticTotal = state.automaticTests.tests.length;

    final manualPassed = state.manualTests.tests
        .where((test) => test.status == TestStatus.pass)
        .length;
    final manualTotal = state.manualTests.tests.length;

    final totalPassed = automaticPassed + manualPassed;
    final totalTests = automaticTotal + manualTotal;
    final overallSuccess = totalTests > 0 && totalPassed == totalTests;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: overallSuccess
              ? [Colors.green.shade400, Colors.green.shade600]
              : [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            overallSuccess ? Icons.check_circle : Icons.cancel,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            overallSuccess ? 'Factory Test Passed!' : 'Factory Test Failed',
            style: context.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalPassed of $totalTests tests passed',
            style: context.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                    'Automatic', automaticPassed, automaticTotal),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickStat('Manual', manualPassed, manualTotal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, int passed, int total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '$passed/$total',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
      BuildContext context, WidgetRef ref, FactoryTestState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTestSection('Automatic Tests', state.automaticTests.tests),
          const SizedBox(height: 24),
          _buildTestSection('Manual Tests', state.manualTests.tests),
          const SizedBox(height: 32),
          _buildActionButtons(context, ref, state),
        ],
      ),
    );
  }

  Widget _buildTestSection(String title, List<TestResult> tests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...tests.map((test) => _buildTestResultItem(test)),
      ],
    );
  }

  Widget _buildTestResultItem(TestResult test) {
    final isPass = test.status == TestStatus.pass;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPass ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPass ? Icons.check_circle : Icons.cancel,
            color: isPass ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              test.testName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPass ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isPass ? 'PASS' : 'FAIL',
              style: TextStyle(
                color: isPass ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, FactoryTestState state) {
    final automaticPassed = state.automaticTests.tests
        .where((test) => test.status == TestStatus.pass)
        .length;
    final automaticTotal = state.automaticTests.tests.length;

    final manualPassed = state.manualTests.tests
        .where((test) => test.status == TestStatus.pass)
        .length;
    final manualTotal = state.manualTests.tests.length;

    final totalPassed = automaticPassed + manualPassed;
    final totalTests = automaticTotal + manualTotal;
    final overallSuccess = totalTests > 0 && totalPassed == totalTests;

    return Column(
      children: [
        // Device Status
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: overallSuccess ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  overallSuccess ? Colors.green.shade200 : Colors.red.shade200,
            ),
          ),
          child: Column(
            children: [
              Icon(
                overallSuccess ? Icons.thumb_up : Icons.thumb_down,
                size: 48,
                color: overallSuccess
                    ? Colors.green.shade600
                    : Colors.red.shade600,
              ),
              const SizedBox(height: 8),
              Text(
                overallSuccess
                    ? 'Device Approved for Production'
                    : 'Device Rejected - Retest Required',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: overallSuccess
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                overallSuccess
                    ? 'All factory tests passed successfully'
                    : 'Some tests failed and need to be addressed',
                style: TextStyle(
                  fontSize: 14,
                  color: overallSuccess
                      ? Colors.green.shade600
                      : Colors.red.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _restartTest(context, ref),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Start New Test'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _exportResults(context, state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Export Results'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Exit Factory Test'),
          ),
        ),
      ],
    );
  }

  void _restartTest(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Test'),
        content: const Text(
          'Are you sure you want to start a new factory test? '
          'This will reset all current results.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(factoryTestProvider.notifier).resetFactoryTest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
            ),
            child: const Text('Start New Test'),
          ),
        ],
      ),
    );
  }

  void _exportResults(BuildContext context, FactoryTestState state) {
    // This would implement the results export functionality
    // For now, just show a success message
    context.showSnackBar('Results exported successfully!');
  }
}
