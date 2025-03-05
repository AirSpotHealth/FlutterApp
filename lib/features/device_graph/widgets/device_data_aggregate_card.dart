import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/device_historical_data_provider.dart';
import 'package:airspothealth/features/device_graph/providers/graph_range_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceDataAggregateCard extends ConsumerWidget {
  const DeviceDataAggregateCard({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GraphDataDuration selectedDuration = ref.watch(graphDurationProvider);
    final DeviceHistoryDataRequest request =
        DeviceHistoryDataRequest(deviceId, selectedDuration);

    ref.watch(deviceHistoricalDataProvider(request));

    final DeviceData? minValue =
        ref.read(deviceHistoricalDataProvider(request).notifier).minValue;

    final DeviceData? maxValue =
        ref.read(deviceHistoricalDataProvider(request).notifier).maxValue;

    debugPrint("Min and max values: $minValue, $maxValue");

    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedDuration.durationString,
              style: context.textTheme.labelLarge?.weight600,
            ),
            const SizedBox(height: 4),
            _buildDataRow(context,
                label: 'Highest',
                data: maxValue,
                color: deviceSettings.getValueColor(maxValue?.value)),
            const SizedBox(height: 4),
            _buildDataRow(context,
                label: 'Lowest',
                data: minValue,
                color: deviceSettings.getValueColor(minValue?.value)),
          ],
        ),
      ),
    );
  }

  Row _buildDataRow(BuildContext context,
      {required String label, required DeviceData? data, Color? color}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium
                ?.copyWith(color: AppColors.neutralGrey),
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
          child: Text(
            data != null ? data.dateTime.formatTime() : '00/00 00:00',
            style: context.textTheme.bodyMedium
                ?.copyWith(color: AppColors.neutralGrey),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: RichText(
            textAlign: TextAlign.end,
            text: TextSpan(
              text: data != null
                  ? data.value.toInt().clamp(350, 5000).toString()
                  : '0000',
              style: context.textTheme.bodyMedium?.copyWith(color: color),
              children: const [
                TextSpan(
                  text: ' ppm',
                  style: TextStyle(
                    color: AppColors.neutralGrey,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
