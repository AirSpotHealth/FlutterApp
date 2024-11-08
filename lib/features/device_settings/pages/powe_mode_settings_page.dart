import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PowerModeSettingsPage extends ConsumerWidget {
  const PowerModeSettingsPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    final BleDevice bleDevice = ref.watch(bleDeviceProvider(deviceId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            '${bleDevice.alias ?? bleDevice.name} CO${Constants.subscript2} reading rate'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPowerModeItem(
                    asset: Assets.lowBattery,
                    isSelected: deviceSettings.powerMode == PowerMode.low,
                    onTap: () => _updatePowerMode(
                        ref, deviceSettings.copyWith(powerMode: PowerMode.low)),
                    description:
                        'CO${Constants.subscript2} level updates every 3 minute'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPowerModeItem(
                    asset: Assets.mediumBattery,
                    isSelected: deviceSettings.powerMode == PowerMode.medium,
                    onTap: () => _updatePowerMode(ref,
                        deviceSettings.copyWith(powerMode: PowerMode.medium)),
                    description:
                        'CO${Constants.subscript2} level updates every 1 minute'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPowerModeItem(
                    asset: Assets.highBattery,
                    isSelected: deviceSettings.powerMode == PowerMode.high,
                    onTap: () => _updatePowerMode(ref,
                        deviceSettings.copyWith(powerMode: PowerMode.high)),
                    description:
                        'CO${Constants.subscript2} level updates every 5 seconds'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
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
                onChanged: (value) => _updatePowerMode(ref,
                    deviceSettings.copyWith(continuosScreenEnabled: value)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              'To maintain battery power the screen is on for 10 seconds in low and medium power modes and 1 minute in high power mode. We recommend continuos screen display is only turned on when the device is being charged.',
              style: context.textTheme.bodySmall?.weight500),
        ],
      ),
    );
  }

  void _updatePowerMode(WidgetRef ref, DeviceSettings deviceSettings) {
    return ref
        .read(deviceSettingsProvider(deviceId).notifier)
        .updateSettings(deviceSettings);
  }

  Widget _buildPowerModeItem({
    required String asset,
    required bool isSelected,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Image.asset(
              asset,
              width: 64,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primaryColor : Colors.grey,
              size: 20,
            ),
          ],
        ));
  }
}
