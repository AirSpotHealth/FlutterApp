import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/models/remote_version.dart';
import 'package:airspothealth/features/device_settings/providers/dfu_update_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceFirmwareUpdateDialog extends ConsumerWidget {
  const DeviceFirmwareUpdateDialog(
      {required this.deviceId, required this.remoteVersion, super.key});

  final String deviceId;

  final RemoteVersion remoteVersion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(dfuUpdateProvider, (oldState, newState) {
      if (newState is AsyncFailure && oldState is AsyncFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update firmware, ${newState.error}'),
          ),
        );
      }

      if (newState is AsyncSuccess) {
        context.showSnackBar('Firmware updated successfully');

        ref.read(bleDeviceConnectionProvider(deviceId).notifier).connect();

        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    });

    final AsyncProgressValue updateState = ref.watch(dfuUpdateProvider);

    return AlertDialog.adaptive(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          const AppLogo(),
          const SizedBox(height: 8),
          Text('App Version Update',
              style: context.textTheme.bodyLarge?.weight700),
          const SizedBox(height: 16),
          Text(remoteVersion.updateContent),
          const SizedBox(height: 16),
          if (updateState is AsyncInProgress) ...[
            LinearProgressIndicator(
              value: updateState.progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(Colors.green),
            ),
            const SizedBox(height: 8),
            if (updateState.message != null)
              Text(updateState.message!, style: context.textTheme.bodySmall),
          ] else if (updateState is AsyncNone || updateState is AsyncFailure)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                ref.read(dfuUpdateProvider.notifier).updateFirmware(
                    url: remoteVersion.downloadUrl, deviceId: deviceId);
              },
              child: const Text(
                'Update Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (updateState is AsyncFailure)
            Text(
              updateState.error.toString(),
              style: context.textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
