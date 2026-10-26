import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Startup is an unavailable reading, not a failed sensor or a green CO2 zone.
class SensorPreparingNotice extends StatelessWidget {
  const SensorPreparingNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.hourglass_top,
                color: AppColors.primaryColorDark, size: 24),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preparing sensor…',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const Text(
                    'Keep Slim powered while it prepares to measure. Startup readings are not shown. This is separate from the 12-hour recovery check.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
