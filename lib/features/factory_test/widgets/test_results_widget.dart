import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:airspothealth/features/factory_test/widgets/result_export_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestResultsWidget extends ConsumerWidget {
  const TestResultsWidget({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoryTestState = ref.watch(factoryTestProvider(deviceId));
    return Column(
      children: [
        _buildDeviceInfo(factoryTestState, context),
        const SizedBox(height: 16),
        _buildResultsSummary(factoryTestState, context),
      ],
    );
  }

  Widget _buildDeviceInfo(DeviceFactoryTestState state, BuildContext context) {
    final device = state.selectedDevice.name;

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
            'Device Information',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.devices, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Text(
                'Device: $device',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          if (state.selectedDeviceVariant != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.memory, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Text(
                  'Sensor: ${state.selectedDeviceVariant == 0 ? 'SCD40' : 'SCD41'}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsSummary(
      DeviceFactoryTestState state, BuildContext context) {
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
          Row(
            children: [
              Text(
                'Test Summary',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              ResultExportButton(deviceId: deviceId),
            ],
          ),
          const SizedBox(height: 16),
          _buildTestCategory('Automatic Tests', state.automaticTests.tests),
          const SizedBox(height: 12),
          _buildTestCategory('Manual Tests', state.manualTests.tests),
        ],
      ),
    );
  }

  Widget _buildTestCategory(String title, List<TestResult> tests) {
    final passCount =
        tests.where((test) => test.status == DeviceTestStatus.pass).length;
    final totalCount = tests.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: passCount == totalCount
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: passCount == totalCount
                      ? Colors.green.shade200
                      : Colors.orange.shade200,
                ),
              ),
              child: Text(
                '$passCount/$totalCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: passCount == totalCount
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...tests.map((test) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    test.status == DeviceTestStatus.pass
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 16,
                    color: test.status == DeviceTestStatus.pass
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      test.testName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (test.comment != null && test.comment!.isNotEmpty)
                    Text(
                      _cleanupComment(test.comment!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            )),
      ],
    );
  }

  String _cleanupComment(String comment) {
    // Handle special case for charge test with redundant auto-start + user confirmation
    if (comment.contains('Auto-started after automatic tests completed') &&
        comment.contains('User confirmed')) {
      // For charge test, just show "User confirmed" without the auto-start part
      return '- User confirmed';
    }

    // Keep other "User confirmed" comments as they are meaningful
    return comment;
  }
}
