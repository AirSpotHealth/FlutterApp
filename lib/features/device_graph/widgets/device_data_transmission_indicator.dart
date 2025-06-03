import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:airspothealth/features/device_graph/providers/graph_range_provider.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceDataTransmissionIndicator extends ConsumerWidget {
  const DeviceDataTransmissionIndicator({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncProgressValue progress =
        ref.watch(deviceHistoryDataRequestProvider(deviceId));

    if (progress is AsyncInProgress) {
      return Container(
        padding: const EdgeInsets.all(8),
        width: context.width - 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                progress.message ?? t.deviceGraph.fetchingData,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (progress is AsyncFailure) {
      return Container(
        padding: const EdgeInsets.all(8),
        width: context.width,
        decoration: BoxDecoration(color: Colors.red),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(progress.error.toString(),
                  style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Button(
              wrapWidth: true,
              onPressed: () {
                ref
                    .read(deviceHistoryDataRequestProvider(deviceId).notifier)
                    .request(ref.read(graphDurationProvider));
              },
              child: Text(t.devices.retryNow),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }
}
