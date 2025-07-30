import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/factory_test/models/factory_test_models.dart';
import 'package:airspothealth/features/factory_test/providers/factory_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AutomaticTestsTab extends ConsumerWidget {
  const AutomaticTestsTab({super.key, required this.deviceId});

  final String deviceId;

  String _getConnectionStatusText(DeviceFactoryTestPhase phase) {
    switch (phase) {
      case DeviceFactoryTestPhase.connecting:
        return 'Connecting to device...';
      case DeviceFactoryTestPhase.enteringFactoryMode:
        return 'Entering factory mode...';
      case DeviceFactoryTestPhase.reconnecting:
        return 'Device restarting, waiting for reconnection...';
      default:
        return 'Preparing device...';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoryTestState = ref.watch(factoryTestProvider(deviceId));

    debugPrint('AutomaticTestsTab build - phase: ${factoryTestState.phase}');
    debugPrint(
        'AutomaticTestsTab build - connectionState: ${factoryTestState.connectionState}');

    // Show progress view only during initial connection phases (not during tests)
    if (factoryTestState.phase == DeviceFactoryTestPhase.connecting ||
        factoryTestState.phase == DeviceFactoryTestPhase.enteringFactoryMode ||
        factoryTestState.phase == DeviceFactoryTestPhase.reconnecting) {
      debugPrint(
          'AutomaticTestsTab showing progress view for phase: ${factoryTestState.phase}');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _getConnectionStatusText(factoryTestState.phase),
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Show error state with retry option
    if (factoryTestState.phase == DeviceFactoryTestPhase.error) {
      debugPrint('AutomaticTestsTab showing error state');
      return _buildErrorStateWithRetry(context, ref, factoryTestState);
    }

    debugPrint('AutomaticTestsTab showing test results view');
    debugPrint(
        'Automatic tests running: ${factoryTestState.automaticTests.isRunning}');
    debugPrint(
        'Automatic tests complete: ${factoryTestState.automaticTests.isComplete}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Automatic Tests Status',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (factoryTestState.automaticTests.isRunning) ...[
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Running (timeout 1 min)',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Show error message if automatic tests failed due to timeout
        if (factoryTestState.automaticTests.error != null)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.brandColorRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.brandColorRed.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.brandColorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test Failed',
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandColorRed,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            factoryTestState.automaticTests.error!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.brandColorRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(factoryTestProvider(deviceId).notifier)
                        .retryAutomaticTests();
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry Tests'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _buildTestResults(context, ref, factoryTestState),
        ),
      ],
    );
  }

  Widget _buildErrorStateWithRetry(
      BuildContext context, WidgetRef ref, DeviceFactoryTestState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.brandColorRed,
            ),
            const SizedBox(height: 24),
            Text(
              'Connection Failed',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.brandColorRed,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.error ?? 'Unknown error occurred',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                final notifier =
                    ref.read(factoryTestProvider(deviceId).notifier);
                notifier.resetFactoryTest();
                notifier.connectToDeviceAndStartFactoryTest();
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResults(
      BuildContext context, WidgetRef ref, DeviceFactoryTestState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ListView.separated(
        itemCount: state.automaticTests.tests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final test = state.automaticTests.tests[index];
          return _buildTestItem(test);
        },
      ),
    );
  }

  Widget _buildTestItem(TestResult test) {
    IconData icon;
    Color iconColor;
    String statusText;

    switch (test.status) {
      case DeviceTestStatus.notStarted:
        icon = Icons.schedule_outlined;
        iconColor = AppColors.neutralGrey;
        statusText = 'Pending';
        break;
      case DeviceTestStatus.running:
        icon = Icons.autorenew;
        iconColor = AppColors.primaryColor;
        statusText = 'Running';
        break;
      case DeviceTestStatus.pass:
        icon = Icons.check_circle;
        iconColor = AppColors.brandColorGreen;
        statusText = 'Passed';
        break;
      case DeviceTestStatus.fail:
        icon = Icons.cancel;
        iconColor = AppColors.brandColorRed;
        statusText = 'Failed';
        break;
    }

    // Get description and format value display
    String description = _getTestDescription(test.testName);
    String? valueDisplay;

    if (test.value != null) {
      // Format the value based on test type
      valueDisplay = _formatTestValue(test.testName, test.value);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderPrimary),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPrimary,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.testName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (valueDisplay != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      valueDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTestDescription(String testName) {
    switch (testName.toLowerCase()) {
      case 'sensor test':
      case 'sensor':
        return 'Testing CO2 sensor functionality';
      case 'memory test':
      case 'memory':
        return 'Erase/Read/Write Memory';
      case 'battery voltage test':
      case 'battery voltage':
      case 'battery':
        return 'Measuring battery voltage';
      case 'lf crystal test':
      case 'lf crystal':
        return 'Testing low frequency crystal';
      case 'lcd controller test':
      case 'lcd controller':
        return 'Testing LCD controller';
      default:
        return 'Running factory test';
    }
  }

  String _formatTestValue(String testName, dynamic value) {
    switch (testName.toLowerCase()) {
      case 'battery voltage test':
      case 'battery voltage':
      case 'battery':
        if (value is int) {
          return '${value}mV';
        }
        break;
      case 'lf crystal test':
      case 'lf crystal':
        if (value is double) {
          return '${value.toStringAsFixed(3)}KHz';
        } else if (value is int) {
          return '${(value / 1000.0).toStringAsFixed(3)}KHz';
        }
        break;
      case 'sensor test':
      case 'sensor':
        if (value is int) {
          return '${value}ppm';
        }
        break;
      default:
        if (value != null) {
          return value.toString();
        }
    }
    return value?.toString() ?? '';
  }
}
