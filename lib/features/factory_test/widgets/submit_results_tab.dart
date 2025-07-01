import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:airspothealth/features/factory_test/providers/submission_provider.dart';
import 'package:airspothealth/features/factory_test/providers/tester_name_provider.dart';
import 'package:airspothealth/features/factory_test/widgets/submit_results_button.dart';
import 'package:airspothealth/features/factory_test/widgets/test_results_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubmitResultsTab extends ConsumerStatefulWidget {
  const SubmitResultsTab({super.key, required this.deviceId});

  final String deviceId;

  @override
  ConsumerState<SubmitResultsTab> createState() => _SubmitResultsTabState();
}

class _SubmitResultsTabState extends ConsumerState<SubmitResultsTab> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _testedByController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load saved tester name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedTesterName = ref.read(testerNameProvider);
      if (savedTesterName.isNotEmpty) {
        _testedByController.text = savedTesterName;
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _testedByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final factoryTestState = ref.watch(factoryTestProvider(widget.deviceId));

    if (!factoryTestState.isTestingComplete) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                'Complete All Tests First',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Results will be available after all tests are completed',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          _buildCleanHeader(factoryTestState),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubmissionSection(factoryTestState),
                  const SizedBox(height: 16),
                  TestResultsWidget(
                    deviceId: widget.deviceId,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanHeader(DeviceFactoryTestState state) {
    final automaticPassed = state.automaticTests.tests
        .where((test) => test.status == DeviceTestStatus.pass)
        .length;
    final automaticTotal = state.automaticTests.tests.length;

    final manualPassed = state.manualTests.tests
        .where((test) => test.status == DeviceTestStatus.pass)
        .length;
    final manualTotal = state.manualTests.tests.length;

    final totalPassed = automaticPassed + manualPassed;
    final totalTests = automaticTotal + manualTotal;
    final overallSuccess = totalTests > 0 && totalPassed == totalTests;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: overallSuccess ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              overallSuccess ? Icons.check_circle : Icons.cancel,
              size: 20,
              color:
                  overallSuccess ? Colors.green.shade600 : Colors.red.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overallSuccess ? 'All Tests Passed' : 'Some Tests Failed',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  '$totalPassed of $totalTests tests completed successfully',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionSection(DeviceFactoryTestState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit Results',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),

          // Tested By Field
          Consumer(
            builder: (context, ref, child) {
              final submissionState =
                  ref.watch(submissionProvider(widget.deviceId));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tested By *',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: submissionState.testedBy,
                    decoration: InputDecoration(
                      hintText: 'Enter tester name (required)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      errorText: submissionState.testedBy.trim().isEmpty &&
                              submissionState.status == SubmissionStatus.error
                          ? 'Tester name is required'
                          : null,
                    ),
                    onChanged: (value) {
                      ref
                          .read(submissionProvider(widget.deviceId).notifier)
                          .setTestedBy(value);
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tester name is required';
                      }
                      return null;
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Comments Field
          Text(
            'Comments (Optional)',
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _commentController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add any additional notes about the test',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFFFF8C00), width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.grey.shade50,
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          SubmitResultsButton(deviceId: widget.deviceId),
        ],
      ),
    );
  }
}
