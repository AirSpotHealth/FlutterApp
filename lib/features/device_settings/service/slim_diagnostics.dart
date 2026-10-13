import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:airspothealth/core/models/ble_device.dart';

/// Read-only Slim journal protocol (0x37). No cached sensor data is substituted.
class SlimDiagnostics {
  static const command = 0x37;
  static const names = {
    1: 'boot',
    2: 'watchdog',
    3: 'startup_failed',
    4: 'trial_boot',
    5: 'image_confirmed',
    6: 'rollback_requested',
    7: 'sensor_failed',
    8: 'ota_rejected',
    9: 'storage_failed',
    10: 'i2c_failed',
    11: 'sample_failed',
    12: 'co2_context',
    13: 'recovery_result',
    14: 'factory_reset_failed',
    15: 'sensor_power',
  };

  static Map<String, Object> decodeDetail(int code, int detail) {
    final low = detail & 65535;
    final error = low >= 32768 ? low - 65536 : low;
    final stage = (detail >> 16) & 255;
    final fault = (detail >> 24) & 255;
    switch (code) {
      case 10:
        return {
          'address': '0x${fault.toRadixString(16).padLeft(2, '0')}',
          'operation':
              {1: 'write', 2: 'read', 3: 'write_read'}[stage] ?? 'unknown',
          'errno': error
        };
      case 11:
        return {
          'sensorFault': fault,
          'stage': stage == 1 ? 'compensation' : 'co2_sample',
          'errno': error
        };
      case 12:
        return {'sensorStatus': detail >> 16, 'rawCo2Ppm': error};
      case 13:
        return {
          'sensorFault': fault,
          'stage': stage == 2 ? 'recovered' : 'failed',
          'errno': error
        };
      case 14:
        return {
          'stage': {
                1: 'sensor_erase',
                2: 'readings_erase',
                3: 'settings_reset'
              }[stage] ??
              'unknown',
          'errno': error
        };
      case 15:
        return {
          'batteryMillivolts': detail >> 16,
          'charging': (low & 1) != 0,
          'rawCo2Available': (low & 2) != 0,
          'singleShot': (low & 4) != 0
        };
      default:
        return {};
    }
  }

  static int crc32(List<int> bytes) {
    var crc = 0xffffffff;
    for (final byte in bytes) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        crc = (crc >>> 1) ^ ((crc & 1) != 0 ? 0xedb88320 : 0);
      }
    }
    return (crc ^ 0xffffffff) & 0xffffffff;
  }

  static List<int> request(int index, int head) {
    final data = ByteData(5)..setUint8(0, index);
    data.setUint32(1, head);
    final frame = [0xff, 0xaa, command, 5, ...data.buffer.asUint8List()];
    return [...frame, frame.fold<int>(0, (a, b) => a + b) & 0xff];
  }

  static ByteData parseFrame(List<int> frame) {
    if (frame.length < 13 ||
        frame[0] != 0xff ||
        frame[1] != 0xaa ||
        frame[2] != command ||
        frame.length != frame[3] + 5 ||
        (frame.take(frame.length - 1).fold<int>(0, (a, b) => a + b) & 0xff) !=
            frame.last) {
      throw const FormatException('Invalid diagnostic response');
    }
    final payload = Uint8List.fromList(frame.sublist(4, frame.length - 1));
    if (payload[0] != 1 ||
        payload[3] > 16 ||
        payload[1] > 4 ||
        payload.length != (payload[1] == 0 ? 36 : 8)) {
      throw const FormatException('Unsupported diagnostic response');
    }
    return ByteData.sublistView(payload);
  }

  static Map<String, Object> parseRecord(ByteData payload) {
    final record = payload.buffer.asUint8List(payload.offsetInBytes + 8, 28);
    final data = ByteData.sublistView(record);
    if (record[0] != 1 ||
        !names.containsKey(record[1]) ||
        crc32(record.sublist(0, 24)) != data.getUint32(24) ||
        data.getUint32(8) != payload.getUint32(4) - payload.getUint8(2)) {
      throw const FormatException('Diagnostic record failed integrity checks');
    }
    return {
      'event': names[record[1]]!,
      'code': record[1],
      'firmware': '${record[2]}.${record[3]}.${data.getUint16(4)}',
      'sequence': data.getUint32(8),
      'uptimeSeconds': data.getUint32(12),
      'detail': data.getUint32(16),
      if (record[1] >= 10)
        'decoded': decodeDetail(record[1], data.getUint32(16)),
      'resetCause': data.getUint32(20),
    };
  }

  static Future<String> collect({
    required BleDevice device,
    required bool connectedAtCollectionStart,
    required Stream<List<int>> responses,
    required Future<bool> Function(List<int>) send,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final collectionStartedAt = DateTime.now().toUtc().toIso8601String();
    // Saved identity is app metadata, not a fresh firmware/version query.
    final deviceDetails = {
      'deviceId': device.deviceId,
      'name': device.name,
      'alias': device.alias,
      'address': device.address,
      'model': device.deviceModel?.name,
      'platform': device.platform,
      'savedFirmwareVersion':
          device.firmwareVersion == '-.-.-' || device.firmwareVersion.isEmpty
              ? null
              : device.firmwareVersion,
    };
    final records = <Map<String, Object>>[];
    final missing = <int>[];
    var head = 0;
    var count = 16;
    for (var index = 0; index < count; index++) {
      final result = Completer<List<int>>();
      final subscription = responses.listen((frame) {
        if (frame.length > 2 && frame[2] == command && !result.isCompleted) {
          result.complete(frame);
        }
      }, onError: (Object error) {
        if (!result.isCompleted) result.completeError(error);
      }, onDone: () {
        if (!result.isCompleted) {
          result.completeError(StateError('Device disconnected'));
        }
      });
      final reply = result.future.timeout(timeout);
      unawaited(reply.catchError((Object error) => <int>[]));
      try {
        if (!await send(request(index, head)).timeout(timeout)) {
          throw StateError('Connect to Slim before exporting diagnostics');
        }
        final payload = parseFrame(await reply);
        if (payload.getUint8(2) != index) {
          throw const FormatException('Unexpected diagnostic page');
        }
        final status = payload.getUint8(1);
        if (status == 2) {
          throw StateError(
              'Diagnostics are still starting. Try again shortly.');
        }
        if (status == 3 || (index > 0 && payload.getUint32(4) != head)) {
          throw StateError('New events arrived during export. Please retry.');
        }
        if (index == 0) {
          head = payload.getUint32(4);
          count = payload.getUint8(3);
        }
        if (status == 1 && index == 0 && count == 0) break;
        if (status == 4) {
          missing.add(head - index);
          continue;
        }
        if (status != 0) {
          throw const FormatException('Incomplete diagnostic journal');
        }
        records.add(parseRecord(payload));
      } on TimeoutException {
        throw StateError(
            'No diagnostic response. Check the connection; older firmware may not support export.');
      } finally {
        await subscription.cancel();
      }
    }
    return const JsonEncoder.withIndent('  ').convert({
      'schema': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'device': deviceDetails,
      'collection': {
        'source': 'bluetooth',
        'startedAt': collectionStartedAt,
        'connectedAtStart': connectedAtCollectionStart,
      },
      'events': records,
      'unreadableSequences': missing,
    });
  }
}
