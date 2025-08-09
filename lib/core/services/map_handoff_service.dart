import 'dart:convert';
import 'dart:io' show gzip;
import 'dart:typed_data';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:isar/isar.dart';

class MapHandoffService {
  MapHandoffService({IsarService? isarService})
      : _isarService = isarService ?? IsarService();

  final IsarService _isarService;

  static const String _kid = String.fromEnvironment('MAP_HMAC_KID');
  static const String _secretB64 = String.fromEnvironment('MAP_HMAC_KEY');

  Future<Uri> buildSignedMapUrl({
    required String deviceId,
    int recordLimit = 500,
    bool useFragment = true,
  }) async {
    final bleName = _readBleName(deviceId);
    final canonicalId = bleName?.isNotEmpty == true ? bleName! : deviceId;
    final records =
        await _fetchLastCo2Records(deviceId: deviceId, limit: recordLimit);

    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final payload = {
      'v': 1,
      'deviceId': deviceId, // platform-local id
      'canonicalId': canonicalId, // cross-platform id (BLE name or fallback)
      'co2': records.isNotEmpty ? records.last['co2'] : 0,
      'records': records,
      'iat': nowSec,
      'exp': nowSec + 180,
    };

    final jsonBytes = utf8.encode(json.encode(payload));
    final compressed = gzip.encode(jsonBytes);

    final secret = _base64UrlDecode(_secretB64);
    final hmac = crypto.Hmac(crypto.sha256, secret);
    final sigBytes = hmac.convert(compressed).bytes;

    final params = {
      'v': '1',
      'kid': _kid,
      'alg': 'HS256',
      'enc': 'gzip',
      'iat': nowSec.toString(),
      'exp': (nowSec + 180).toString(),
      'payload': _base64UrlEncode(compressed),
      'sig': _base64UrlEncode(sigBytes),
    };

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
