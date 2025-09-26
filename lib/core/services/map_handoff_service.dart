import 'dart:convert';
import 'dart:io' show gzip;
import 'dart:math';
import 'dart:typed_data';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pointycastle/export.dart';

class MapHandoffService {
  MapHandoffService({IsarService? isarService})
      : _isarService = isarService ?? IsarService();

  final IsarService _isarService;

  static const String _kid =
      String.fromEnvironment('MAP_HMAC_KID', defaultValue: '');
  static const String _secretB64 =
      String.fromEnvironment('MAP_HMAC_KEY', defaultValue: '');

  Future<Uri> buildSignedMapUrl({
    required String deviceId,
    int recordLimit = 500,
    bool useFragment = true,
    int? tsMs,
    int? selectedCo2,
  }) async {
    // Validate environment variables
    if (_secretB64.isEmpty) {
      throw Exception(
          'MAP_HMAC_KEY environment variable is required for map handoff');
    }
    if (_kid.isEmpty) {
      throw Exception(
          'MAP_HMAC_KID environment variable is required for map handoff');
    }

    final bleName = _readBleName(deviceId);
    final canonicalId = bleName?.isNotEmpty == true ? bleName! : deviceId;
    final records =
        await _fetchLastCo2Records(deviceId: deviceId, limit: recordLimit);
    final fallbackCo2 = records.isNotEmpty ? records.last['co2'] as int : 0;
    final co2ToSend = selectedCo2 ?? fallbackCo2;

    final secret = _base64UrlDecode(_secretB64);

    // 1. Encrypt device ID using AES-256-GCM
    final encryptedDeviceId = _encryptAES256GCM(canonicalId, secret);

    // 2. Encrypt CO2 value using AES-256-GCM. If a specific selection is provided,
    //    that value is used; otherwise we default to the most recent value.
    final encryptedCo2 = _encryptAES256GCM(co2ToSend.toString(), secret);

    // 3. Compress records
    final recordsJson = json.encode(records);
    final recordsBytes = utf8.encode(recordsJson);
    final compressedRecords = gzip.encode(recordsBytes);
    final encodedRecords = _base64UrlEncode(compressedRecords);

    final params = {
      'kid': _kid,
      'deviceId': encryptedDeviceId,
      'co2': encryptedCo2,
      'records': encodedRecords,
    };

    // Optionally include the selected timestamp as ISO string for the point.
    if (tsMs != null) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(tsMs, isUtc: false);
      params['ts'] = _encryptAES256GCM(dateTime.toIso8601String(), secret);
    }

    debugPrint('Map handoff params: $params');
    debugPrint('tsMs passed: $tsMs');
    debugPrint('ts param present: ${params.containsKey('ts')}');
    if (params.containsKey('ts')) {
      debugPrint('ts param length: ${params['ts']?.length}');
    }

    final base = Uri.parse(Constants.mapUrl);
    if (useFragment) {
      final fragment = params.entries
          .map((e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      return base.replace(fragment: fragment);
    } else {
      return base.replace(queryParameters: params);
    }
  }

  String? _readBleName(String deviceId) {
    try {
      final device = _isarService.read<BleDevice?>(
        (isar) => isar.bleDevices.where().deviceIdEqualTo(deviceId).findFirst(),
      );
      return device?.name;
    } catch (_) {
      return null;
    }
  }

  /// Encrypts data using AES-256-GCM
  /// Returns: IV (16 bytes) + Ciphertext + AuthTag (16 bytes), then base64url encoded
  String _encryptAES256GCM(String plaintext, Uint8List key) {
    // Generate random IV (16 bytes for GCM)
    final random = Random.secure();
    final iv = Uint8List(16);
    for (int i = 0; i < iv.length; i++) {
      iv[i] = random.nextInt(256);
    }

    // Ensure key is 32 bytes for AES-256
    final aesKey = _deriveKey(key, 32);

    // Create AES-GCM cipher
    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(KeyParameter(aesKey), 128, iv, Uint8List(0));

    cipher.init(true, params);

    // Encrypt the plaintext
    final plaintextBytes = utf8.encode(plaintext);
    final ciphertext = cipher.process(plaintextBytes);

    // Extract authentication tag (last 16 bytes)
    final authTag = ciphertext.sublist(ciphertext.length - 16);
    final encryptedData = ciphertext.sublist(0, ciphertext.length - 16);

    // Format: IV (16 bytes) + Ciphertext + AuthTag (16 bytes)
    final result = Uint8List(iv.length + encryptedData.length + authTag.length);
    result.setRange(0, iv.length, iv);
    result.setRange(iv.length, iv.length + encryptedData.length, encryptedData);
    result.setRange(iv.length + encryptedData.length, result.length, authTag);

    return _base64UrlEncode(result);
  }

  /// Derives a key of specified length from the input key using SHA-256
  Uint8List _deriveKey(Uint8List inputKey, int keyLength) {
    if (inputKey.length >= keyLength) {
      return Uint8List.fromList(inputKey.take(keyLength).toList());
    }

    // If input key is shorter, derive using repeated hashing
    final digest = SHA256Digest();
    var result = Uint8List.fromList(inputKey);

    while (result.length < keyLength) {
      result = Uint8List.fromList([...result, ...digest.process(result)]);
    }

    return Uint8List.fromList(result.take(keyLength).toList());
  }

  Future<List<Map<String, dynamic>>> _fetchLastCo2Records({
    required String deviceId,
    required int limit,
  }) async {
    // Query last N CO2 records (type == co2) sorted by dateTime descending
    final co2TypeIndex = DeviceDataType.co2.index;
    final all = _isarService.read<List<DeviceData>>((isar) {
      return isar.deviceDatas
          .where()
          .deviceIdEqualTo(deviceId)
          .typeEqualTo(co2TypeIndex)
          .sortByDateTimeDesc()
          .findAll(limit: limit);
    });

    // Convert to chronological order (oldest → newest)
    final ascending = List<DeviceData>.from(all)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return ascending
        .map((e) => {
              'ts': e.dateTime.millisecondsSinceEpoch,
              'co2': e.value,
            })
        .toList();
  }

  String _base64UrlEncode(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  Uint8List _base64UrlDecode(String input) {
    if (input.isEmpty) {
      throw StateError('MAP_HMAC_KEY is not defined');
    }
    String normalized = input.replaceAll('-', '+').replaceAll('_', '/');
    switch (normalized.length % 4) {
      case 2:
        normalized += '==';
        break;
      case 3:
        normalized += '=';
        break;
    }
    return Uint8List.fromList(base64.decode(normalized));
  }

  // no nonce used in 3-minute TTL mode
}
