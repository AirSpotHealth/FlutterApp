import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/widgets/co2_ppm_range_picker_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_ui_mode_widget.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: DeviceSettingsNameWidget(
        deviceId: widget.deviceId,
        suffixText: 'Screen Settings',
      )),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          DeviceUIModeWidget(
            deviceId: widget.deviceId,
            scrollController: _scrollController,
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Co2PpmRangePickerWidget(deviceId: widget.deviceId),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Screen on Continuously',
                  style: context.textTheme.bodyMedium?.weight600,
                ),
              ),
              Switch(
                  value: deviceSettings.continuosScreenEnabled,
                  onChanged: (value) {
                    ref
                        .read(deviceSettingsProvider(widget.deviceId).notifier)
                        .updateSettings(deviceSettings.copyWith(
                            continuosScreenEnabled: value));
                  }),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'To maintain battery power the screen is on for 10 seconds in low and medium power modes and 1 minute in high power mode.',
            style: context.textTheme.bodySmall?.weight500?.copyWith(
              color: context.textTheme.bodySmall?.color?.withValues(alpha: .7),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
