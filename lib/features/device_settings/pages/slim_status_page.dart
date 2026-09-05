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
                _ledRow(
                  color: Colors.blue,
                  title: 'Blue — gentle breathing',
                  body:
                      'On and idle (not connected to the app). Off the charger it gives one soft breath every ~10 seconds to save battery; on the charger it breathes continuously.',
                ),
                _ledRow(
                  color: Colors.white,
                  title: 'White — breathing (~20 s at startup)',
                  body:
                      'Warming up: right after power-on the CO₂ sensor conditions itself for about 22 seconds. Readings aren’t ready until it finishes.',
                ),
                _ledRow(
                  color: Colors.green,
                  title: 'Green',
                  body:
                      'Air quality is good — CO₂ below your green threshold (default ${settings.greenUpperLimit} ppm).',
                ),
                _ledRow(
                  color: Colors.amber,
                  title: 'Amber',
                  body:
                      'CO₂ is moderate — between your green and yellow thresholds.',
                ),
                _ledRow(
                  color: Colors.red,
                  title: 'Red',
                  body:
                      'CO₂ is high — above your yellow threshold (default ${settings.yellowUpperLimit} ppm). A slow red breath/flash instead means low battery (see below).',
                ),
                _ledRow(
                  color: Colors.green,
                  title: 'Green — quick flash',
                  body: 'The app just connected to the device.',
                ),
                const SizedBox(height: 8),
                Text(
                  'The air-quality colour (green / amber / red) is shown when you’re connected and when the device is on the charger. When idle and unplugged it rests on the soft blue breath. Lower the CO₂ limits below to change when the colour switches.',
                  style: Theme.of(context).textTheme.bodySmall,
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
                  'Place the Slim on its wireless (Qi) charging pad. While charging, the LED briefly shows white and then the current air-quality colour.',
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
                  'If the battery gets critically low, the Slim automatically shuts down Bluetooth and the sensors to protect the cell — it stops advertising and the app will show it as disconnected. This is normal. Just leave it on the charger: once it has charged back up enough, it restarts and reconnects on its own. While protecting itself it shows a slow red flash.',
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
