import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/providers/recalibration_time_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManualCalibrationWidget extends ConsumerStatefulWidget {
  const ManualCalibrationWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManualCalibrationWidgetState();
}

class _ManualCalibrationWidgetState
    extends ConsumerState<ManualCalibrationWidget> {
  final TextEditingController calibrationValueController =
      TextEditingController()..text = '426';

  @override
  void dispose() {
    calibrationValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          TextFormField(
            controller: calibrationValueController,
            decoration: InputDecoration(
              labelText: 'Calibration Target',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              helperMaxLines: 3,
              helperStyle: context.textTheme.bodySmall,
              helperText:
                  "You can set the CO2 level of the air where calibration takes place. If unknown, 420-450 is typical for outdoors.",
            ),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a calibration target';
              }

              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }

              if (int.parse(value) <= 0) {
                return 'Please enter a positive number greater than 0';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.number,
            style: context.textTheme.bodyMedium?.weight700,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (calibrationValueController.text.isEmpty) {
                return;
              }

              final int calibrationValue =
                  int.parse(calibrationValueController.text);

              if (calibrationValue <= 0) {
                return;
              }

              ref
                  .read(recalibrationTimeProvider(widget.deviceId).notifier)
                  .startRecalibration(calibrationValue);
            },
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  Assets.recalibrateImage,
                  height: 120,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
