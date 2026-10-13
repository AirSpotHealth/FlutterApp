import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/features/device_settings/service/slim_diagnostics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'slim_test_helpers.dart';

List<int> reply({int index = 0, int head = 1, int count = 1, int status = 0}) {
  final payload = Uint8List(status == 0 ? 36 : 8);
  final data = ByteData.sublistView(payload);
  payload.setRange(0, 4, [1, status, index, count]);
  data.setUint32(4, head);
  if (status == 0) {
    payload.setRange(8, 12, [1, 2, 0, 17]);
    data.setUint32(16, head - index);
    data.setUint32(20, 120);
    data.setUint32(24, 2);
    data.setUint32(28, 8);
    data.setUint32(32, SlimDiagnostics.crc32(payload.sublist(8, 32)));
  }
  return frame(0x37, payload);
}

void main() {
  test(
      'sensor evidence decodes signed errors and distinguishes bus and CRC failures',
      () {
    expect(SlimDiagnostics.decodeDetail(10, 0x6402fffb),
        {'address': '0x64', 'operation': 'read', 'errno': -5});
    expect(SlimDiagnostics.decodeDetail(11, 0x4402ffb6)['errno'], -74);
    expect(SlimDiagnostics.decodeDetail(12, 0x0084ffff),
        {'sensorStatus': 132, 'rawCo2Ppm': -1});
    expect(SlimDiagnostics.decodeDetail(13, 0x44020000)['stage'], 'recovered');
    expect(
        SlimDiagnostics.decodeDetail(14, 0x0001fffb)['stage'], 'sensor_erase');
    expect(SlimDiagnostics.decodeDetail(15, (3700 << 16) | 3), {
      'batteryMillivolts': 3700,
      'charging': true,
      'rawCo2Available': true,
      'singleShot': false
    });
  });

  final device = BleDevice(
    deviceId: 'test-peripheral-id',
    name: 'AirSpot-E368FD',
    alias: 'Slim T',
    address: 'test-peripheral-id',
    platform: 'ios',
    firmwareVersion: '0.18.5',
    deviceModelValue: DeviceModel.airspotSlim.index,
  );
  test('CRC uses IEEE vector and validates event metadata', () {
    expect(SlimDiagnostics.crc32(utf8.encode('123456789')), 0xcbf43926);
    final record =
        SlimDiagnostics.parseRecord(SlimDiagnostics.parseFrame(reply()));
    expect(record['event'], 'watchdog');
    expect(record['firmware'], '0.17.0');
    expect(record['uptimeSeconds'], 120);
  });
  test('bad transport checksum, CRC, schema and sequence fail closed', () {
    final badChecksum = reply()..last ^= 1;
    expect(
        () => SlimDiagnostics.parseFrame(badChecksum), throwsFormatException);
    final badRecord = reply().sublist(4, 40)..[16] ^= 1;
    expect(
        () => SlimDiagnostics.parseRecord(
            SlimDiagnostics.parseFrame(frame(0x37, badRecord))),
        throwsFormatException);
    expect(
        () => SlimDiagnostics.parseFrame(frame(0x37, [2, 1, 0, 0, 0, 0, 0, 0])),
        throwsFormatException);
  });
  test('export retrieves bounded snapshot and removes listeners', () async {
    final stream = StreamController<List<int>>.broadcast();
    final sent = <List<int>>[];
    final result = await SlimDiagnostics.collect(
        device: device,
        connectedAtCollectionStart: true,
        responses: stream.stream,
        send: (request) async {
          sent.add(request);
          stream.add(reply(index: request[4], head: 2, count: 2));
          return true;
        });
    expect((jsonDecode(result)['events'] as List).length, 2);
    final exported = jsonDecode(result);
    expect(exported['device'], {
      'deviceId': 'test-peripheral-id',
      'name': 'AirSpot-E368FD',
      'alias': 'Slim T',
      'address': 'test-peripheral-id',
      'model': 'airspotSlim',
      'platform': 'ios',
      'savedFirmwareVersion': '0.18.5',
    });
    expect(exported['collection']['source'], 'bluetooth');
    expect(exported['collection']['connectedAtStart'], true);
    expect(DateTime.parse(exported['collection']['startedAt']).isUtc, true);
    // Old event firmware remains distinct from the saved device version.
    expect(exported['events'][0]['firmware'], '0.17.0');
    expect(sent[1].sublist(5, 9), [0, 0, 0, 2]);
    expect(stream.hasListener, false);
    await stream.close();
  });
  test('changed snapshot never produces a misleading export', () async {
    final stream = StreamController<List<int>>.broadcast();
    await expectLater(
        SlimDiagnostics.collect(
            device: device,
            connectedAtCollectionStart: true,
            responses: stream.stream,
            send: (request) async {
              stream.add(reply(
                  index: request[4],
                  head: 2,
                  count: 2,
                  status: request[4] == 0 ? 0 : 3));
              return true;
            }),
        throwsStateError);
    expect(stream.hasListener, false);
    await stream.close();
  });
  test('old firmware timeout is bounded and cleans up subscription', () async {
    final stream = StreamController<List<int>>.broadcast();
    await expectLater(
        SlimDiagnostics.collect(
            device: device,
            connectedAtCollectionStart: true,
            responses: stream.stream,
            send: (_) async => true,
            timeout: const Duration(milliseconds: 5)),
        throwsStateError);
    expect(stream.hasListener, false);
    await stream.close();
  });
}
