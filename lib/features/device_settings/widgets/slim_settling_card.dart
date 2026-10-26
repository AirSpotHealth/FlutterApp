import 'package:airspothealth/core/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import '../models/slim_settling_state.dart';
import '../providers/slim_settling_provider.dart';

// Device owns elapsed time; phone timers never certify recovery.
const showSlimSettlingGuidance = true;

class SlimSettlingCard extends ConsumerWidget {
  const SlimSettlingCard(
      {required this.deviceId,
      this.showInactive = false,
      this.compact = false,
      super.key});
  final String deviceId;
  final bool showInactive;
  final bool compact;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!showSlimSettlingGuidance) return const SizedBox.shrink();
    final device = ref.watch(bleDeviceProvider(deviceId));
    if (device.deviceModel != DeviceModel.airspotSlim ||
        !SlimSettlingState.supported(device.firmwareVersion)) {
      return const SizedBox.shrink();
    }
    final value = ref.watch(slimSettlingProvider(deviceId));
    return value.when(
      loading: () => const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Checking sensor settling status…')),
      error: (e, _) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settling status unavailable',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text(
                  'Could not check recovery progress. Keep Slim nearby, reconnect, and try again.'),
              const SizedBox(height: 16),
              Button(
                type: ButtonType.outlined,
                prefixIcon: const Icon(Icons.refresh, size: 20),
                label: 'Retry settling status',
                onPressed: () =>
                    ref.read(slimSettlingProvider(deviceId).notifier).refresh(),
              ),
            ],
          ),
        ),
      ),
      data: (s) => !showInactive && (s.stage == 0 || s.stage == 4)
          ? const SizedBox.shrink()
          : SettlingGuidance(
              s: s,
              canStartRecovery: SlimSettlingState.continuousRecoverySupported(
                  device.firmwareVersion),
              onOpenDetails: compact
                  ? () => context.pushNamed(RouteNames.deviceSettings,
                      pathParameters: {'deviceId': deviceId})
                  : null,
              onAction: (a) =>
                  ref.read(slimSettlingProvider(deviceId).notifier).act(a)),
    );
  }
}

class SettlingGuidance extends StatelessWidget {
  const SettlingGuidance(
      {required this.s,
      required this.onAction,
      this.onOpenDetails,
      this.canStartRecovery = false,
      super.key});
  final SlimSettlingState s;
  final bool canStartRecovery;
  final ValueChanged<int> onAction;
  final VoidCallback? onOpenDetails;
  String duration(int seconds) {
    final minutes = (seconds / 60).ceil();
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (s.stage) {
      1 => s.running ? 'Sensor settling' : 'Settling paused',
      2 => 'Fresh air needed',
      3 => 'Fresh-air step',
      4 => 'Recovery guidance completed',
      5 => 'Calibration erase needs checking',
      _ =>
        canStartRecovery ? 'Check my readings' : 'No tracked calibration erase',
    };
    if (onOpenDetails != null) {
      return Card(
          child: ListTile(
        dense: true,
        title: Text(title),
        subtitle: Text(s.stage == 1
            ? '${duration(SlimSettlingState.settlingSeconds - s.seconds)} remaining · View guidance'
            : 'View sensor recovery guidance'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpenDetails,
      ));
    }
    final description = switch (s.stage) {
      1 =>
        '${duration(SlimSettlingState.settlingSeconds - s.seconds)} of continuous operation remaining. Readings may be inaccurate. Keep auto-calibration on and the Slim powered in ordinary indoor air, away from heat and direct sun. On firmware 0.21.0 or later, every reporting mode measures continuously; older firmware requires five-second mode. A restart, sensor fault or interruption restarts this settling interval.',
      2 =>
        'The settling interval is complete. Place Slim in fresh outside air for 10 minutes, sheltered from rain and direct sun, away from people, traffic and exhaust. Detach it from your phone and charger. A thoroughly ventilated room is an alternative, but opening a window alone does not guarantee fresh-air conditions. Keep measuring with auto-calibration on.',
      3 =>
        'Keep fresh outside air reaching the device. ${((600 - s.freshSeconds) / 60).ceil()} minutes remaining. Confirm only after the full exposure. The device cannot detect whether the air is fresh.',
      4 =>
        'You confirmed the fresh-air step. This does not certify accuracy. If readings still seem wrong, compare with a trusted meter or contact support.',
      5 =>
        'An erase was started but completion could not be confirmed. Do not assume the sensor is calibrated. Reconnect and check diagnostics before retrying.',
      _ => canStartRecovery
          ? 'If readings seem wrong, run 12 hours of uninterrupted continuous measurement, followed by a separate 10-minute fresh-air step. Keep Slim powered; charge it if needed during the 12-hour stage. This preserves calibration history and does not force a particular CO₂ value.'
          : 'This firmware has no recorded calibration erase. This does not confirm accuracy or reconstruct resets performed on older firmware.',
    };
    return Semantics(
        container: true,
        child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(description),
                      if (canStartRecovery && (s.stage == 0 || s.stage == 4))
                        Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Button(
                              onPressed: () async {
                                final start = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title:
                                        const Text('Start the 12-hour check?'),
                                    content: const Text(
                                        'Slim will enable sensor auto-calibration and track 12 hours of continuous readings. Keep it powered. Afterwards, follow the fresh-air step. Calibration history and saved readings are kept. Completion does not independently verify accuracy.'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Start check')),
                                    ],
                                  ),
                                );
                                if (start == true && context.mounted) {
                                  onAction(3);
                                }
                              },
                              label: 'Start 12-hour check',
                            )),
                      if (s.stage == 1) ...[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                            value:
                                s.seconds / SlimSettlingState.settlingSeconds,
                            semanticsLabel: 'Device-reported settling progress')
                      ],
                      if (s.stage == 2)
                        Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Button(
                                onPressed: () => onAction(1),
                                label: 'Start fresh-air step')),
                      if (s.stage == 3)
                        Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Button(
                                onPressed: s.freshSeconds >= 600 && s.running
                                    ? () => onAction(2)
                                    : null,
                                label: 'I completed the fresh-air exposure')),
                    ]))));
  }
}
