import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/widgets/section_header.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_card.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DeviceControlsSection extends ConsumerWidget {
  final String deviceId;
  final DeviceSettings settings;
  final bool isConnected;
  final bool hasAlarm;
  final bool hasVibration;

  const DeviceControlsSection({
    required this.deviceId,
    required this.settings,
    required this.isConnected,
    required this.hasAlarm,
    required this.hasVibration,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Device Controls'),
        SettingsCard(
          children: [
            if (hasAlarm)
              SettingsTile(
                assetPath: Assets.alarmSettings,
                iconBgColor: AppColors.primaryColor.withValues(alpha: 0.1),
                title: 'Alarm',
                action: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.pushNamed(RouteNames.advancedAlarmSettings,
                            pathParameters: {'deviceId': deviceId});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Advanced',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch.adaptive(
                      value: settings.alarmEnabled,
                      activeThumbColor: AppColors.primaryColor,
                      onChanged: (value) {
                        if (!isConnected) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Device not connected')),
                          );
                          return;
                        }
                        ref
                            .read(deviceSettingsProvider(deviceId).notifier)
                            .updateSettings(
                                settings.copyWith(alarmEnabled: value));
                      },
                    ),
                  ],
                ),
              ),
            if (hasVibration)
              SettingsTile(
                assetPath: Assets.vibrateSettings,
                iconBgColor: AppColors.purple.withValues(alpha: 0.1),
                title: 'Vibrate',
                action: Switch.adaptive(
                  value: settings.vibrationEnabled,
                  activeThumbColor: AppColors.primaryColor,
                  onChanged: (value) {
                    if (!isConnected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Device not connected')),
                      );
                      return;
                    }
                    ref
                        .read(deviceSettingsProvider(deviceId).notifier)
                        .updateSettings(
                            settings.copyWith(vibrationEnabled: value));
                  },
                ),
              ),
            SettingsTile(
              assetPath: Assets.autoConnectSettings,
              iconBgColor: AppColors.brandColorGreen.withValues(alpha: 0.1),
              title: 'Auto Connect',
              isLast: true,
              action: Switch.adaptive(
                value: settings.autoConnect,
                activeThumbColor: AppColors.primaryColor,
                onChanged: (value) {
                  ref
                      .read(deviceSettingsProvider(deviceId).notifier)
                      .updateSettings(settings.copyWith(autoConnect: value));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
