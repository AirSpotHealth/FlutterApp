import 'package:airspothealth/features/device_settings/models/asc_data.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/device_asc_data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalibrationCorrectionWidget extends ConsumerWidget {
  const CalibrationCorrectionWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncProgressValue ascDataProgress =
        ref.watch(deviceASCDataProvider(deviceId));

    return GestureDetector(
      onTap: () {
        if (ascDataProgress is AsyncInProgress) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(deviceASCDataProvider(deviceId).notifier).request();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ascDataProgress is AsyncInProgress)
              CupertinoActivityIndicator()
            else if (ascDataProgress is AsyncFailure)
              Text(
                'Failed to get ASC data: ${ascDataProgress.error}',
                style: const TextStyle(color: Colors.red),
              )
            else if (ascDataProgress is AsyncSuccess) ...[
              Text(
                "The last correction applied was ${(ascDataProgress.data as AscData).correction}.",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Tap to get latest values',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
