import 'package:airspothealth/features/device_settings/widgets/slim_diagnostics_export.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/app_utils.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/providers/ble_device_version_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/devices/providers/device_battery_level_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The 0x37 diagnostic journal command only exists from Slim firmware 0.17.0
/// onward (still beta / not yet released). Older firmware times out on it.
const _minDiagnosticsFirmwareVersion = '0.17.0';

/// AirSpot Slim has no screen — the RGB LED shows CO₂ zones and charging status.
/// This page explains LED behavior and exposes settings that affect the LED.
class SlimStatusPage extends ConsumerWidget {
  const SlimStatusPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battery = ref.watch(deviceBatteryLevelProvider(deviceId));
    final settings = ref.watch(deviceSettingsProvider(deviceId));
    final firmwareVersion = ref.watch(bleDeviceVersionProvider(deviceId));
    final supportsDiagnostics = firmwareVersion != null &&
        !AppUtils.isVersionGreater(
            firmwareVersion, _minDiagnosticsFirmwareVersion);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: DeviceSettingsNameWidget(
          deviceId: deviceId,
          suffixText: 'LED & charging guide',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Section(
            title: 'What the LED means',
            child: Text(
                'The LED usually stays off; press the button to check status or CO₂ level:\n\n'
                '• Single press — connection and battery status\n'
                '• Double press — CO₂ level'),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Single press — device status displayed for 5 seconds',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ledRow(context,
                    color: Colors.blue,
                    title: 'Blue — connected to your phone'),
                _ledRow(context,
                    color: Colors.white, title: 'White — not connected'),
                _ledRow(context, color: Colors.red, title: 'Red — low battery'),
                _ledRow(
                  context,
                  color: Colors.red,
                  title: 'Flashing red — critically low battery',
                  body: 'Place the Slim on its charging pad.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Double press — CO₂ level display',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Press twice within half a second. The last reading’s colour flashes for 5 seconds, then the fresh reading’s colour stays steady for 5 seconds before turning off.'),
                const SizedBox(height: 12),
                _ledRow(
                  context,
                  color: Colors.green,
                  title: 'Green — lower CO₂',
                  body:
                      'Below your green limit (${settings.greenUpperLimit} ppm).',
                ),
                _ledRow(
                  context,
                  color: Colors.amber,
                  title: 'Amber — moderate CO₂',
                  body:
                      'At or above your green limit (${settings.greenUpperLimit} ppm) and below your amber limit (${settings.yellowUpperLimit} ppm).',
                ),
                _ledRow(
                  context,
                  color: Colors.red,
                  title: 'Red — higher CO₂',
                  body:
                      'At or above your amber limit (${settings.yellowUpperLimit} ppm). A red status indication after a single press refers to battery level instead.',
                ),
                TextButton(
                  onPressed: () => context.pushNamed(
                    RouteNames.slimLedSettings,
                    pathParameters: {'deviceId': deviceId},
                  ),
                  child: const Text('Change CO₂ zones in CO₂ Zone Settings'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Lights you may see automatically',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ledRow(
                  context,
                  color: Colors.green,
                  title: 'Green — brief connection flash',
                  body: 'The Slim has just connected to your phone.',
                ),
                _ledRow(
                  context,
                  color: Colors.blue,
                  title: 'Blue pulse every 5 seconds',
                  body:
                      'Calibration is in progress. Button gestures are ignored until calibration finishes.',
                ),
                _ledRow(
                  context,
                  color: Colors.white,
                  title: 'White — rapid flashing',
                  body: 'Find My Device was requested from the app.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _Section(
            title: 'Charging your Slim',
            child: Text(
              'When placed on the charging pad, the Slim displays the same five-second status light as a single press.\n\n'
              'The LED turns off after the initial status indication. This is normal—the LED does not remain illuminated while charging.',
            ),
          ),
          const SizedBox(height: 16),
          _Section(
            title: 'Battery and charging-pad status in the AIRSPOT app',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/slim_battery_guide.jpeg',
                  semanticLabel:
                      'Example AIRSPOT device card with the battery icon at the lower left and an 88% battery tooltip.',
                ),
                const SizedBox(height: 12),
                const Text(
                  'The battery icon may show:\n'
                  '• battery percentage\n'
                  '• battery percentage unknown\n'
                  '• low battery — charging required\n'
                  '• charging pad detected',
                ),
                const SizedBox(height: 12),
                Text(
                  battery.lowBatteryLockout
                      ? 'App shows: low battery — charging required${battery.level != null ? " (${battery.level}%)" : ""}'
                      : battery.isCharging
                          ? 'App shows: charging pad detected${battery.level != null ? " (${battery.level}%)" : ""}'
                          : 'App shows: ${battery.level != null ? "${battery.level}% battery" : "battery percentage unknown"}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  'To confirm charging, wait several minutes, use Refresh battery status under Low-battery protection below, and check that the percentage has increased. Tap the battery icon on the device card to view its status.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _CollapsibleSection(
            title: 'Low-battery protection',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'If the battery gets critically low, the Slim automatically shuts down Bluetooth and the sensors to protect the battery cell — the app will show it as disconnected.\n\n'
                  'Leave the device on the charger: once sufficiently charged, it restarts and becomes available to reconnect.\n\n'
                  'When the Slim enters low-battery protection mode while on the charging pad, the LED flashes red briefly and then turns off. If it enters this mode away from the charging pad, the LED briefly fades red and then turns off.',
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
          const _CollapsibleSection(
            title: 'Power & restart',
            child: Text(
              '• While the Slim is on the charging pad, hold the button for five seconds to turn it off or on. The light fades out when turning off and fades in during the power-on hold.\n\n'
              '• While the Slim is powered on and on the charging pad, press the button five times quickly to restart it.',
            ),
          ),
          if (supportsDiagnostics)
            _CollapsibleSection(
              title: 'Export diagnostics',
              child: SlimDiagnosticsExport(deviceId: deviceId),
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
        Semantics(
          header: true,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: PageStorageKey(title),
      maintainState: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      children: [child],
    );
  }
}

Widget _ledRow(
  BuildContext context, {
  required Color color,
  required String title,
  String? body,
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
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              if (body != null) ...[
                const SizedBox(height: 2),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
