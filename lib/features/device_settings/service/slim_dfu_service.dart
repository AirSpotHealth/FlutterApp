import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mcumgr_flutter/mcumgr_flutter.dart';
import 'package:mcumgr_flutter/models/firmware_upgrade_mode.dart';

import 'slim_firmware_image.dart';

/// SMP owns the BLE connection until the expected image is active and confirmed.
class SlimDfuService {
  static Future<bool> upload({
    required String deviceId,
    required SlimFirmwareImage firmware,
    required void Function(double) onProgress,
    required void Function(String) onStatus,
    UpdateManagerFactory? factory,
    Duration timeout = const Duration(minutes: 10),
    Duration confirmationTimeout = const Duration(seconds: 150),
    Duration pollInterval = const Duration(seconds: 2),
  }) async {
    final manager = await (factory ?? FirmwareUpdateManagerFactory())
        .getUpdateManager(deviceId)
        .timeout(const Duration(seconds: 30));
    final subscriptions = <StreamSubscription>[];
    var completed = false;
    var rebootRequested = false;
    Completer<void>? pendingResult;
    try {
      final states = manager.setup();
      bool matches(ImageSlot slot) =>
          slot.image == 0 &&
          slot.active &&
          slot.confirmed &&
          listEquals(slot.hash, firmware.hash);
      onStatus('Checking installed image...');
      final before =
          await manager.readImageList().timeout(const Duration(seconds: 20));
      if (before?.any(matches) == true) {
        completed = true;
        return true; // Already current: do not claim an upload occurred.
      }
      final result = Completer<void>();
      pendingResult = result;
      // Attach an error handler immediately, including errors emitted while update() starts.
      final finished = result.future.timeout(timeout);
      unawaited(finished.catchError((Object _) {}));
      subscriptions.add(manager.progressStream.listen((progress) {
        if (progress.imageSize > 0) {
          onProgress(progress.bytesSent / progress.imageSize);
        }
      }, onError: (Object error) {
        if (!result.isCompleted) result.completeError(error);
      }));
      subscriptions.add(states.listen((state) {
        switch (state) {
          case FirmwareUpgradeState.upload:
            onStatus('Uploading firmware...');
          case FirmwareUpgradeState.validate:
            onStatus('Validating image...');
          case FirmwareUpgradeState.test:
            onStatus('Preparing test boot...');
          case FirmwareUpgradeState.reset:
            rebootRequested = true;
            onStatus('Rebooting; waiting for the device to reconnect...');
          case FirmwareUpgradeState.confirm:
            onStatus('Confirming running image...');
          case FirmwareUpgradeState.success:
            if (!result.isCompleted) result.complete();
          default:
            break;
        }
      }, onError: (Object error) {
        if (!result.isCompleted) result.completeError(error);
      }, onDone: () {
        if (!result.isCompleted) {
          result.completeError(
              StateError('Firmware update ended before completion'));
        }
      }));
      await manager.update(
        [Image(data: firmware.bytes, image: 0)],
        configuration: const FirmwareUpgradeConfiguration(
          firmwareUpgradeMode: FirmwareUpgradeMode.testOnly,
          // Slim confirms itself after startup and a healthy sensor sample.
          // Reconnect immediately; the bounded poll below waits for confirmation.
          estimatedSwapTime: Duration.zero,
          eraseAppSettings: false,
          pipelineDepth: 1,
        ),
      ).timeout(timeout);
      try {
        await finished;
      } catch (_) {
        // A native reconnect can time out while Slim is still starting.
        // Only after reset may read-only verification recover the update;
        // upload/validation errors must still fail immediately.
        if (!rebootRequested) rethrow;
      }
      onStatus('Waiting for startup checks and firmware confirmation...');
      final deadline = DateTime.now().add(confirmationTimeout);
      do {
        try {
          final slots = await manager
              .readImageList()
              .timeout(const Duration(seconds: 20));
          if (slots?.any(matches) == true) {
            completed = true;
            return false;
          }
        } catch (error) {
          // BLE may disappear during image swap, startup, or rollback.
          // A failed read is never proof of success.
          debugPrint("Slim post-reboot image check: $error");
        }
        await Future<void>.delayed(pollInterval);
      } while (DateTime.now().isBefore(deadline));
      throw StateError('Target firmware is not active and confirmed; '
          'the device may have rolled back');
    } finally {
      if (pendingResult != null && !pendingResult.isCompleted) {
        pendingResult.complete();
      }
      if (!completed) {
        try {
          await manager.cancel().timeout(const Duration(seconds: 5));
        } catch (_) {
          // Preserve the original error while still releasing the native manager.
        }
      }
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      try {
        await manager.kill().timeout(const Duration(seconds: 5));
      } catch (error) {
        debugPrint('SlimDfu cleanup: $error');
      }
    }
  }
}
