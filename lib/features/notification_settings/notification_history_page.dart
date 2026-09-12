import 'package:airspothealth/core/models/ventilation_event.dart';
import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:airspothealth/core/providers/ventilation_history_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/local_date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Past and current ventilation events for a device.
class NotificationHistoryPage extends ConsumerWidget {
  const NotificationHistoryPage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(ventilationHistoryProvider(deviceId));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Notification history', style: TextStyle(fontSize: 18)),
      ),
      body: events.isEmpty
          ? const _EmptyHistory()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _EventTile(
                event: events[index],
                onTap: () => context.pushNamed(
                  RouteNames.ventilationEventDetail,
                  pathParameters: {
                    'deviceId': deviceId,
                    'eventId': events[index].id,
                  },
                ),
              ),
            ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none_rounded,
                size: 48, color: AppColors.neutralGrey),
            const SizedBox(height: 12),
            Text(
              'No ventilation events yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Alerts, the actions you record and how the air improved afterwards will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary of an event: state colour chip, title, reading and time.
class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.onTap});

  final VentilationEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final level = event.highestLevelNotified;
    final recovered = event.status == VentilationEventStatus.recovered;
    final displayLevel = recovered ? VentilationLevel.none : level;
    final title = recovered ? VentilationCopy.recoveryTitle : level.title;
    final subtitle = recovered && event.recoveryValue != null
        ? 'CO₂ fell from ${VentilationCopy.ppm(event.peakValue)} to ${VentilationCopy.ppm(event.recoveryValue!)} ppm'
        : event.status == VentilationEventStatus.expired
            ? 'Peak ${VentilationCopy.ppm(event.peakValue)} ppm, readings stopped'
            : 'Peak ${VentilationCopy.ppm(event.peakValue)} ppm, still ongoing';
    final df = LocalDateFormat.instance;
    final when =
        '${df.systemDateFormat.format(event.startedAt)} ${df.systemTimeFormat.format(event.startedAt)}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: displayLevel.paleColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(displayLevel.icon, color: displayLevel.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(when,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textTertiary)),
                  ],
                ),
              ),
              if (event.userAction != VentilationUserAction.none)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.task_alt_rounded,
                      size: 18, color: AppColors.ventGreen),
                ),
              const Icon(Icons.chevron_right, color: AppColors.neutralGrey),
            ],
          ),
        ),
      ),
    );
  }
}
