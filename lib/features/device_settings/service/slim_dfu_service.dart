import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// MCUmgr SMP firmware upload for AirSpot Slim (nRF54L05 / Zephyr / NCS).
///
/// Accepts either a raw `.bin` (MCUboot-signed slot-1 image) or a `.zip`
/// containing exactly one `.bin`. The upload uses the SMP over BLE transport
/// that the Slim device exposes via the MCUmgr service UUID.
class SlimDfuService {
  // SMP protocol constants
  static const int _opWriteRequest = 2;
  static const int _groupImage = 1;
  static const int _groupOs = 0;
  static const int _cmdImageUpload = 1;
  static const int _cmdImageState = 0;
  static const int _cmdOsReset = 5;

  static const int _chunkSize = 128;

  /// Upload firmware to the Slim device.
  ///
  /// [filePath] may be a `.bin` or `.zip` (auto-extracted).
  static Future<void> uploadFromFile({
    required String deviceId,
    required String filePath,
    required void Function(double) onProgress,
    required void Function(String) onStatus,
  }) async {
    final firmware = await _loadFirmware(filePath, onStatus);
    await upload(
      deviceId: deviceId,
      firmware: firmware,
      onProgress: onProgress,
      onStatus: onStatus,
    );
  }

  /// Upload raw firmware bytes via MCUmgr SMP.
  static Future<void> upload({
    required String deviceId,
    required Uint8List firmware,
    required void Function(double) onProgress,
    required void Function(String) onStatus,
  }) async {
    final device = BluetoothDevice.fromId(deviceId);

    onStatus('Discovering SMP service...');
    final services = await device.discoverServices();

    final smpService = services.firstWhereOrNull(
      (s) => s.uuid.toString().toUpperCase() == Constants.smpServiceUuid,
    );
    if (smpService == null) throw Exception('SMP service not found on device');

    final smpChar = smpService.characteristics.firstWhereOrNull(
      (c) => c.uuid.toString().toUpperCase() == Constants.smpCharacteristicUuid,
    );
    if (smpChar == null) throw Exception('SMP characteristic not found');

    await smpChar.setNotifyValue(true);
    debugPrint('SlimDfu: starting upload of ${firmware.length} bytes');

    final sha = Uint8List.fromList(sha256.convert(firmware).bytes);
    int offset = 0;
    int seq = 0;

    onStatus('Uploading firmware...');

    while (offset < firmware.length) {
      final end = (offset + _chunkSize).clamp(0, firmware.length);
      final chunk = firmware.sublist(offset, end);

      final payload = _buildUploadPayload(
        offset: offset,
        chunk: chunk,
        totalLength: offset == 0 ? firmware.length : null,
        sha: offset == 0 ? sha : null,
      );
      final frame = _buildSmpFrame(
        op: _opWriteRequest,
        group: _groupImage,
        seq: seq,
        id: _cmdImageUpload,
        payload: payload,
      );

      final completer = Completer<Map<String, dynamic>>();
      final sub =
          smpChar.lastValueStream.where((d) => d.length >= 8).listen((data) {
        if (!completer.isCompleted) {
          completer.complete(_parseSmpResponse(data));
        }
      });

      try {
        await smpChar.write(frame, withoutResponse: false);
        final response =
            await completer.future.timeout(const Duration(seconds: 15));

        final rc = (response['rc'] as int?) ?? 0;
        if (rc != 0) {
          throw Exception('SMP upload error: rc=$rc at offset=$offset');
        }
        offset = (response['off'] as int?) ?? end;
      } finally {
        await sub.cancel();
      }

      seq = (seq + 1) & 0xFF;
      onProgress(offset / firmware.length);
      debugPrint('SlimDfu: offset=$offset / ${firmware.length}');
    }

    onStatus('Confirming image...');
    await _confirmImage(smpChar, seq);

    onStatus('Rebooting device...');
    await _osReset(smpChar, (seq + 1) & 0xFF);
  }

  // ── Firmware loading ───────────────────────────────────────────────────────

  static Future<Uint8List> _loadFirmware(
      String filePath, void Function(String) onStatus) async {
    if (filePath.endsWith('.bin')) {
      onStatus('Reading firmware binary...');
      return await File(filePath).readAsBytes();
    }

    // Assume .zip — extract first .bin entry
    onStatus('Extracting firmware from package...');
    final archive =
        ZipDecoder().decodeBytes(await File(filePath).readAsBytes());
    for (final file in archive) {
      if (file.isFile && file.name.endsWith('.bin')) {
        debugPrint('SlimDfu: extracted ${file.name} (${file.size} bytes)');
        return Uint8List.fromList(file.content as List<int>);
      }
    }
    throw Exception('No .bin file found inside DFU package zip');
  }

  // ── SMP helpers ────────────────────────────────────────────────────────────

  static Uint8List _buildSmpFrame({
    required int op,
    required int group,
    required int seq,
    required int id,
    required Uint8List payload,
  }) {
    final header = ByteData(8);
    header.setUint8(0, op);
    header.setUint8(1, 0); // flags
    header.setUint16(2, payload.length, Endian.big);
    header.setUint16(4, group, Endian.big);
    header.setUint8(6, seq);
    header.setUint8(7, id);
    return Uint8List.fromList([...header.buffer.asUint8List(), ...payload]);
  }

