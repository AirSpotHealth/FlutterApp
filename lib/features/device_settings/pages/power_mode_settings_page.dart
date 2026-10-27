import '../widgets/slim_measurement_icon.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import '../models/slim_settling_state.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PowerModeSettingsPage extends ConsumerWidget {
  const PowerModeSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    final device = ref.watch(bleDeviceProvider(deviceId));
    final isSlim = device.deviceModel == DeviceModel.airspotSlim;
    final nativeModes = isSlim &&
        SlimSettlingState.nativeTestModesSupported(device.firmwareVersion) &&
        device.firmwareVersion != '0.22.0';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: DeviceSettingsNameWidget(
          deviceId: deviceId,
          suffixText: isSlim ? 'Measurement Mode' : 'Reading Rate',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isSlim
                ? 'Both modes report every 10 seconds. Single shot takes one measurement every 10 seconds. Continuous measures every second. Temperature, humidity and pressure compensation are refreshed every second in both modes. Battery life is being measured. A brief white blink every 10 seconds indicates the first hour of settling after setup or a sensor reset.'
                : 'Choose how frequently your device takes ${Constants.co2Text} readings. More frequent updates will use more battery.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          if (isSlim)
            SlimMeasurementModeChoices(
              firmwareVersion: device.firmwareVersion,
              enabled: nativeModes,
              selectedMode: nativeModes ? deviceSettings.powerMode : null,
              onChanged: (mode) => _updatePowerMode(
                  ref, deviceSettings.copyWith(powerMode: mode)),
            )
          else
            Column(
              children: [
                _PowerModeCard(
                  asset: Assets.powerModeOnDemand,
                  title: 'Now',
                  updateRate: 'Manual update only',
                  batteryLife: '~14 days with 100 measurements per day',
                  isSelected: deviceSettings.powerMode == PowerMode.onDemand,
                  onTap: () => _updatePowerMode(
                    ref,
                    deviceSettings.copyWith(powerMode: PowerMode.onDemand),
                  ),
                ),
                const SizedBox(height: 12),
                _PowerModeCard(
                  asset: Assets.powerMode3min,
                  title: '3 min',
                  updateRate: 'Updates every 3 minutes',
                  batteryLife: '~10 days on full charge',
                  isSelected: deviceSettings.powerMode == PowerMode.low,
                  onTap: () => _updatePowerMode(
                    ref,
                    deviceSettings.copyWith(powerMode: PowerMode.low),
                  ),
                ),
                const SizedBox(height: 12),
                _PowerModeCard(
                  asset: Assets.powerMode1min,
                  title: '1 min',
                  updateRate: 'Updates every minute',
                  batteryLife: '~6 days on full charge',
                  isSelected: deviceSettings.powerMode == PowerMode.medium,
                  onTap: () => _updatePowerMode(
                    ref,
                    deviceSettings.copyWith(powerMode: PowerMode.medium),
                  ),
                ),
                const SizedBox(height: 12),
                _PowerModeCard(
                  asset: Assets.powerMode5sec,
                  title: '5 sec',
                  updateRate: 'Updates every 5 seconds',
                  batteryLife: '~12 hours on full charge',
                  isSelected: deviceSettings.powerMode == PowerMode.high,
                  onTap: () => _updatePowerMode(
                    ref,
                    deviceSettings.copyWith(powerMode: PowerMode.high),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _updatePowerMode(WidgetRef ref, DeviceSettings deviceSettings) {
    return ref
        .read(deviceSettingsProvider(deviceId).notifier)
        .updateSettings(deviceSettings);
  }
}

/// Slim always presents the two acquisition choices. Older firmware cannot
/// interpret those wire values correctly, so require an update before sending.
class SlimMeasurementModeChoices extends StatelessWidget {
  const SlimMeasurementModeChoices(
      {super.key,
      required this.firmwareVersion,
      required this.enabled,
      required this.selectedMode,
      required this.onChanged});
  final String firmwareVersion;
  final bool enabled;
  final PowerMode? selectedMode;
  final ValueChanged<PowerMode> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!enabled) ...[
            Text('Firmware update required',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
                'This Slim reports firmware $firmwareVersion. Install firmware 0.22.1 or later, then reconnect to enable these modes. Your current setting has not been changed.'),
            const SizedBox(height: 16),
          ],
          for (final mode in [PowerMode.low, PowerMode.high]) ...[
            Semantics(
              button: true,
              enabled: enabled,
              selected: selectedMode == mode,
              child: Opacity(
                opacity: enabled ? 1 : 0.55,
                child: _PowerModeCard(
                  leading: SlimMeasurementIcon(mode: mode),
                  title: mode == PowerMode.low ? 'Single shot' : 'Continuous',
                  updateRate: mode == PowerMode.low
                      ? 'One measurement every 10 seconds'
                      : 'One measurement every second',
                  batteryLife: 'Reports every 10 seconds',
                  isSelected: selectedMode == mode,
                  onTap: enabled ? () => onChanged(mode) : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
}

class _PowerModeCard extends StatelessWidget {
  const _PowerModeCard({
    required this.onTap,
    required this.isSelected,
    this.asset,
    this.leading,
    required this.title,
    required this.updateRate,
    required this.batteryLife,
  });

  final VoidCallback? onTap;
  final bool isSelected;
  final String? asset;
  final Widget? leading;
  final String title;
  final String updateRate;
  final String batteryLife;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryColorDark : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? AppColors.primaryColorDark.withValues(alpha: 0.05)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (asset != null || leading != null)
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColorDark.withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: leading ??
                    Image.asset(
                      asset!,
                      width: 32,
                      height: 32,
                    ),
              ),
            if (asset != null || leading != null) const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryColorDark
                              : Colors.black87,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColorDark
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Selected',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryColorDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    updateRate,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.battery_charging_full,
                        size: 16,
                        color: isSelected
                            ? AppColors.primaryColorDark
                            : Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          batteryLife,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected
                                ? AppColors.primaryColorDark
                                : Colors.grey[600],
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primaryColorDark : Colors.grey[300],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
