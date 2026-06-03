import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/app_utils.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/devices/providers/device_battery_level_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceCurrentValueWidget extends ConsumerWidget {
  const DeviceCurrentValueWidget({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceValue = ref.watch(bleDeviceCommunicationProvider(deviceId));
    final powerState = ref.watch(deviceBatteryLevelProvider(deviceId));
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));
    final value = !powerState.isCharging && powerState.level == 0
        ? '----'
        : deviceValue != null
            ? "${AppUtils.getDisplayCO2Value(deviceValue!)}"
            : '0000';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (powerState.lowBatteryLockout)
          _LowBatteryLockoutBanner(isCharging: powerState.isCharging),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Text(
                  'Current ${Constants.co2Text} Level: ',
                  style: context.textTheme.bodyMedium?.weight600,
                ),
                const Spacer(),
                RichText(
                  text: TextSpan(
                    text: value,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: deviceSettings.getValueColor(deviceValue),
                      fontWeight: FontWeight.bold,
                    ),
                    children: const [
                      TextSpan(
                        text: '  ppm',
                        style: TextStyle(
                          color: AppColors.neutralGrey,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Shown when the device reports it is entering low-battery lockout: it drops
/// BLE to protect a near-empty cell and reconnects automatically once charged.
class _LowBatteryLockoutBanner extends StatelessWidget {
  const _LowBatteryLockoutBanner({required this.isCharging});

  final bool isCharging;

  @override
  Widget build(BuildContext context) {
    final message = isCharging
        ? 'Low battery — charging. The device will reconnect automatically '
            'once it has charged enough.'
        : 'Low battery — please place the device on the charger. It will '
            'reconnect automatically once charged.';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandColorAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.brandColorAmber.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.battery_alert_rounded,
              color: AppColors.brandColorRed, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