  static Uint8List _buildUploadPayload({
    required int offset,
    required Uint8List chunk,
    int? totalLength,
    Uint8List? sha,
  }) {
    final parts = <Uint8List>[];

    // Map header: 2 keys always ("data", "off"), +2 on first packet ("len", "sha")
    final count = (totalLength != null) ? 4 : 2;
    parts.add(_cborMapHeader(count));
    parts.add(_cborString('data'));
    parts.add(_cborBytes(chunk));
    parts.add(_cborString('off'));
    parts.add(_cborInt(offset));
    if (totalLength != null && sha != null) {
      parts.add(_cborString('len'));
      parts.add(_cborInt(totalLength));
      parts.add(_cborString('sha'));
      parts.add(_cborBytes(sha));
    }

    final builder = BytesBuilder();
    for (final p in parts) {
      builder.add(p);
    }
    return builder.toBytes();
  }

  static Future<void> _confirmImage(
      BluetoothCharacteristic char, int seq) async {
    // Write {"confirm": true} to image state command
    final payload = Uint8List.fromList([
      0xA1, // map(1)
      0x67, 0x63, 0x6F, 0x6E, 0x66, 0x69, 0x72, 0x6D, // "confirm"
      0xF5, // true
    ]);
    final frame = _buildSmpFrame(
      op: _opWriteRequest,
      group: _groupImage,
      seq: seq,
      id: _cmdImageState,
      payload: payload,
    );
    await char.write(frame, withoutResponse: false);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  static Future<void> _osReset(BluetoothCharacteristic char, int seq) async {
    // Send OS reset: group=0, id=5, empty map payload
    final frame = _buildSmpFrame(
      op: _opWriteRequest,
      group: _groupOs,
      seq: seq,
      id: _cmdOsReset,
      payload: Uint8List.fromList([0xA0]), // empty CBOR map
    );
    await char.write(frame, withoutResponse: false);
  }

  // ── CBOR response parser ───────────────────────────────────────────────────

  static Map<String, dynamic> _parseSmpResponse(List<int> raw) {
    if (raw.length <= 8) return {};
    return _decodeCborMap(Uint8List.fromList(raw.sublist(8)));
  }

  static Map<String, dynamic> _decodeCborMap(Uint8List data) {
    final result = <String, dynamic>{};
    if (data.isEmpty) return result;
    int i = 0;

    final mapByte = data[i++];
    if ((mapByte & 0xE0) != 0xA0) return result;
    final mapCount = mapByte & 0x1F;

    for (int k = 0; k < mapCount && i < data.length; k++) {
      // Key (text string)
      final keyByte = data[i++];
      if ((keyByte >> 5) != 3) break; // not a text string
      final keyLen = keyByte & 0x1F;
      if (i + keyLen > data.length) break;
      final key = utf8.decode(data.sublist(i, i + keyLen));
      i += keyLen;
      if (i >= data.length) break;

      // Value
      final valByte = data[i++];
      final major = (valByte >> 5) & 0x7;
      final addl = valByte & 0x1F;

      if (major == 0) {
        // Unsigned integer
        if (addl <= 23) {
          result[key] = addl;
        } else if (addl == 24 && i < data.length) {
          result[key] = data[i++];
        } else if (addl == 25 && i + 1 < data.length) {
          result[key] = (data[i] << 8) | data[i + 1];
          i += 2;
        } else if (addl == 26 && i + 3 < data.length) {
          result[key] = (data[i] << 24) |
              (data[i + 1] << 16) |
              (data[i + 2] << 8) |
              data[i + 3];
          i += 4;
        }
      } else if (major == 2) {
        // Byte string
        int len;
        if (addl <= 23) {
          len = addl;
        } else if (addl == 24 && i < data.length) {
          len = data[i++];
        } else {
          break;
        }
        if (i + len > data.length) break;
        result[key] = Uint8List.fromList(data.sublist(i, i + len));
        i += len;
      }
    }
    return result;
  }

  // ── Minimal CBOR encoder ───────────────────────────────────────────────────

  static Uint8List _cborMapHeader(int count) {
    assert(count <= 23);
    return Uint8List.fromList([0xA0 + count]);
  }

  static Uint8List _cborString(String s) {
    final bytes = utf8.encode(s);
    assert(bytes.length <= 23, 'CBOR string too long: $s');
    return Uint8List.fromList([0x60 + bytes.length, ...bytes]);
  }

  static Uint8List _cborInt(int value) {
    assert(value >= 0);
    if (value <= 23) return Uint8List.fromList([value]);
    if (value <= 0xFF) return Uint8List.fromList([0x18, value]);
    if (value <= 0xFFFF) {
      return Uint8List.fromList([0x19, (value >> 8) & 0xFF, value & 0xFF]);
    }
    return Uint8List.fromList([
      0x1A,
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ]);
  }

  static Uint8List _cborBytes(Uint8List data) {
    if (data.length <= 23) {
      return Uint8List.fromList([0x40 + data.length, ...data]);
    }
    if (data.length <= 0xFF) {
      return Uint8List.fromList([0x58, data.length, ...data]);
    }
    return Uint8List.fromList([
      0x59,
      (data.length >> 8) & 0xFF,
      data.length & 0xFF,
      ...data,
    ]);
  }
}
