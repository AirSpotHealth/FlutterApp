import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/widgets/section_header.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_card.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SystemSupportSection extends ConsumerWidget {
  final String deviceId;
  final BleDevice device;
  final bool isConnected;

  const SystemSupportSection({
    required this.deviceId,
    required this.device,
    required this.isConnected,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'System & Support'),
        SettingsCard(
          children: [
            SettingsTile(
              assetPath: Assets.deviceUpdate,
              iconBgColor: AppColors.primaryColor.withValues(alpha: 0.1),
              iconColor: AppColors.primaryColor,
              title: 'AirSpot Device Update',
              onTap: () {
                if (!_checkConnection(context, isConnected)) return;
                context.pushNamed(RouteNames.deviceUpdate,
                    pathParameters: {'deviceId': deviceId});
              },
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      device.firmwareVersion,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppColors.textTertiary),
                ],
              ),
            ),
            SettingsTile(
              assetPath: Assets.recalibrateSettings,
              iconBgColor: AppColors.brandColorGreen.withValues(alpha: 0.1),
              iconColor: AppColors.brandColorGreen,
              title: 'Calibrate Device',
              onTap: () {
                if (!_checkConnection(context, isConnected)) return;
                context.pushNamed(RouteNames.recalibrateSettings,
                    pathParameters: {'deviceId': deviceId});
              },
              action: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.textTertiary),
            ),
            SettingsTile(
              assetPath: Assets.findMyDevice,
              iconBgColor: AppColors.brandColorAmber.withValues(alpha: 0.1),
              iconColor: AppColors.brandColorAmber,
              title: 'Locate my AirSpot',
              isLast: true,
              onTap: () {
                if (!_checkConnection(context, isConnected)) return;
                context.pushNamed(RouteNames.findMyDevice,
                    pathParameters: {'deviceId': deviceId});
              },
              action: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.textTertiary),
            ),
          ],
        ),
      ],
    );
  }

  bool _checkConnection(BuildContext context, bool isConnected) {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device not connected')),
      );
      return false;
    }
    return true;
  }
}
