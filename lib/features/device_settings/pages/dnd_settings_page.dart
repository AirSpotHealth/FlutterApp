import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/utils/local_date_format.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_card.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_tile.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DndSettingsPage extends ConsumerWidget {
  const DndSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  static const _defaultStartHour = 22;
  static const _defaultEndHour = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSettings = ref.watch(deviceSettingsProvider(deviceId));

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: DeviceSettingsNameWidget(
            deviceId: deviceId, suffixText: 'Do not disturb Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDndSettingsCard(context, ref, deviceSettings),
        ],
      ),
    );
  }

  Widget _buildDndSettingsCard(
      BuildContext context, WidgetRef ref, DeviceSettings deviceSettings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'SCHEDULE',
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
            SettingsTile(
              assetPath: Assets.doNotDisturbSettings,
              iconBgColor: AppColors.indigo.withValues(alpha: 0.1),
              title: 'Do not disturb',
              subtitle: 'Silences all alerts and sounds',
              isLast: !deviceSettings.dndEnabled,
              action: Switch.adaptive(
                value: deviceSettings.dndEnabled,
                activeThumbColor: AppColors.primaryColor,
                onChanged: (value) =>
                    _updateDndSettings(ref, deviceSettings, enabled: value),
              ),
            ),
            if (deviceSettings.dndEnabled) ...[
              _buildTimeTile(
                context,
                ref,
                deviceSettings,
                isStartTime: true,
              ),
              _buildTimeTile(
                context,
                ref,
                deviceSettings,
                isStartTime: false,
                isLast: true,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTimeTile(
      BuildContext context, WidgetRef ref, DeviceSettings deviceSettings,
      {required bool isStartTime, bool isLast = false}) {
    final bool is12Hour =
        LocalDateFormat.instance.systemTimeFormat.pattern!.contains('a');
    final DateTime? time =
        isStartTime ? deviceSettings.dndStartTime : deviceSettings.dndEndTime;

    return SettingsTile(
      icon: isStartTime ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
      iconBgColor:
          (isStartTime ? Colors.orange : Colors.purple).withValues(alpha: 0.1),
      iconColor: isStartTime ? Colors.orange : Colors.purple,
      title: isStartTime ? 'Start time' : 'End time',
      subtitle: time == null
          ? 'Not set'
          : is12Hour
              ? time.format12Hour()
              : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      isLast: isLast,
      onTap: () => _showTimePicker(
        context,
        ref,
        deviceSettings,
        isStartTime: isStartTime,
        is12Hour: is12Hour,
      ),
    );
  }

  void _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    DeviceSettings deviceSettings, {
    required bool isStartTime,
    required bool is12Hour,
  }) {
    final DateTime? currentTime =
        isStartTime ? deviceSettings.dndStartTime : deviceSettings.dndEndTime;
    final int defaultHour = isStartTime ? _defaultStartHour : _defaultEndHour;

    BottomPicker.time(
      headerBuilder: (context) => Text(
        'Select ${isStartTime ? 'start' : 'end'} time',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      initialTime: Time(
        hours: currentTime?.hour ?? defaultHour,
        minutes: currentTime?.minute ?? 0,
      ),
      dismissable: true,
      buttonWidth: MediaQuery.of(context).size.width * 0.8,
      buttonStyle: BoxDecoration(
        color: AppColors.brandColorGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      use24hFormat: !is12Hour,
      onSubmit: (time) => _updateTime(
        ref,
        deviceSettings,
        time: time,
        isStartTime: isStartTime,
      ),
    ).show(context);
  }

  void _updateTime(
    WidgetRef ref,
    DeviceSettings deviceSettings, {
    required DateTime time,
    required bool isStartTime,
  }) {
    final DateTime newTime = DateTime.now().copyWith(
      hour: time.hour,
      minute: time.minute,
    );

    ref.read(deviceSettingsProvider(deviceId).notifier).updateSettings(
          deviceSettings.copyWith(
            dndStartTime: isStartTime ? newTime : deviceSettings.dndStartTime,
            dndEndTime: isStartTime ? deviceSettings.dndEndTime : newTime,
          ),
        );
  }

  void _updateDndSettings(
    WidgetRef ref,
    DeviceSettings deviceSettings, {
    required bool enabled,
  }) {
    ref.read(deviceSettingsProvider(deviceId).notifier).updateSettings(
          deviceSettings.copyWith(
            dndEnabled: enabled,
            dndStartTime: deviceSettings.dndStartTime ??
                deviceSettings.defaultDndStartTime,
            dndEndTime:
                deviceSettings.dndEndTime ?? deviceSettings.defaultDndEndTime,
          ),
        );
  }
}
