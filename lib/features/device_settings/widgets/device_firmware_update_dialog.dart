import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/models/remote_version.dart';
import 'package:airspothealth/features/device_settings/providers/dfu_update_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/download_device_data_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceFirmwareUpdateDialog extends ConsumerStatefulWidget {
  const DeviceFirmwareUpdateDialog({
    required this.deviceId,
    required this.remoteVersion,
    super.key,
  }) : localFilePath = null;

  const DeviceFirmwareUpdateDialog.local({
    required this.deviceId,
    required this.localFilePath,
    super.key,
  }) : remoteVersion = null;

  final String deviceId;

  final RemoteVersion? remoteVersion;

  final String? localFilePath;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeviceFirmwareUpdateDialogState();
}

class _DeviceFirmwareUpdateDialogState
    extends ConsumerState<DeviceFirmwareUpdateDialog> {
  String get deviceId => widget.deviceId;

  RemoteVersion? get remoteVersion => widget.remoteVersion;

  String? get localFilePath => widget.localFilePath;

  @override
  void initState() {
    super.initState();

    _checkIfLocalUpdate();
  }

  void _checkIfLocalUpdate() {
    if (remoteVersion == null && localFilePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(dfuUpdateProvider.notifier).updateFirmware(
              deviceId: deviceId,
              url: localFilePath!,
              isLocal: true,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(dfuUpdateProvider, (oldState, newState) {
      if (newState is AsyncFailure && newState != oldState) {
        context.showSnackBar('Failed to update firmware, ${newState.error}');
        return;
      }

      if (newState is AsyncSuccess) {
        context.showSnackBar('Firmware updated successfully');

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
                if (updateState is AsyncInProgress) {
                  context.showSnackBar('Firmware update in progress...');
                  return;
                }

                Navigator.of(context).pop();
              },
            ),
          ),
          const AppLogo(),
          const SizedBox(height: 8),
          Text(
            'Airspot device firmware update',
            style: context.textTheme.bodyLarge?.weight700,
            textAlign: TextAlign.center,
          ),
          if (remoteVersion != null) ...[
            Text(
              remoteVersion!.changeLog ?? 'No change log available',
              style: context.textTheme.bodySmall?.copyWith(
                letterSpacing: 0.5,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 16)
          ],
          if (remoteVersion?.requireErase == true) ...[
            Text(
              'Warning: This device update will erase the CO2 history stored on the device. If you want to keep it, download it first. It will be saved as a .csv (spreadsheet).',
              style: context.textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 16),
            DownloadDeviceDataButton(deviceId: deviceId)
          ],
          const SizedBox(height: 16),
          if (updateState is AsyncInProgress) ...[
            LinearProgressIndicator(
              value: updateState.progress,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            if (updateState.message != null)
              Text(updateState.message!, style: context.textTheme.bodySmall),
          ] else if (remoteVersion != null &&
              (updateState is AsyncNone || updateState is AsyncFailure))
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => ref
                  .read(dfuUpdateProvider.notifier)
                  .updateFirmware(
                      url: remoteVersion!.downloadUrl, deviceId: deviceId),
              child: Text(
                'Update Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (updateState is AsyncFailure)
            Flexible(
              child: Text(
                updateState.error.toString(),
                style: context.textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
