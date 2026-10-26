import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import '../models/slim_settling_state.dart';
import '../providers/slim_settling_provider.dart';

// Temporarily hidden for this release; retain device-owned tracking and UI for the next update.
const showSlimSettlingGuidance = false;

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
          child: ListTile(
              title: const Text('Settling status unavailable'),
              subtitle: Text('$e'),
              trailing: IconButton(
                  tooltip: 'Retry settling status',
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref
                      .read(slimSettlingProvider(deviceId).notifier)
                      .refresh()))),
      data: (s) => !showInactive && (s.stage == 0 || s.stage == 4)
          ? const SizedBox.shrink()
          : SettlingGuidance(
              s: s,
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
      {required this.s, required this.onAction, this.onOpenDetails, super.key});
  final SlimSettlingState s;
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
      _ => 'No tracked calibration erase',
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
        '${duration(SlimSettlingState.settlingSeconds - s.seconds)} of continuous operation remaining. Readings may be inaccurate. Keep native auto-calibration on and use five-second mode in ordinary indoor air, away from heat and direct sun. A restart, sensor fault or interruption restarts this settling interval.',
      2 =>
        'The settling interval is complete. Open a window to ventilate the room with outside air for 10 minutes. Keep measuring with auto-calibration on. You do not need to take the device outdoors.',
      3 =>
        'Keep fresh outside air reaching the device. ${((600 - s.freshSeconds) / 60).ceil()} minutes remaining. Confirm only after the full exposure. The device cannot detect whether the air is fresh.',
      4 =>
        'You confirmed the fresh-air step. This does not certify accuracy. If readings still seem wrong, compare with a trusted meter or contact support.',
      5 =>
        'An erase was started but completion could not be confirmed. Do not assume the sensor is calibrated. Reconnect and check diagnostics before retrying.',
      _ =>
        'This firmware has no recorded calibration erase. This does not confirm accuracy or reconstruct resets performed on older firmware.',
    };
    return Semantics(
        container: true,
        child: Card(
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
                      if (s.stage == 1) ...[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                            value:
                                s.seconds / SlimSettlingState.settlingSeconds,
                            semanticsLabel: 'Device-reported settling progress')
                      ],
                      if (s.stage == 2)
                        TextButton(
                            onPressed: () => onAction(1),
                            child: const Text('Start fresh-air step')),
                      if (s.stage == 3)
                        TextButton(
                            onPressed: s.freshSeconds >= 600 && s.running
                                ? () => onAction(2)
                                : null,
                            child: const Text(
                                'I completed the fresh-air exposure')),
                    ]))));
  }
}
