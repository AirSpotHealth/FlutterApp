import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/services/live_activity_service.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_card.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SensorDisplaySection extends ConsumerWidget {
  final String deviceId;
  final DeviceSettings settings;
  final bool isConnected;
  final bool supportsTimeSettings;
  final bool supportsScreenSettings;

  const SensorDisplaySection({
    required this.deviceId,
    required this.settings,
    required this.isConnected,
    required this.supportsTimeSettings,
    required this.supportsScreenSettings,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'SENSOR & DISPLAY',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        SettingsCard(
          children: [
            if (supportsTimeSettings)
              SettingsTile(
                assetPath: Assets.timeSettings,
                iconBgColor: Colors.transparent,
                title: 'Time Settings',
                onTap: () {
                  if (!_checkConnection(context, isConnected)) return;
                  context.pushNamed(RouteNames.timeSettings,
                      pathParameters: {'deviceId': deviceId});
                },
                action: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ),
            if (deviceId.isNotEmpty)
              SettingsTile(
                assetPath: Assets.powerModeSettings,
                iconBgColor: Colors.transparent,
                title: 'CO2 Reading Rate',
                subtitle: settings.powerMode.name,
                onTap: () {
                  if (!_checkConnection(context, isConnected)) return;
                  context.pushNamed(RouteNames.powerModeSettings,
                      pathParameters: {'deviceId': deviceId});
                },
                action: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ),
            if (supportsScreenSettings)
              SettingsTile(
                assetPath: Assets.screenSettings,
                iconBgColor: Colors.transparent,
                title: 'Device Screen Settings',
                onTap: () {
                  if (!_checkConnection(context, isConnected)) return;
                  context.pushNamed(RouteNames.screenSettings,
                      pathParameters: {'deviceId': deviceId});
                },
                action: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ),
            SettingsTile(
              icon: Icons
                  .notifications_active, // Keep icon for notifications as requested? User said "existing icons", Assets has no notification icon other than Alarm?
              // Wait, previous code used Icons.notifications_active with color grey.
              // I will use icon here since I don't see a "notification_settings" asset in provided Assets list, only alarm/vibrate/dnd.
              // Actually, user said "cant see them icons... its all appearing greyed" refers to my Assets usages.
              // I will use Icon for now unless I find an asset.
              iconColor: Colors.grey,
              iconBgColor: Colors.transparent,
              title: 'Notification Settings',
              onTap: () {
                if (!_checkConnection(context, isConnected)) return;
                context.pushNamed(RouteNames.notificationSettings,
                    pathParameters: {'deviceId': deviceId});
              },
              action: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey),
            ),
            SettingsTile(
              assetPath: Assets.liveActivity,
              iconBgColor: Colors.transparent,
              title: 'Live Activity',
              isLast: true,
              action: Switch.adaptive(
                value: settings.showLiveActivity,
                activeThumbColor: AppColors.primaryColor,
                onChanged: (value) async {
                  if (value) {
                    // To start fresh, we trigger a CO2 read which calls updateWithCO2Data
                    ref
                        .read(bleDeviceCommunicationProvider(deviceId).notifier)
                        .sendCommand(DeviceCmdUtils.getCO2());
                  } else {
                    await LiveActivityService()
                        .removeDeviceLiveActivity(deviceId);
                  }
                  ref
                      .read(deviceSettingsProvider(deviceId).notifier)
                      .updateSettings(
                          settings.copyWith(showLiveActivity: value));
                },
              ),
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
