import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/utils/local_date_format.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_time_picker_submit_button.dart';
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
  static const _styles = {
    'title': TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    'subtitle': TextStyle(fontSize: 14, color: Colors.grey),
  };

  static const _padding = EdgeInsets.all(16.0);
  static const _horizontalPadding = EdgeInsets.zero;

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
          ref.read(deviceSettingsProvider(widget.deviceId)).copyWith(
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
    final bool is12Hour =
        LocalDateFormat.instance.systemTimeFormat.pattern!.contains('a');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: DeviceSettingsNameWidget(
          deviceId: widget.deviceId,
          suffixText: 'Time Settings',
        ),
      ),
      body: ListView(
        padding: _padding,
        children: [
          _buildAutoSyncTile(autoSyncTime),
          if (!autoSyncTime) ...[
            const Divider(),
            _buildManualTimePicker(is12Hour),
          ]
        ],
      ),
    );
  }

  Widget _buildAutoSyncTile(bool autoSyncTime) {
    return SwitchListTile(
      contentPadding: _horizontalPadding,
      title: Text('Sync with mobile device', style: _styles['title']),
      value: autoSyncTime,
      onChanged: _updateAutoSync,
    );
  }

  Widget _buildManualTimePicker(bool is12Hour) {
    return ListTile(
      contentPadding: _horizontalPadding,
      title: Text('Manual Time', style: _styles['title']),
      leading: const Icon(Icons.access_time),
      subtitle: Text(
        is12Hour
            ? DateTime.now()
                .copyWith(
                  hour: _selectedHour,
                  minute: _selectedMinute,
                )
                .format12Hour()
            : '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
        style: _styles['subtitle'],
      ),
      onTap: () => _showTimePicker(context, is12Hour),
    );
  }

  void _showTimePicker(BuildContext context, bool is12Hour) {
    BottomPicker.time(
      headerBuilder: (context) => Text('Select time', style: _styles['title']),
      initialTime: Time(
        hours: _selectedHour,
        minutes: _selectedMinute,
      ),
      dismissable: true,
      use24hFormat: !is12Hour,
      buttonBuilder: (instance, context) => DeviceTimePickerSubmitButton(
        picker: instance,
        onTimeSelected: (time) {
          setState(() {
            _selectedHour = time.hour;
            _selectedMinute = time.minute;
          });
          _updateManualTime();
        },
      ),
    ).show(context);
  }
}
