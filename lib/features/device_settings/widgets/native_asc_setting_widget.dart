import '../models/slim_settling_state.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airspothealth/features/device_settings/models/native_asc_state.dart';
import 'package:airspothealth/features/device_settings/providers/native_asc_provider.dart';

/// Read-only auto-calibration status. Slim keeps automatic calibration enabled.
class NativeAscSettingWidget extends ConsumerWidget {
  const NativeAscSettingWidget(
      {required this.deviceId,
      required this.firmwareVersion,
      required this.manualControls,
      super.key});
  final String deviceId;
  final String firmwareVersion;
  final Widget manualControls;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!NativeAscState.supported(firmwareVersion)) {
      return Text(
          'Update your Slim firmware to use automatic calibration and forced recalibration.',
          style: Theme.of(context).textTheme.bodySmall);
    }
    final state = ref.watch(nativeAscProvider(deviceId));
    final value = state.asData?.value;
    final enabled = value?.verified == true && value?.enabled == true;
    final canRecalibrate =
        enabled && SlimSettlingState.nativeTestModesSupported(firmwareVersion);
    final theme = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Auto-calibration',
            style: theme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        subtitle: Text(
            state.isLoading
                ? 'Checking auto-calibration…'
                : enabled
                    ? 'On. Auto-calibration adjusts the sensor baseline over time. Expose Slim to fresh air at least once a week.'
                    : state.hasError
                        ? 'Could not confirm auto-calibration. Keep Slim nearby and try again.'
                        : 'Auto-calibration is off on this firmware. Update your Slim to enable it automatically.',
            style: theme.bodySmall?.copyWith(color: AppColors.textSecondary)),
      ),
      if (state.hasError) ...[
        const SizedBox(height: 8),
        Button(
            type: ButtonType.outlined,
            prefixIcon: const Icon(Icons.refresh, size: 20),
            onPressed: () =>
                ref.read(nativeAscProvider(deviceId).notifier).refresh(),
            label: 'Retry'),
      ],
      if (canRecalibrate) ...[
        const SizedBox(height: 16),
        manualControls,
      ] else if (enabled) ...[
        const SizedBox(height: 8),
        Text('Update your Slim firmware to use forced recalibration.',
            style: theme.bodySmall),
      ],
    ]);
  }
}
