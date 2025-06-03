import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/services/data_logger_service.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_settings/models/log_data.dart';
import 'package:airspothealth/features/device_settings/providers/device_log_provider.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceLogPage extends ConsumerWidget {
  const DeviceLogPage({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  List<LogData> parseLog(String log) {
    final lines = log.split('\n');
    final entries = <LogData>[];
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split(',');
      if (parts.length >= 2) {
        final datetimeString = parts[0].trim();
        final value = parts[1].trim();
        final sent = parts.length > 2 ? parts[2].trim() == 'sent' : false;

        final datetime = DateTime.tryParse(datetimeString);
        if (datetime != null) {
          entries.add(
            LogData(
              dateTime: datetime,
              value: value,
              deviceId: deviceId,
              sent: sent,
            ),
          );
        }
      }
    }

    return entries..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<String> deviceLog = ref.watch(deviceLogProvider(deviceId));
    final BleDevice device = ref.read(bleDeviceProvider(deviceId));

    return Scaffold(
        appBar: AppBar(
          title: Text(t.deviceSettings
              .deviceLog(deviceName: device.alias ?? device.name)),
          actions: [
            IconButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.invalidate(deviceLogProvider(deviceId));
                });
              },
              icon: Icon(Icons.refresh),
            ),
            IconButton(
              iconSize: 24,
              onPressed: () {
                DataLoggerService().clearLogData(deviceId);
                ref.invalidate(deviceLogProvider(deviceId));
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ),
        body: deviceLog.when(
          data: (log) {
            final entries = parseLog(log);

            if (entries.isEmpty) {
              return Center(
                  child: Text(t.deviceSettings.noLogEntriesAvailable));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return ListTile(
                        title: Text('${entry.value}'),
                        subtitle: Text(
                          entry.dateTime.formatLocalDate(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                        leading: Icon(
                          entry.sent
                              ? CupertinoIcons.device_phone_portrait
                              : Icons.watch,
                          color: entry.sent ? Colors.red : Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Text(t.deviceSettings.errorLoadingDeviceLog),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            DataLoggerService().downloadLogData(deviceId);
          },
          backgroundColor: AppColors.primaryColor,
          child: const Icon(Icons.download),
        ));
  }
}
