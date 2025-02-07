import 'package:airspothealth/features/device_settings/models/asc_data.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/device_asc_data_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AutoCalibrationWidget extends ConsumerStatefulWidget {
  const AutoCalibrationWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AutoCalibrationWidgetState();
}

class _AutoCalibrationWidgetState extends ConsumerState<AutoCalibrationWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deviceASCDataProvider(widget.deviceId).notifier).request();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncProgressValue ascDataProgress =
        ref.watch(deviceASCDataProvider(widget.deviceId));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'If Auto Calibration is enabled, AirSpot will calibrate itself on the assumption that it has made measurements in fresh air at least once a week. It is usually best to leave this OFF unless you are sure AirSpot will be measuring fresh air at least every few days. See full manual for details.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            if (ascDataProgress is AsyncInProgress) return;

            ref.read(deviceASCDataProvider(widget.deviceId).notifier).request();
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
                    "The sensor has been calibrated itself ${(ascDataProgress.data as AscData).count} times since ASC was enabled. The last correction applied was ${(ascDataProgress.data as AscData).correction}.",
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
        ),
      ],
    );
  }
}
