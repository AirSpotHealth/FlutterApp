import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/app_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/models/remote_version.dart';
import 'package:airspothealth/features/device_settings/providers/ble_device_version_provider.dart';
import 'package:airspothealth/features/device_settings/providers/firmware_remote_version_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/device_firmware_update_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceVersionUpdateWidget extends ConsumerStatefulWidget {
  const DeviceVersionUpdateWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeviceVersionUpdateWidgetState();
}

class _DeviceVersionUpdateWidgetState
    extends ConsumerState<DeviceVersionUpdateWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(firmwareRemoteVersionProvider.notifier).fetchRemoteVersion();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(firmwareRemoteVersionProvider, (oldState, newState) {
      if (newState is AsyncError) {
        context
            .showSnackBar('Failed to fetch remote version, ${newState.error}');
      }
    });

    final AsyncValue<RemoteVersion?> remoteVersion =
        ref.watch(firmwareRemoteVersionProvider);

    final String currentVersion =
        ref.read(bleDeviceVersionProvider(widget.deviceId));

    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Text('Latest Version: '),
            const Spacer(),
            remoteVersion.when(
              data: (version) => Text(
                remoteVersion.value?.versionId ?? 'N/A',
                style: const TextStyle(
                  color: AppColors.brandColorAmber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              loading: () => const CupertinoActivityIndicator(),
              error: (error, stackTrace) => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref
                    .read(firmwareRemoteVersionProvider.notifier)
                    .fetchRemoteVersion(),
              ),
            ),
            if (remoteVersion is AsyncData &&
                remoteVersion.value != null &&
                AppUtils.isVersionGreater(
                    currentVersion, remoteVersion.value!.versionId)) ...[
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  _showUpdateDialog(context, remoteVersion.value!);
                },
                child: const Text('Update'),
              ),
            ]
          ],
        ));
  }

  void _showUpdateDialog(BuildContext context, RemoteVersion remoteVersion) {
    showAdaptiveDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeviceFirmwareUpdateDialog(
          deviceId: widget.deviceId, remoteVersion: remoteVersion),
    );
  }
}
