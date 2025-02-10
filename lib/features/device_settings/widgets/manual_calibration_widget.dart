import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/features/device_settings/providers/recalibration_time_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManualCalibrationWidget extends ConsumerWidget {
  const ManualCalibrationWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'To calibrate this AirSpot, place the device outdoors for at least 5 minutes, away from any people or CO2 sources, then tap the icon below. See full manual for details.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // TextFormField(
          //   controller: TextEditingController()..text = '426',
          //   decoration: InputDecoration(
          //     labelText: 'Calibration Value',
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     contentPadding:
          //         const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //   ),
          //   onTapOutside: (_) => FocusScope.of(context).unfocus(),
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return 'Please enter a calibration value';
          //     }

          //     if (int.tryParse(value) == null) {
          //       return 'Please enter a valid number';
          //     }

          //     if (int.parse(value) <= 0) {
          //       return 'Please enter a positive number greater than 0';
          //     }
          //     return null;
          //   },
          //   autovalidateMode: AutovalidateMode.onUserInteraction,
          //   keyboardType: TextInputType.number,
          // ),
          GestureDetector(
            onTap: () {
              ref
                  .read(recalibrationTimeProvider(deviceId).notifier)
                  .startRecalibration();
            },
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                Assets.recalibrateImage,
                height: 120,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
