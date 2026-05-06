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

class FocusSection extends ConsumerWidget {
  final String deviceId;
  final DeviceSettings settings;
  final bool isConnected;
  final bool supportsDnd;

  const FocusSection({
    required this.deviceId,
    required this.settings,
    required this.isConnected,
    required this.supportsDnd,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!supportsDnd) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Focus'),
        SettingsCard(
          children: [
            SettingsTile(
              assetPath: Assets.doNotDisturbSettings,
              iconBgColor: AppColors.indigo.withValues(alpha: 0.1),
              title: 'Do Not Disturb',
              subtitle: 'Silences all alerts and sounds',
              isLast: true,
              onTap: () {
                if (!_checkConnection(context, isConnected)) return;
                context.pushNamed(RouteNames.doNotDisturbSettings,
                    pathParameters: {'deviceId': deviceId});
              },
              action: Switch.adaptive(
                value: settings.dndEnabled,
                activeThumbColor: AppColors.primaryColor,
                onChanged: (value) {
                  if (!_checkConnection(context, isConnected)) return;
                  ref
                      .read(deviceSettingsProvider(deviceId).notifier)
                      .updateSettings(settings.copyWith(dndEnabled: value));
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
