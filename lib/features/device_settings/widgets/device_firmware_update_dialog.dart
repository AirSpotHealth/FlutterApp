import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/device_settings/service/firmware_update_error.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/core/widgets/warning_text.dart';
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
    required this.currentVersion,
    super.key,
  }) : localFilePath = null;

  const DeviceFirmwareUpdateDialog.local({
    required this.deviceId,
    required this.localFilePath,
    required this.currentVersion,
    super.key,
  }) : remoteVersion = null;

  final String deviceId;

  final RemoteVersion? remoteVersion;

  final String? currentVersion;

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
        return;
      }

      if (newState is AsyncSuccess) {
        context.showSnackBar(newState.data is String
            ? newState.data as String
            : 'Firmware updated successfully');

        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    });

    final AsyncProgressValue updateState = ref.watch(dfuUpdateProvider);

    final failure = updateState is AsyncFailure
        ? firmwareUpdateError(updateState.error)
        : null;
    return AlertDialog.adaptive(
      scrollable: true,
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close update',
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
          if (widget.currentVersion == null) ...[
            const SizedBox(height: 12),
            WarningText(text: 'Failed to read installed firmware version.'),
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
          ] else ...[
            if (updateState is AsyncFailure) ...[
              FirmwareUpdateFailureNotice(error: updateState.error),
              const SizedBox(height: 16),
            ],
            if (failure?.retryable == false)
              Button(
                  label: 'Close',
                  type: ButtonType.outlined,
                  onPressed: () => Navigator.of(context).pop())
            else if ((remoteVersion != null || localFilePath != null) &&
                (updateState is AsyncNone || updateState is AsyncFailure))
              Button(
                label:
                    updateState is AsyncFailure ? 'Try again' : 'Start update',
                onPressed: () =>
                    ref.read(dfuUpdateProvider.notifier).updateFirmware(
                          url: remoteVersion?.downloadUrl ?? localFilePath!,
                          deviceId: deviceId,
                          isLocal: remoteVersion == null,
                          release: remoteVersion,
                        ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Actionable update failure text; low-level details stay in the error cause.
class FirmwareUpdateFailureNotice extends StatelessWidget {
  const FirmwareUpdateFailureNotice({required this.error, super.key});
  final Object error;
  @override
  Widget build(BuildContext context) {
    final failure = firmwareUpdateError(error);
    return Semantics(
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(failure.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(failure.message,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ));
  }
}
