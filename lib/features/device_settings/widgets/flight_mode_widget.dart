import 'package:airspothealth/core/models/device_capabilities.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlightModeWidget extends ConsumerWidget {
  const FlightModeWidget({
    required this.deviceId,
    this.capabilities,
    super.key,
  });

  final String deviceId;
  final DeviceCapabilities? capabilities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSettings = ref.watch(deviceSettingsProvider(deviceId));
    final caps =
        capabilities ?? ref.read(bleDeviceProvider(deviceId)).capabilities;

    // For Slim devices, flight mode is auto-calculated, so show as read-only
    final supportsManual = caps.supportsManualFlightMode();
    final isAutoMode = !supportsManual;

    return SettingItemWidget(
      onTap: () {},
      item: SettingItem(
        title: 'Flight Mode',
        assetIcon: Assets.flightMode,
        suffixWidget: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isAutoMode)
              Text(
                'Auto',
                style: TextStyle(
                  color: context.textTheme.bodySmall?.color,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              RichText(
                text: TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      context.tryLaunchUrl(
                          'https://airspothealth.com/a/blog/flight-mode-airspot');
                    },
                  text: 'Learn more',
                  style: TextStyle(
                    color: context.textTheme.bodyMedium?.color,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            SizedBox(
              height: 24,
              child: Switch(
                value: deviceSettings.flightMode,
                onChanged: isAutoMode
                    ? null // Disable for auto mode
                    : (value) {
                        if (!ref
                            .read(
                                bleDeviceConnectionProvider(deviceId).notifier)
                            .isConnected) {
                          context.showSnackBar('Device is not connected');
                          Navigator.of(context).pop();
                          return;
                        }

                        ref
                            .read(deviceSettingsProvider(deviceId).notifier)
                            .updateSettings(
                              deviceSettings.copyWith(
                                  flightMode: !deviceSettings.flightMode),
                            );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
