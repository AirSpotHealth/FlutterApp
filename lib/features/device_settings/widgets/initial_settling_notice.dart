import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import '../models/initial_settling_state.dart';
import '../providers/initial_settling_provider.dart';

class InitialSettlingNotice extends ConsumerWidget {
  const InitialSettlingNotice({super.key, required this.deviceId});
  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(bleDeviceProvider(deviceId));
    if (device.deviceModel != DeviceModel.airspotSlim ||
        !InitialSettlingState.supported(device.firmwareVersion) ||
        ref.watch(bleDeviceConnectionProvider(deviceId)) !=
            BluetoothBondState.bonded) {
      return const SizedBox.shrink();
    }
    final status = ref.watch(initialSettlingProvider(deviceId)).asData?.value;
    if (status == null || !status.active) return const SizedBox.shrink();
    return InitialSettlingBanner(remainingSeconds: status.remainingSeconds);
  }
}

class InitialSettlingBanner extends StatelessWidget {
  const InitialSettlingBanner({super.key, required this.remainingSeconds});
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds / 60).ceil();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.hourglass_top_rounded,
              color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sensor settling',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                  'About $minutes min remaining. The white blink every 10 seconds is normal. Keep Slim powered on while readings settle.',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          )),
        ],
      ),
    );
  }
}
