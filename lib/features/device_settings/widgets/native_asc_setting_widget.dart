import '../models/slim_settling_state.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airspothealth/features/device_settings/models/native_asc_state.dart';
import 'package:airspothealth/features/device_settings/providers/native_asc_provider.dart';

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
      return Column(children: [
        ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto Calibration'),
            subtitle: Text(firmwareVersion == '0.17.12'
                ? 'Auto calibration is enabled in this experimental firmware. Update to control it from the app.'
                : 'Update Slim firmware to 0.18.0 or later to enable sensor auto calibration.')),
        if (NativeAscState.canCalibrate(firmwareVersion, null)) manualControls,
      ]);
    }
    final nativeFrc =
        SlimSettlingState.nativeTestModesSupported(firmwareVersion);
    final state = ref.watch(nativeAscProvider(deviceId));
    final value = state.asData?.value;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Auto Calibration',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          subtitle: const Text(
              'Let the sensor adjust its baseline automatically. It needs exposure to fresh air at least once a week.',
              style: TextStyle(color: AppColors.textSecondary)),
          value: value?.enabled ?? false,
          onChanged: value?.verified == true && !state.isLoading
              ? (enabled) => ref
                  .read(nativeAscProvider(deviceId).notifier)
                  .setEnabled(enabled)
              : null),
      if (state.isLoading)
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Checking the sensor setting…')),
      if (state.hasError) ...[
        const SizedBox(height: 12),
        const Text(
            'Could not confirm the sensor setting. Keep Slim nearby, reconnect, and try again.'),
        const SizedBox(height: 12),
        Button(
            type: ButtonType.outlined,
            prefixIcon: const Icon(Icons.refresh, size: 20),
            onPressed: () =>
                ref.read(nativeAscProvider(deviceId).notifier).refresh(),
            label: 'Retry'),
      ],
      if (value?.enabled == true && !nativeFrc)
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
                'Manual calibration is unavailable while auto calibration is on. Turning it off pauses learning and retains the sensor baseline.')),
      if (value?.mode == 1)
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
                'Auto calibration is paused. The sensor keeps its learned baseline; manual calibration can apply a new correction.')),
      if (nativeFrc)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
              'Sensirion auto calibration runs inside the STCC4. Forced recalibration is also available with a known, stable CO₂ reference. No AirSpot offset is added.'),
        ),
      if (NativeAscState.canCalibrate(firmwareVersion, value)) manualControls,
    ]);
  }
}
