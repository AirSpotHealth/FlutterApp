import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/utils/local_date_format.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_card.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_tile.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimeSettingsPage extends ConsumerStatefulWidget {
  const TimeSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<TimeSettingsPage> createState() => _TimeSettingsPageState();
}

class _TimeSettingsPageState extends ConsumerState<TimeSettingsPage> {
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _initializeTime();
  }

  void _initializeTime() {
    final now = DateTime.now();
    _selectedHour = now.hour;
    _selectedMinute = now.minute;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(deviceSettingsProvider(widget.deviceId)).autoSyncTime) {
        _syncTime();
      }
    });
  }

  void _syncTime() {
    ref
        .read(bleDeviceCommunicationProvider(widget.deviceId).notifier)
        .sendCommand(DeviceCmdUtils.setTime());
  }

  void _updateAutoSync(bool value) {
    ref.read(deviceSettingsProvider(widget.deviceId).notifier).updateSettings(
          ref.watch(deviceSettingsProvider(widget.deviceId)).copyWith(
                autoSyncTime: value,
              ),
        );

    if (!value) {
      _selectedHour = DateTime.now().hour;
      _selectedMinute = DateTime.now().minute;
    }
  }

  void _updateManualTime() {
    ref
        .read(bleDeviceCommunicationProvider(widget.deviceId).notifier)
        .sendCommand(DeviceCmdUtils.setTime(
          hour: _selectedHour,
          min: _selectedMinute,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final autoSyncTime =
        ref.watch(deviceSettingsProvider(widget.deviceId)).autoSyncTime;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: DeviceSettingsNameWidget(
          deviceId: widget.deviceId,
          suffixText: 'Time Settings',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'CONFIGURATION',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          SettingsCard(children: [
            SettingsTile(
              assetPath: Assets.timeSettings,
              iconBgColor: AppColors.primaryColor.withValues(alpha: 0.1),
              title: 'Sync with mobile device',
              isLast: autoSyncTime,
              action: Switch.adaptive(
                value: autoSyncTime,
                activeThumbColor: AppColors.primaryColor,
                onChanged: _updateAutoSync,
              ),
            ),
            if (!autoSyncTime) _buildManualTimePicker(),
          ]),
        ],
      ),
    );
  }

  Widget _buildManualTimePicker() {
    final bool is12Hour =
        LocalDateFormat.instance.systemTimeFormat.pattern!.contains('a');

    return SettingsTile(
      icon: Icons.access_time,
      iconBgColor: Colors.orange.withValues(alpha: 0.1),
      iconColor: Colors.orange,
      title: 'Manual Time',
      subtitle: is12Hour
          ? DateTime.now()
              .copyWith(
                hour: _selectedHour,
                minute: _selectedMinute,
              )
              .format12Hour()
          : '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
      isLast: true,
      onTap: () => _showTimePicker(context, is12Hour),
    );
  }

  void _showTimePicker(BuildContext context, bool is12Hour) {
    BottomPicker.time(
      headerBuilder: (context) => const Text(
        'Select time',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      initialTime: Time(
        hours: _selectedHour,
        minutes: _selectedMinute,
      ),
      dismissable: true,
      buttonWidth: MediaQuery.of(context).size.width * 0.8,
      buttonStyle: BoxDecoration(
        color: AppColors.brandColorGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      use24hFormat: !is12Hour,
      onSubmit: (time) {
        debugPrint('time: ${time.runtimeType}');
        setState(() {
          _selectedHour = time.hour;
          _selectedMinute = time.minute;
        });

        _updateManualTime();
      },
    ).show(context);
  }
}
