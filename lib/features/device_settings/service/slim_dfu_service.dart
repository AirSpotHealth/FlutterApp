import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:mcumgr_flutter/mcumgr_flutter.dart';
import 'package:mcumgr_flutter/models/firmware_upgrade_mode.dart';

/// MCUmgr SMP firmware upload for AirSpot Slim (nRF54L05 / Zephyr / NCS).
///
/// Accepts a raw `.bin` or an NCS DFU `.zip`. Zips are unpacked by basename in
/// priority order: `application.signed.bin` (NCS sysbuild), `app_update.bin`,
/// `zephyr.signed.bin`, `zephyr.bin`, then any `.bin`. Before upload, trailing
/// trailing 0xFF padding is trimmed to the full signed image size (header + body +
/// TLV trailer). Never use `ih_hdr_size + ih_img_size` alone — that strips the
/// signature and bricks the device after confirm/reset.
class SlimDfuService {
  static Future<void> uploadFromFile({
    required String deviceId,
    required String filePath,
    required void Function(double) onProgress,
    required void Function(String) onStatus,
  }) async {
    final bytes = await File(filePath).readAsBytes();
    final raw = filePath.toLowerCase().endsWith('.zip')
        ? _extractBin(bytes)
        : Uint8List.fromList(bytes);
    await upload(
      deviceId: deviceId,
      firmware: raw,
      onProgress: onProgress,
      onStatus: onStatus,
    );
  }

  /// MCUboot [image_header](https://github.com/mcu-tools/mcuboot/blob/main/boot/bootutil/include/bootutil/image.h) magic values (LE).
  static const int _imageMagic = 0x96f3b83d;
  static const int _imageMagicV1 = 0x96f3b83c;
  /// IMAGE_TLV_INFO_MAGIC — TLV area follows header + application body.
  static const int _imageTlvInfoMagic = 0x6907;

  static Uint8List _extractBin(Uint8List zipBytes) {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final entry = _pickFirmwareZipEntry(archive);
    if (entry == null) {
      throw Exception(
        'No .bin firmware found in DFU zip. Contents: '
        '${archive.map((f) => f.name).join(', ')}',
      );
    }
    // Use readBytes() — the archive 4.x explicit API that decompresses on demand.
    final bytes = entry.readBytes();
    if (bytes == null || bytes.isEmpty) {
      throw Exception(
        'Failed to read firmware bytes from zip entry "${entry.name}". '
        'The zip may be corrupt.',
      );
    }
    debugPrint(
      'SlimDfu: extracted "${entry.name}" (${bytes.length} bytes) from zip',
    );
    return bytes;
  }

  static ArchiveFile? _pickFirmwareZipEntry(Archive archive) {
    bool basenameIs(String zipPath, String base) {
      final idx = zipPath.lastIndexOf('/');
      final name = idx == -1 ? zipPath : zipPath.substring(idx + 1);
      return name == base;
    }

    // Priority order: NCS sysbuild name first, then legacy names.
    const preferred = [
      'application.signed.bin', // west build --sysbuild output (NCS 2.x+)
      'app_update.bin',         // older NCS / manual packaging
      'zephyr.signed.bin',      // fallback script output
      'zephyr.bin',
    ];
    for (final base in preferred) {
      for (final f in archive.files) {
        if (f.isFile && basenameIs(f.name, base) && !f.name.contains('__MACOSX')) {
          return f;
        }
      }
    }
    // Last resort: any .bin file that is not the nrfutil init-packet (.dat) or manifest.
    for (final f in archive.files) {
      if (f.isFile &&
          f.name.toLowerCase().endsWith('.bin') &&
          !f.name.contains('__MACOSX')) {
        return f;
      }
    }
    return null;
  }

  /// Returns the byte length of the signed MCUboot image (header + app + TLVs).
  static int? _mcubootSignedImageLength(Uint8List raw) {
    const minHeader = 32;
    if (raw.length < minHeader) {
      return null;
    }

    final bd = ByteData.sublistView(raw, 0, minHeader);
    final magic = bd.getUint32(0, Endian.little);
    if (magic != _imageMagic && magic != _imageMagicV1) {
      return null;
    }

    final hdrSize = bd.getUint16(8, Endian.little);
    final imgSize = bd.getUint32(12, Endian.little);
    if (hdrSize < minHeader || imgSize == 0) {
      return null;
    }

    final bodyEnd = hdrSize + imgSize;
    if (bodyEnd > raw.length) {
      return null;
    }

    var total = bodyEnd;
    if (bodyEnd + 4 <= raw.length) {
      final tlvBd = ByteData.sublistView(raw, bodyEnd, bodyEnd + 4);
      if (tlvBd.getUint16(0, Endian.little) == _imageTlvInfoMagic) {
        final tlvTot = tlvBd.getUint16(2, Endian.little);
        if (tlvTot >= 4) {
          final withTlv = bodyEnd + tlvTot;
          if (withTlv <= raw.length) {
            total = withTlv;
          }
        }
      }
    }
    return total;
  }

