import 'package:airspothealth/core/models/sensor_error_state.dart';
import 'package:airspothealth/features/device_settings/providers/sensor_error_provider.dart';
import 'package:airspothealth/features/report_issue/providers/issue_reporting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Banner widget displayed when a sensor error is detected
/// Shows error details and a "Report Issue" button for quick reporting
class SensorErrorBanner extends ConsumerWidget {
  const SensorErrorBanner({
    required this.deviceId,
    this.firmware,
    super.key,
  });

  final String deviceId;
  final String? firmware;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorError = ref.watch(sensorErrorProvider(deviceId));

    if (sensorError == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sensor Issue Detected',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Friendly help text
          Text(
            sensorError.isRecoveryExhausted
                ? "We're having trouble reading your CO2 sensor. Try restarting your device by turning it off and on again."
                : 'We detected a sensor issue and are attempting to recover automatically. If this persists, try restarting your device.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reportIssue(context, ref, sensorError),
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: const Text('Report Issue'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _reportIssue(
    BuildContext context,
    WidgetRef ref,
    SensorErrorState sensorError,
  ) {
    // Pre-fill the issue report with sensor error details
    ref.read(issueReportingProvider.notifier).prefillFromSensorError(
          deviceId: deviceId,
          firmware: firmware,
          errorCode: sensorError.errorCode,
          recoveryAttempts: sensorError.recoveryAttempts,
          errorMessage: sensorError.errorMessage,
        );

    // Navigate to report issue page
    context.push('/report-issue');
  }
}
