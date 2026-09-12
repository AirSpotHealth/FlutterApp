import 'package:airspothealth/core/models/ventilation_event.dart';
import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:airspothealth/core/providers/ventilation_history_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/local_date_format.dart';
import 'package:airspothealth/features/notification_settings/widgets/notification_settings_widgets.dart';
import 'package:airspothealth/features/notification_settings/widgets/taken_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "View result": start, peak, current value, elapsed time, recorded action
/// and recovery outcome for one ventilation event.
class VentilationEventDetailPage extends ConsumerWidget {
  const VentilationEventDetailPage({
    required this.deviceId,
    required this.eventId,
    super.key,
  });

  final String deviceId;
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(ventilationEventProvider(eventId));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Ventilation event', style: TextStyle(fontSize: 18)),
      ),
      body: event == null
          ? const Center(child: Text('This event is no longer available.'))
          : _Body(event: event),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.event});

  final VentilationEvent event;

  @override
  Widget build(BuildContext context) {
    final df = LocalDateFormat.instance;
    String fmt(DateTime t) =>
        '${df.systemDateFormat.format(t)} ${df.systemTimeFormat.format(t)}';

    final recovered = event.status == VentilationEventStatus.recovered;
    final headerLevel =
        recovered ? VentilationLevel.none : event.highestLevelNotified;
    final endValue = event.recoveryValue ?? event.lastValue;
    final elapsedFrom = event.userActionAt ?? event.peakAt;
    final elapsedTo = event.recoveredAt ?? event.lastReadingAt;
    final elapsed = elapsedTo.difference(elapsedFrom);

    final String outcome;
    if (recovered) {
      outcome = event.userAction == VentilationUserAction.none
          ? 'The air improved. CO₂ fell from ${VentilationCopy.ppm(event.peakValue)} to ${VentilationCopy.ppm(endValue)} ppm in ${VentilationCopy.elapsed(elapsed)}.'
          : 'Your action was followed by improvement. CO₂ fell from ${VentilationCopy.ppm(event.peakValue)} to ${VentilationCopy.ppm(endValue)} ppm in ${VentilationCopy.elapsed(elapsed)}.';
    } else if (event.status == VentilationEventStatus.expired) {
      outcome =
          'Readings stopped before the air was confirmed to have improved, so no result was recorded.';
    } else {
      outcome = 'Still monitoring. AirSpot will let you know when the air improves.';
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: headerLevel.paleColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: headerLevel.color.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(headerLevel.icon, color: headerLevel.color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recovered
                          ? VentilationCopy.recoveryTitle
                          : event.highestLevelNotified.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(outcome, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SettingsSectionHeader('Readings'),
        SettingsCard(children: [
          _row('Started', '${VentilationCopy.ppm(event.startValue)} ppm',
              fmt(event.startedAt)),
          _row('Peak', '${VentilationCopy.ppm(event.peakValue)} ppm',
              fmt(event.peakAt)),
          _row(
              recovered ? 'Improved to' : 'Latest',
              '${VentilationCopy.ppm(endValue)} ppm',
              fmt(event.recoveredAt ?? event.lastReadingAt)),
          _row('Elapsed', VentilationCopy.elapsed(elapsed),
              event.userActionAt != null ? 'Since your action' : 'Since the peak'),
        ]),
        const SettingsSectionHeader('Your action'),
        SettingsCard(children: [
          ListTile(
            leading: Icon(event.userAction.icon,
                color: event.userAction == VentilationUserAction.none
                    ? AppColors.neutralGrey
                    : AppColors.ventGreen),
            title: Text(event.userAction.label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: event.userActionAt == null
                ? null
                : Text(fmt(event.userActionAt!),
                    style: const TextStyle(fontSize: 12)),
            trailing: event.isActive
                ? TextButton(
                    onPressed: () => showTakenActionSheet(context,
                        deviceId: event.deviceId),
                    child: Text(event.userAction == VentilationUserAction.none
                        ? 'Record'
                        : 'Change'),
                  )
                : null,
          ),
        ]),
        const SettingsSectionHeader('Notifications sent'),
        SettingsCard(children: [
          if (event.notifications.isEmpty)
            const ListTile(title: Text('None')),
          for (final n in event.notifications)
            ListTile(
              leading: Icon(
                n.kind == VentilationNotificationKind.recovery
                    ? VentilationLevel.none.icon
                    : n.level.icon,
                color: n.kind == VentilationNotificationKind.recovery
                    ? VentilationLevel.none.color
                    : n.level.color,
              ),
              title: Text(
                n.kind == VentilationNotificationKind.recovery
                    ? VentilationCopy.recoveryTitle
                    : n.level.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${n.kind == VentilationNotificationKind.reminder ? 'Reminder, ' : ''}${VentilationCopy.ppm(n.co2)} ppm${n.sentAt != null ? ', ${fmt(n.sentAt!)}' : ''}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ]),
      ],
    );
  }

  Widget _row(String label, String value, String detail) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(detail, style: const TextStyle(fontSize: 12)),
      trailing: Text(value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }
}
