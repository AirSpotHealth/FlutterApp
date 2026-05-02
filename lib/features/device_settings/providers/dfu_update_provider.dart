import 'dart:io';

import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/services/network_service.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/service/slim_dfu_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nordic_dfu/nordic_dfu.dart';
import 'package:path_provider/path_provider.dart';

final dfuUpdateProvider =
    NotifierProvider.autoDispose<_DfuUpdateNotifier, AsyncProgressValue>(
        _DfuUpdateNotifier.new);

class _DfuUpdateNotifier extends AutoDisposeNotifier<AsyncProgressValue> {
  @override
  AsyncProgressValue build() {
    return const AsyncNone();
  }

  void updateFirmware({
    required String url,
    required String deviceId,
    bool isLocal = false,
  }) async {
    try {
      if (isLocal) {
        state = const AsyncInProgress(0.0, message: 'Updating firmware...');

        _uploadDfu(deviceId, url);

        return;
      }

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

      _uploadDfu(deviceId, filePath);
    } catch (e) {
      state = AsyncFailure("Update failed: $e");
    }
  }

  void _uploadDfu(String deviceId, String filePath) {
    final device =
        ref.read(bleSavedDevicesProvider.notifier).getDeviceById(deviceId);
    if (device?.deviceModel == DeviceModel.airspotSlim) {
      _uploadSlimDfu(deviceId, filePath);
      return;
    }
    _uploadNordicDfu(deviceId, filePath);
  }

  void _uploadSlimDfu(String deviceId, String filePath) {
    SlimDfuService.uploadFromFile(
      deviceId: deviceId,
      filePath: filePath,
      onProgress: (progress) {
        state = AsyncInProgress(progress, message: 'Uploading firmware... ${(progress * 100).toInt()}%');
      },
      onStatus: (status) {
        state = AsyncInProgress(
          state is AsyncInProgress ? (state as AsyncInProgress).progress : 0.0,
          message: status,
        );
      },
    ).then((_) {
      state = const AsyncInProgress(1.0, message: 'DFU completed, rebooting...');
      _disconnectDevice(deviceId);
    }).catchError((e) {
      state = AsyncFailure('Update failed: $e');
    });
  }

  void _uploadNordicDfu(String deviceId, String filePath) {
    NordicDfu().startDfu(
      deviceId,
      filePath,
      onProgressChanged:
          (address, percent, speed, avgSpeed, currentPart, totalParts) {
        state = AsyncInProgress(
          percent / 100,
          message: 'Updating firmware.... $percent%',
        );
      },
      iosSpecialParameter: const IosSpecialParameter(
        connectionTimeout: 30,
        alternativeAdvertisingNameEnabled: false,
      ),
      onDeviceDisconnected: (error) {
        state = state is AsyncInProgress
            ? (state as AsyncInProgress).copyWithMessage('Device disconnected')
            : const AsyncInProgress(0.0, message: 'Device disconnected');
      },
      onDeviceConnected: (address) {
        state = state is AsyncInProgress
            ? (state as AsyncInProgress).copyWithMessage('Device connected')
            : const AsyncInProgress(0.0, message: 'Device connected');
      },
      onDeviceConnecting: (address) {
        state = const AsyncInProgress(0.0, message: 'Connecting to device...');
      },
      onDeviceDisconnecting: (address) {
        state = state is AsyncInProgress
            ? (state as AsyncInProgress).copyWithMessage('Disconnecting device')
            : const AsyncInProgress(0.0, message: 'Disconnecting device...');
      },
      onEnablingDfuMode: (address) {
        state = const AsyncInProgress(0.0, message: 'Enabling DFU mode...');
      },
      onDfuAborted: (error) {
        state = AsyncFailure('DFU aborted, update failed $error');
      },
      onDfuCompleted: (res) {
        state = const AsyncInProgress(
          1,
          message: 'DFU completed!!, rebooting...',
        );
        _disconnectDevice(deviceId);
      },
      onFirmwareValidating: (address) {
        state = const AsyncInProgress(1.0, message: 'Validating firmware...');
      },
      onDfuProcessStarting: (address) {
        state = const AsyncInProgress(0.0, message: 'Starting DFU process...');
      },
      onDfuProcessStarted: (address) {
        state = const AsyncInProgress(0.0, message: 'DFU process started...');
      },
      onError: (address, error, errorType, message) {
        state = AsyncFailure('Update failed: $message');
      },
    );
  }

  void _disconnectDevice(String deviceId) {
    state = const AsyncInProgress(1, message: 'Reconnecting device...');

    ref.read(bleDeviceConnectionProvider(deviceId).notifier).connect();
    ref.invalidate(bleDeviceCommunicationProvider(deviceId));
    ref.read(bleSavedDevicesProvider.notifier).resetDeviceFetchTime(deviceId);
    ref.invalidate(deviceHistoryDataRequestProvider(deviceId));

    state = const AsyncSuccess(null);
  }
}
