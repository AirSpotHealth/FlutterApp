import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/features/device_settings/models/remote_version.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceFirmwareUpdateDialog extends ConsumerWidget {
  const DeviceFirmwareUpdateDialog(
      {required this.deviceId, required this.remoteVersion, super.key});

  final String deviceId;

  final RemoteVersion remoteVersion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Update Now',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