  /// SMP upload `len` must match the signed image, not padded file size.
  static Uint8List _normalizeMcubootImage(Uint8List raw) {
    final signedLen = _mcubootSignedImageLength(raw);
    if (signedLen == null) {
      final magic = raw.length >= 4
          ? ByteData.sublistView(raw, 0, 4).getUint32(0, Endian.little)
          : 0;
      throw Exception(
        'Invalid firmware: not a signed MCUboot image '
        '(size=${raw.length}, magic=0x${magic.toRadixString(16)}). '
        'Use application.signed.bin or app_update.bin from the NCS DFU zip.',
      );
    }

    if (signedLen > raw.length) {
      throw Exception(
        'Firmware file is truncated (need $signedLen bytes, have ${raw.length}).',
      );
    }

    if (signedLen < raw.length) {
      debugPrint(
        'SlimDfu: trimmed flash padding ${raw.length} -> $signedLen bytes',
      );
      return Uint8List.sublistView(raw, 0, signedLen);
    }
    return raw;
  }

  static Future<void> upload({
    required String deviceId,
    required Uint8List firmware,
    required void Function(double) onProgress,
    required void Function(String) onStatus,
    int maxAttempts = 3,
  }) async {
    final normalized = _normalizeMcubootImage(firmware);
    Exception? lastError;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      if (attempt > 1) {
        onStatus('Retrying... (attempt $attempt of $maxAttempts)');
        await Future.delayed(const Duration(seconds: 2));
      }
      try {
        await _attemptUpload(
          deviceId: deviceId,
          firmware: normalized,
          onProgress: onProgress,
          onStatus: onStatus,
        );
        return;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        debugPrint('SlimDfu attempt $attempt/$maxAttempts failed: $e');
      }
    }
    throw lastError!;
  }

  static Future<void> _attemptUpload({
    required String deviceId,
    required Uint8List firmware,
    required void Function(double) onProgress,
    required void Function(String) onStatus,
  }) async {
    final factory = FirmwareUpdateManagerFactory();
    final manager = await factory.getUpdateManager(deviceId);

    final completer = Completer<void>();
    final subs = <StreamSubscription>[];

    try {
      onStatus('Initialising update session...');
      manager.setup();

      subs.add(manager.progressStream.listen((progress) {
        if (progress.imageSize > 0) {
          onProgress(progress.bytesSent / progress.imageSize);
        }
      }));

      subs.add(manager.updateStateStream!.listen(
        (state) {
          debugPrint('SlimDfu state: $state');
          switch (state) {
            case FirmwareUpgradeState.upload:
              onStatus('Uploading firmware...');
            case FirmwareUpgradeState.validate:
              onStatus('Validating image...');
            case FirmwareUpgradeState.test:
              onStatus('Testing image...');
            case FirmwareUpgradeState.confirm:
              onStatus('Confirming image...');
            case FirmwareUpgradeState.reset:
              onStatus('Rebooting device...');
            case FirmwareUpgradeState.success:
              onProgress(1.0);
              onStatus('Update complete.');
              if (!completer.isCompleted) completer.complete();
            default:
              break;
          }
        },
        onError: (Object e, StackTrace st) {
          if (!completer.isCompleted) {
            completer.completeError(Exception('DFU error: $e'), st);
          }
        },
      ));

      await manager.update(
        [Image(data: firmware, image: 0)],
        configuration: const FirmwareUpgradeConfiguration(
          // testAndConfirm: MCUboot validates the image before marking it permanent.
          // confirmOnly previously bricked devices when upload omitted TLV signatures.
          firmwareUpgradeMode: FirmwareUpgradeMode.testAndConfirm,
          estimatedSwapTime: Duration(seconds: 15),
          pipelineDepth: 1,
        ),
      );

      await completer.future;
    } finally {
      for (final s in subs) {
        await s.cancel();
      }
      await manager.kill();
    }
  }
}
