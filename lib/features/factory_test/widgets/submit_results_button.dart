import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/factory_test/providers/submission_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubmitResultsButton extends ConsumerWidget {
  const SubmitResultsButton({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionState = ref.watch(submissionProvider(deviceId));

    return Column(children: [
      // Server submission option
      CheckboxListTile(
        value: submissionState.putDeviceToSleep,
        onChanged: (value) {
          ref
              .read(submissionProvider(deviceId).notifier)
              .setPutDeviceToSleep(value ?? false);
        },
        title: const Text('Sleep Device after Submission'),
        subtitle: Text(
          'Device will be put to sleep after submission',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        dense: true,
        contentPadding: EdgeInsets.zero,
        activeColor: const Color(0xFFFF8C00),
      ),

      const SizedBox(height: 16),

      switch (submissionState.status) {
        SubmissionStatus.submitting => Button(
            onPressed: null,
            label: 'Submitting...',
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Submitting...',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        SubmissionStatus.success => Button(
            onPressed: null,
            label: 'Completed Successfully',
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 20),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Completed Successfully',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        SubmissionStatus.error => Column(
            children: [
              if (submissionState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade600, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          submissionState.errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: Button(
                  onPressed: () => ref
                      .read(submissionProvider(deviceId).notifier)
                      .startSubmission(),
                  label: 'Retry Submission',
                ),
              ),
            ],
          ),
        _ => SizedBox(
            width: double.infinity,
            child: Button(
              onPressed: () => ref
                  .read(submissionProvider(deviceId).notifier)
                  .startSubmission(),
              label: submissionState.putDeviceToSleep
                  ? 'Submit & Sleep Device'
                  : 'Submit & Restart Device',
            ),
          ),
      },
    ]);
  }
}
