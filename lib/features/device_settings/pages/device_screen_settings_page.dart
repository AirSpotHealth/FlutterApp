import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/features/device_settings/widgets/co2_ppm_range_picker_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_ui_mode_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_card.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceScreenSettingsPage extends ConsumerStatefulWidget {
  const DeviceScreenSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<DeviceScreenSettingsPage> createState() =>
      _DeviceScreenSettingsPageState();
}

class _DeviceScreenSettingsPageState
    extends ConsumerState<DeviceScreenSettingsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSettings = ref.watch(deviceSettingsProvider(widget.deviceId));

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: DeviceSettingsNameWidget(
          deviceId: widget.deviceId,
          suffixText: 'Screen Settings',
        ),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DeviceUIModeWidget(deviceId: widget.deviceId),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Co2PpmRangePickerWidget(deviceId: widget.deviceId),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsCard(
            children: [
              SettingsTile(
                assetPath: Assets.screenSettings,
                iconBgColor: AppColors.primaryColor.withValues(alpha: 0.1),
                title: 'Screen on Continuously',
                subtitle:
                    'To maintain battery power the screen is on for 10 seconds in low and medium power modes and 1 minute in high power mode.',
                isLast: true,
                action: Switch.adaptive(
                  value: deviceSettings.continuosScreenEnabled,
                  activeThumbColor: AppColors.primaryColor,
                  onChanged: (value) {
                    ref
                        .read(deviceSettingsProvider(widget.deviceId).notifier)
                        .updateSettings(deviceSettings.copyWith(
                            continuosScreenEnabled: value));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
