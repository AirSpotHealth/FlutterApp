import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PowerModeSettingsPage extends ConsumerWidget {
  const PowerModeSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: DeviceSettingsNameWidget(
          deviceId: deviceId,
          suffixText: 'Reading Rate',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Choose how frequently your device takes ${Constants.co2Text} readings. More frequent updates will use more battery.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          const SizedBox(height: 24),
          SettingsCard(
            children: [
              _PowerModeTile(
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
              _PowerModeTile(
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
              _PowerModeTile(
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
              _PowerModeTile(
                asset: Assets.powerMode5sec,
                title: '5 sec',
                updateRate: 'Updates every 5 seconds',
                batteryLife: '~12 hours on full charge',
                isSelected: deviceSettings.powerMode == PowerMode.high,
                isLast: true,
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

class _PowerModeTile extends StatelessWidget {
  const _PowerModeTile({
    required this.onTap,
    required this.isSelected,
    required this.asset,
    required this.title,
    required this.updateRate,
    required this.batteryLife,
    this.isLast = false,
  });

  final VoidCallback onTap;
  final bool isSelected;
  final String asset;
  final String title;
  final String updateRate;
  final String batteryLife;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor.withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  asset,
                  width: 32,
                  height: 32,
                  color: isSelected ? AppColors.primaryColor : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.black87,
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
                              ? AppColors.primaryColor
                              : Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            batteryLife,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected
                                  ? AppColors.primaryColor
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
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
