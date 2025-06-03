import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/providers/device_asc_day_count_provider.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class NextCalibrationDateWidget extends ConsumerStatefulWidget {
  const NextCalibrationDateWidget({
    required this.deviceId,
    super.key,
  });

  final String deviceId;

  @override
  ConsumerState<NextCalibrationDateWidget> createState() =>
      _NextCalibrationDateWidgetState();
}

class _NextCalibrationDateWidgetState
    extends ConsumerState<NextCalibrationDateWidget> {
  @override
  void initState() {
    super.initState();

    ref
        .read(bleDeviceCommunicationProvider(widget.deviceId).notifier)
        .sendCommand(DeviceCmdUtils.getAscDayCount());
  }

  @override
  Widget build(BuildContext context) {
    final nextAscDateState = ref.watch(deviceAscDayProvider(widget.deviceId));
    debugPrint('nextAscDateState: $nextAscDateState');

    return nextAscDateState.when(
      data: (nextAscDate) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(t.deviceSettings.nextAutoCalibration,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                // 23:59 12-03-2025
                nextAscDate != null
                    ? DateFormat('HH:mm dd-MM-yyyy').format(nextAscDate)
                    : 'N/A',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Text(error.toString()),
      loading: () => const CircularProgressIndicator(),
    );
  }
}
