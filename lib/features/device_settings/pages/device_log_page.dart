import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/services/data_logger_service.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/providers/device_log_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceLogPage extends ConsumerWidget {
  const DeviceLogPage({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  Map<DateTime, String> parseLog(String log) {
    final lines = log.split('\n');
    final entries = <DateTime, String>{};
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split(',');
      if (parts.length >= 2) {
        final datetimeString = parts[0].trim();
        final value = parts[1].trim();

        final datetime = DateTime.tryParse(datetimeString);
        if (datetime != null) {
          entries[datetime] = value;
        }
      }
    }

    return entries;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String> deviceLog = ref.watch(deviceLogProvider(deviceId));
    final DeviceSettings settings = ref.watch(deviceSettingsProvider(deviceId));

    debugPrint('DeviceLogPage: $deviceLog, ');

    return Scaffold(
      appBar: AppBar(
        title: Text('$deviceId log'),
        actions: [
          Switch(
            value: settings.logData,
            activeTrackColor: AppColors.brandColorAmber,
            onChanged: (value) => ref
                .read(deviceSettingsProvider(deviceId).notifier)
                .updateSettings(settings.copyWith(logData: value)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: deviceLog.when(
        data: (log) {
          final entries = parseLog(log);

          if (entries.isEmpty) {
            return const Center(child: Text('No log entries available'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries.entries.elementAt(index);
                    return ListTile(
                      title: Text('HexValue: ${entry.value}'),
                      subtitle: Text('Date: ${entry.key.formatLocalDate()}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error loading device log'),
              ElevatedButton(
                onPressed: () => ref.invalidate(deviceLogProvider(deviceId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: settings.logData
          ? _buildActions(ref)
          : const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Log data is disabled. Enable it in the top right to view the log.',
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  Padding _buildActions(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: OverflowBar(
        overflowAlignment: OverflowBarAlignment.end,
        alignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ref.context).primaryColor,
            ),
            onPressed: () => ref.invalidate(deviceLogProvider(deviceId)),
            child: const Text('Refresh'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandColorRed,
            ),
            onPressed: () {
              DataLoggerService().clearLogData(deviceId);

              ref.invalidate(deviceLogProvider(deviceId));
            },
            child: const Text('Clear Log'),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
