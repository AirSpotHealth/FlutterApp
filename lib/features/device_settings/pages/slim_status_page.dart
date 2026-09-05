import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/widgets/co2_ppm_range_picker_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/devices/providers/device_battery_level_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AirSpot Slim has no screen — the RGB LED shows CO₂ zones and charging status.
/// This page explains LED behavior and exposes settings that affect the LED.
class SlimStatusPage extends ConsumerWidget {
  const SlimStatusPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battery = ref.watch(deviceBatteryLevelProvider(deviceId));
    final settings = ref.watch(deviceSettingsProvider(deviceId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: DeviceSettingsNameWidget(
          deviceId: deviceId,
          suffixText: 'LED & status',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'What the LED means',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'For Slim firmware 0.15.0. The LED normally stays off; press the button to check status or air quality.'),
                const SizedBox(height: 12),
                _ledRow(
                  color: Colors.blue,
                  title: 'Single press — device status for 5 seconds',
                  body:
                      'Blue means currently connected to a phone. White means not connected. Red means low battery; a fast red flash means critically low battery.',
                ),
                _ledRow(
                  color: Colors.green,
                  title: 'Double press — air quality',
                  body:
                      'Press twice within half a second. The last reading’s colour flashes for 5 seconds, then the fresh reading’s colour stays steady for 5 seconds before turning off.',
                ),
                _ledRow(
                  color: Colors.green,
                  title: 'Green — lower CO₂',
                  body:
                      'Below your green limit (${settings.greenUpperLimit} ppm).',
                ),
                _ledRow(
                  color: Colors.amber,
                  title: 'Amber — moderate CO₂',
                  body:
                      'At or above ${settings.greenUpperLimit} ppm and below ${settings.yellowUpperLimit} ppm.',
                ),
                _ledRow(
                  color: Colors.red,
                  title: 'Red — higher CO₂',
                  body:
                      'At or above your yellow limit (${settings.yellowUpperLimit} ppm). A red status indication after a single press refers to battery level instead.',
                ),
                _ledRow(
                  color: Colors.green,
                  title: 'Green — brief connection flash',
                  body: 'A phone has just connected.',
                ),
                _ledRow(
                  color: Colors.blue,
                  title: 'Blue pulse every 5 seconds',
                  body:
                      'Calibration is in progress. Button gestures are ignored until calibration finishes.',
                ),
                _ledRow(
                  color: Colors.white,
                  title: 'White — rapid flashing',
                  body: 'Find My Device was requested from the app.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Battery & charging',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  battery.lowBatteryLockout
                      ? 'App shows: low battery — charging required${battery.level != null ? " (${battery.level}%)" : ""}'
                      : battery.isCharging
                          ? 'App shows: charging${battery.level != null ? " (${battery.level}%)" : ""}'
                          : 'App shows: ${battery.level != null ? "${battery.level}% battery" : "battery unknown"}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Charging',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Place Slim on its wireless Qi charging pad. When powered on, placing it on the pad shows the same 5-second status indication as a single press, then the LED turns off. A dark LED does not mean charging has stopped. Check charging status in the app.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                Text(
                  'Low-battery protection',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'If the battery gets critically low, the Slim automatically shuts down Bluetooth and the sensors to protect the cell — it stops advertising and the app will show it as disconnected. This is normal. Leave it on the charger: once sufficiently charged, it restarts and becomes available to reconnect. On entering protection while charging, it flashes red briefly, then goes dark; off the charger, it briefly fades red and goes dark.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(bleDeviceCommunicationProvider(deviceId).notifier)
                        .sendCommand(DeviceCmdUtils.getBatteryLevel());
                    if (context.mounted) {
                      context.showSnackBar('Battery status requested');
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh battery status'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Power & restart',
            child: Text(
              'On the Qi pad, hold the button for 5 seconds to turn Slim off or on. The light fades out when turning off and fades in during the power-on hold. Release early to cancel power-on. A long hold off the charger does nothing.\n\nWhile powered on and charging, press 5 times quickly to restart Slim. This is a reboot, not a factory reset.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'CO₂ levels for LED colours',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'These limits are sent to the device and control when the LED turns green, amber, or red.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Co2PpmRangePickerWidget(deviceId: deviceId),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Calibration',
            child: Text(
              'Use Settings → Calibrate Device while connected. Place the Slim outdoors in fresh air for at least 5 minutes, set target ~420–450 ppm, then tap the calibration icon.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

Widget _ledRow({
  required Color color,
  required String title,
  required String body,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(top: 3, right: 10),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(body, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    ),
  );
}
