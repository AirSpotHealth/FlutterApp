import 'package:airspothealth/core/providers/services_status_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServicesBanner extends ConsumerWidget {
  const ServicesBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesStatus = ref.watch(servicesStatusProvider);

    final bluetoothEnabled = servicesStatus[Service.bluetoothService];
    // servicesStatus[Service.locationService];

    if (bluetoothEnabled == true) {
      return const SizedBox.shrink();
    }

    final String message = t.bluetoothIsDisabled;

    final String bluetoothEnableInfo = t.bluetoothEnableInfo;

    return Material(
      elevation: 10,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              t.pleaseEnableBluetoothService,
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.bluetooth, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bluetoothEnableInfo,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
