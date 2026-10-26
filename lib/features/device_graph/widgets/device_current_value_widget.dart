import 'package:airspothealth/features/device_settings/widgets/slim_settling_card.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/providers/notification_preferences_provider.dart';
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
    final prefs = ref.watch(notificationPreferencesProvider(deviceId));
    final int? reading = deviceValue is int ? deviceValue : null;
    final level = VentilationBands.forReading(
      reading,
      stuffyThreshold: prefs.stuffyThreshold,
      betterThreshold: prefs.betterThreshold,
      poorThreshold: prefs.poorThreshold,
    );
    final value = !powerState.isCharging && powerState.level == 0
        ? '----'
        : deviceValue != null
            ? "${AppUtils.getDisplayCO2Value(deviceValue!)}"
            : '0000';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SlimSettlingCard(deviceId: deviceId, compact: true),
        if (powerState.lowBatteryLockout)
          _LowBatteryLockoutBanner(isCharging: powerState.isCharging),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current ${Constants.co2Text} Level: ',
                        style: context.textTheme.bodyMedium?.weight600,
                      ),
                      if (reading != null) ...[
                        const SizedBox(height: 4),
                        _StateChip(level: level),
                      ],
                    ],
                  ),
                ),
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

/// Written ventilation state with icon, so colour is never the only cue.
class _StateChip extends StatelessWidget {
  const _StateChip({required this.level});

  final VentilationLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: level.paleColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: level.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(level.icon, size: 14, color: level.color),
          const SizedBox(width: 4),
          Text(
            level.stateLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: level.color,
            ),
          ),
        ],
      ),
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
