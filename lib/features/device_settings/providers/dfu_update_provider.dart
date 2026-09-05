import 'dart:io';

import 'package:airspothealth/features/device_settings/models/remote_version.dart';
import 'package:airspothealth/features/device_settings/service/hosted_firmware.dart';

import 'package:airspothealth/core/services/ble_communicator_service.dart';
import 'package:airspothealth/features/device_settings/service/slim_dfu_service.dart';
import 'package:airspothealth/features/device_settings/service/slim_firmware_image.dart';
import 'package:airspothealth/features/device_settings/service/slim_update_verification.dart';
import 'package:airspothealth/features/device_settings/service/slim_update_session.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/services/network_service.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
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

  Future<void> updateFirmware({
    required String url,
    required String deviceId,
    bool isLocal = false,
    RemoteVersion? release,
  }) async {
    if (state is AsyncInProgress) return;
    final keepAlive = ref.keepAlive();
    try {
      if (isLocal) {
        state = const AsyncInProgress(0.0, message: 'Updating firmware...');

        await _uploadDfu(deviceId, url);

        return;
      }

      if (release == null) {
        throw const FormatException('Missing firmware release metadata');
      }
      final model = ref
              .read(bleSavedDevicesProvider.notifier)
              .getDeviceById(deviceId)
              ?.deviceModel ??
          DeviceModel.unknown;
      release.validateForDevice(model);
      if (model == DeviceModel.airspotSlim) {
        state = const AsyncInProgress(0.0, message: 'Downloading firmware...');
        await HostedFirmware.updateSlim(
          release: release,
          temporaryDirectory: await getTemporaryDirectory(),
          download: HostedFirmware.downloadSlim,
          onProgress: (received, total) => state = AsyncInProgress(
            total > 0 ? (received / total).clamp(0.0, 1.0) : 0,
            message: 'Downloading firmware...',
          ),
          update: (path, image) =>
              _uploadDfu(deviceId, path, release: release, slimImage: image),
        );
        return;
      }

      state = const AsyncInProgress(0.0, message: 'Downloading firmware...');

      final Directory path = await getApplicationDocumentsDirectory();

      final String filePath =
          "${path.path}/${DateTime.now().millisecondsSinceEpoch}.zip";

      await NetworkService.instance.download(
        release.downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          final progress = total > 0 ? (received / total).clamp(0.0, 1.0) : 0.0;
          state = AsyncInProgress(progress, message: 'Downloading firmware...');
        },
      );

      state = const AsyncInProgress(0.0, message: 'Updating firmware...');

      await _uploadDfu(deviceId, filePath, release: release);
    } catch (e) {
      state = AsyncFailure("Update failed: $e");
    } finally {
      keepAlive.close();
    }
  }

  Future<void> _uploadDfu(
    String deviceId,
    String filePath, {
    RemoteVersion? release,
    SlimFirmwareImage? slimImage,
  }) async {
    final device =
        ref.read(bleSavedDevicesProvider.notifier).getDeviceById(deviceId);
    // Service discovery is authoritative even when a scan omitted its SMP UUID.
    final communicator = BleCommunicatorService.instance.communicator(deviceId);
    if (!await communicator.initialize()) {
      throw StateError('Connect to the device before updating');
    }
    var targetModel = DeviceModel.forDfu(device?.deviceModel,
        hasSmpService: communicator.isSlimDevice);
    if (release != null) {
      // Query the connected device again, rather than trusting saved identity.
      final services =
          await BluetoothDevice.fromId(deviceId).discoverServices();
      final hasSmp = services.any((service) => service.uuid == Constants.smpServiceGuid);
      HostedFirmware.checkConnectedModel(release, hasSmpService: hasSmp);
      targetModel = hasSmp ? DeviceModel.airspotSlim : DeviceModel.airspotScreen;
    }
    if (targetModel == DeviceModel.airspotSlim) {
      ref
          .read(bleSavedDevicesProvider.notifier)
          .updateDeviceModel(deviceId, DeviceModel.airspotSlim);
      await _uploadSlimDfu(deviceId, filePath, validatedImage: slimImage);
      return;
    }
    _uploadNordicDfu(deviceId, filePath);
  }

  Future<void> _uploadSlimDfu(String deviceId, String filePath,
      {SlimFirmwareImage? validatedImage}) async {
    final file = File(filePath);
    if (await file.length() > SlimFirmwareImage.maxFileSize) {
      throw const FormatException('Firmware file is too large');
    }
    final firmware = validatedImage ??
        SlimFirmwareImage.fromFileBytes(await file.readAsBytes(), filePath);
    final communicator = BleCommunicatorService.instance.communicator(deviceId);
    final bluetoothDevice = BluetoothDevice.fromId(deviceId);
    final history =
        ref.read(deviceHistoryDataRequestProvider(deviceId).notifier);
    final alreadyCurrent = await SlimUpdateSession.run(
      suspend: () async {
        await communicator.suspend();
        history.pauseForUpdate();
        await ref
            .read(bleDeviceConnectionProvider(deviceId).notifier)
            .disconnect();
      },
      updateAndVerify: () async {
        try {
          final current = await SlimDfuService.upload(
            deviceId: deviceId,
            firmware: firmware,
            onProgress: (progress) => state = AsyncInProgress(progress,
                message: 'Uploading firmware... ${(progress * 100).round()}%'),
            onStatus: (message) => state = AsyncInProgress(
                state is AsyncInProgress
                    ? (state as AsyncInProgress).progress
                    : 0,
                message: message),
          );
          state = const AsyncInProgress(1,
              message: 'Reconnecting and checking live readings...');
          await bluetoothDevice.connect(
              license: License.nonprofit,
              autoConnect: false,
              timeout: const Duration(seconds: 30));
          await SlimUpdateVerification.verify(communicator, firmware.version);
          return current;
        } catch (error) {
          throw StateError('Slim update could not be verified: $error. '
              'If the device rejected the update for low battery, charge it and retry.');
        }
      },
      restore: () async {
        communicator.resume();
        await ref
            .read(bleDeviceConnectionProvider(deviceId).notifier)
            .restoreAfterUpdate();
      },
    );
    state = AsyncSuccess(alreadyCurrent
        ? 'Firmware already current; device verified'
        : 'Firmware updated and device verified');
  }

  void _uploadNordicDfu(String deviceId, String filePath) {
    NordicDfu().startDfu(
      deviceId,
      filePath,
      darwinParameters: const DarwinParameters(
        connectionTimeout: 30,
        alternativeAdvertisingNameEnabled: false,
      ),
      dfuEventHandler: DfuEventHandler(
        onProgressChanged:
            (address, percent, speed, avgSpeed, currentPart, totalParts) {
          state = AsyncInProgress(
            percent / 100,
            message: 'Updating firmware.... $percent%',
          );
        },
        onDeviceDisconnected: (address) {
          state = state is AsyncInProgress
              ? (state as AsyncInProgress)
                  .copyWithMessage('Device disconnected')
              : const AsyncInProgress(0.0, message: 'Device disconnected');
        },
        onDeviceConnected: (address) {
          state = state is AsyncInProgress
              ? (state as AsyncInProgress).copyWithMessage('Device connected')
              : const AsyncInProgress(0.0, message: 'Device connected');
        },
        onDeviceConnecting: (address) {
          state =
              const AsyncInProgress(0.0, message: 'Connecting to device...');
        },
        onDeviceDisconnecting: (address) {
          state = state is AsyncInProgress
              ? (state as AsyncInProgress)
                  .copyWithMessage('Disconnecting device')
              : const AsyncInProgress(0.0, message: 'Disconnecting device...');
        },
        onEnablingDfuMode: (address) {
          state = const AsyncInProgress(0.0, message: 'Enabling DFU mode...');
        },
        onDfuAborted: (address) {
          state = AsyncFailure('DFU aborted, update failed');
        },
        onDfuCompleted: (address) {
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
          state =
              const AsyncInProgress(0.0, message: 'Starting DFU process...');
        },
        onDfuProcessStarted: (address) {
          state = const AsyncInProgress(0.0, message: 'DFU process started...');
        },
        onError: (address, error, errorType, message) {
          state = AsyncFailure('Update failed: $message');
        },
      ),
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
