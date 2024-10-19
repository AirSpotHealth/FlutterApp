import 'dart:io';

import 'package:airspothealth/core/services/network_service.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordic_dfu/nordic_dfu.dart';
import 'package:path_provider/path_provider.dart';

final dfuUpdateProvider =
    NotifierProvider<_DfuUpdateNotifier, AsyncProgressValue>(
        _DfuUpdateNotifier.new);

class _DfuUpdateNotifier extends Notifier<AsyncProgressValue> {
  @override
  AsyncProgressValue build() {
    return const AsyncNone();
  }

  void updateFirmware({
    required String url,
    required String deviceId,
  }) async {
    try {
      state = const AsyncInProgress(0.0, message: 'Downloading firmware...');

      final Directory path = await getApplicationDocumentsDirectory();

      final String filePath =
          "${path.path}/${DateTime.now().millisecondsSinceEpoch}.zip";

      await NetworkService.instance.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          final progress = received / total;
          state = AsyncInProgress(progress, message: 'Downloading firmware...');
        },
      );

      state = const AsyncInProgress(0.0, message: 'Updating firmware...');

      await NordicDfu().startDfu(
        deviceId,
        filePath,
        onProgressChanged:
            (address, percent, speed, avgSpeed, currentPart, totalParts) {
          state =
              AsyncInProgress(percent / 100, message: 'Updating firmware...');
        },
        iosSpecialParameter: const IosSpecialParameter(
          connectionTimeout: 30,
          forceScanningForNewAddressInLegacyDfu: true,
          alternativeAdvertisingNameEnabled: true,
        ),
        onDeviceDisconnected: (error) {
          state = AsyncFailure('Device disconnected, update failed $error');
        },
        onDfuAborted: (error) {
          state = AsyncFailure('DFU aborted, update failed $error');
        },
        onDfuCompleted: (res) {
          state = const AsyncSuccess(null);
        },
        onFirmwareValidating: (address) {
          state = const AsyncInProgress(1.0, message: 'Validating firmware...');
        },
        onDfuProcessStarting: (address) {
          state =
              const AsyncInProgress(0.0, message: 'Starting DFU process...');
        },
        onDfuProcessStarted: (address) {
          state = const AsyncInProgress(0.0, message: 'DFU process started...');
        },
        onError: (address, error, errorType, message) {
          state = AsyncFailure('Update failed: $error');
        },
      );
    } catch (e) {
      state = AsyncFailure("Update failed: $e");
    }
  }
}
