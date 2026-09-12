import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:airspothealth/core/providers/ventilation_alert_provider.dart';
import 'package:airspothealth/core/services/ventilation_notification_coordinator.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/notification_settings/widgets/guidance_sheet.dart';
import 'package:airspothealth/features/notification_settings/widgets/taken_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AirSpot-controlled foreground alert. Full state colour, written state and
/// icon, two actions. The dark-red state pulses once on entry and then stays
/// static; the pulse is skipped when the platform asks for reduced motion.
class VentilationAlertCard extends ConsumerWidget {
  const VentilationAlertCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alert = ref.watch(ventilationAlertProvider);
    if (alert == null) return const SizedBox.shrink();
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: _AlertBody(key: ValueKey(alert.eventId + alert.kind.name), alert: alert),
      ),
    );
  }
}

class _AlertBody extends ConsumerStatefulWidget {
  const _AlertBody({required this.alert, super.key});

  final VentilationAlert alert;

  @override
  ConsumerState<_AlertBody> createState() => _AlertBodyState();
}

class _AlertBodyState extends ConsumerState<_AlertBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.03), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final highPriority = widget.alert.level == VentilationLevel.poor &&
        !widget.alert.isRecovery;
    if (highPriority && !reduceMotion && !_pulse.isAnimating && _pulse.value == 0) {
      _pulse.forward(); // exactly one pulse, never repeated
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    final level = alert.displayLevel;
    final coordinator = ref.read(ventilationCoordinatorProvider);

    void dismiss() => coordinator.dismiss(alert.deviceId);

    final List<Widget> actions;
    if (alert.isRecovery) {
      actions = [
        _ActionButton(
          label: VentilationActionIds.viewResultLabel,
          color: level.color,
          onPressed: () {
            dismiss();
            coordinator.openEventDetail(alert.deviceId, alert.eventId);
          },
        ),
        _ActionButton(
          label: VentilationActionIds.doneLabel,
          color: level.color,
          onPressed: dismiss,
        ),
      ];
    } else {
      actions = [
        if (alert.level == VentilationLevel.better)
          _ActionButton(
            label: VentilationActionIds.whatCanIDoLabel,
            color: level.color,
            onPressed: () =>
                showGuidanceSheet(context, deviceId: alert.deviceId),
          )
        else
          _ActionButton(
            label: VentilationActionIds.takenActionLabel,
            color: level.color,
            onPressed: () {
              dismiss();
              showTakenActionSheet(context, deviceId: alert.deviceId);
            },
          ),
        if (alert.remindersEnabled)
          _ActionButton(
            label: VentilationActionIds.remindLabel(alert.reminderMinutes),
            color: level.color,
            onPressed: () =>
                coordinator.requestReminder(alert.deviceId, alert.level),
          ),
      ];
    }

    return ScaleTransition(
      scale: _scale,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(14),
        color: level.paleColor,
        child: Semantics(
          liveRegion: true,
          label: '${alert.title}. ${alert.body}',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: level.color.withValues(alpha: 0.5)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: level.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(level.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alert.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(alert.body,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: AppColors.textSecondary,
                      tooltip: 'Dismiss',
                      onPressed: dismiss,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      actions[i],
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: color,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        visualDensity: VisualDensity.compact,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
