import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';

class DeviceTimePickerSubmitButton extends StatelessWidget {
  const DeviceTimePickerSubmitButton({
    super.key,
    required this.picker,
    required this.onTimeSelected,
  });

  final BottomPicker picker;
  final ValueChanged<DateTime> onTimeSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Align(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.8,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandColorGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final time = picker.currentValue;
              if (time is! DateTime) return;
              onTimeSelected(time);
              picker.dismiss();
            },
            child: const Text('Select'),
          ),
        ),
      ),
    );
  }
}
