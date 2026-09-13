import 'dart:io';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/history_coverage.dart';
import 'package:airspothealth/core/services/history_coverage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_plus/isar_plus.dart';

Future<void> initializeHistoryTestDatabase() async {
  await Isar.initialize(Platform.environment['ISAR_LIBRARY_PATH']);
}

HistoryCoverage interval(int start, int end, {String device = 'slim'}) =>
    HistoryCoverage(deviceId: device, startSecond: start, endSecond: end);

List<List<int>> bounds(List<HistoryCoverage> intervals) =>
    intervals.map((i) => [i.startSecond, i.endSecond]).toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Isar isar;
  late HistoryCoverageService service;

  setUpAll(initializeHistoryTestDatabase);
  setUp(() {
    directory = Directory.systemTemp.createTempSync('history-coverage-');
    isar = Isar.open(
      schemas: [BleDeviceSchema, DeviceDataSchema, HistoryCoverageSchema],
      directory: directory.path,
      inspector: false,
    );
    service = HistoryCoverageService(isar);
  });
  tearDown(() {
    isar.close();
    directory.deleteSync(recursive: true);
  });

  test('separate downloads preserve the intervening gap', () {
    service.complete(interval(100, 200));
    service.complete(interval(400, 500));
    expect(bounds(service.missing(interval(100, 500))), [
      [200, 400]
    ]);
    expect(bounds(service.missing(interval(0, 600))), [
      [0, 100],
      [200, 400],
      [500, 600]
    ]);
    expect(service.missing(interval(120, 180)), isEmpty);
  });

  test('overlap, adjacency and a bridging interval merge without losing edges',
      () {
    service.complete(interval(100, 200));
    service.complete(interval(150, 250));
    service.complete(interval(250, 300));
    service.complete(interval(400, 500));
    expect(
        bounds(isar.historyCoverages.where().sortByStartSecond().findAll()), [
      [100, 300],
      [400, 500]
    ]);
    service.complete(interval(300, 400));
    service.complete(interval(120, 180));
    expect(
        bounds(isar.historyCoverages.where().sortByStartSecond().findAll()), [
      [100, 500]
    ]);
  });

  test('coverage is isolated by device and persists across reopening', () {
    service.complete(interval(100, 200));
    expect(bounds(service.missing(interval(100, 200, device: 'other'))), [
      [100, 200]
    ]);
    isar.close();
    isar = Isar.open(
        schemas: [BleDeviceSchema, DeviceDataSchema, HistoryCoverageSchema],
        directory: directory.path,
        inspector: false);
    service = HistoryCoverageService(isar);
    expect(service.missing(interval(100, 200)), isEmpty);
    expect(bounds(service.missing(interval(100, 300))), [
      [200, 300]
    ]);
  });

  test('UI dates retain inclusive seconds but never cover unfinished time', () {
    DateTime at(int milliseconds) =>
        DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
    final requested = HistoryCoverageService.requested(
        'slim', DateTimeRange(start: at(100100), end: at(500000)), at(200999))!;
    expect(bounds([requested]), [
      [101, 200]
    ]);
    final historical = HistoryCoverageService.requested(
        'slim', DateTimeRange(start: at(100000), end: at(199000)), at(500000))!;
    expect(bounds([historical]), [
      [100, 200]
    ]);
    expect(HistoryCoverageService.dateRange(historical).end, at(199000));
    expect(
        HistoryCoverageService.requested('slim',
            DateTimeRange(start: at(501000), end: at(600000)), at(500000)),
        isNull);
    service.complete(requested);
    final later = HistoryCoverageService.requested(
        'slim', DateTimeRange(start: at(100100), end: at(500000)), at(210000))!;
    expect(bounds(service.missing(later)), [
      [200, 210]
    ]);
  });

  test('adding the collection preserves legacy readings and device dates', () {
    isar.close();
    // Create the database with the pre-change schema first.
    directory.deleteSync(recursive: true);
    directory.createSync();
    isar = Isar.open(
        schemas: [BleDeviceSchema, DeviceDataSchema],
        directory: directory.path,
        inspector: false);
    final device = BleDevice(
        deviceId: 'slim',
        name: 'Slim',
        address: 'address',
        platform: 'test',
        firmwareVersion: '0.17.1',
        lastFetchedStartDate: DateTime.utc(2026, 9, 1),
        lastFetchedEndDate: DateTime.utc(2026, 9, 4));
    final reading = DeviceData(
        deviceId: 'slim', dateTime: DateTime.utc(2026, 9, 1), value: 800);
    isar.write((db) {
      db.bleDevices.put(device);
      db.deviceDatas.put(reading);
    });
    isar.close();
    isar = Isar.open(
        schemas: [BleDeviceSchema, DeviceDataSchema, HistoryCoverageSchema],
        directory: directory.path,
        inspector: false);
    service = HistoryCoverageService(isar);
    expect(isar.deviceDatas.get(reading.id)!.value, 800);
    expect(
        isar.bleDevices
            .get('slim')!
            .lastFetchedEndDate!
            .isAtSameMomentAs(device.lastFetchedEndDate!),
        isTrue);
    expect(isar.historyCoverages.count(), 0);
    expect(bounds(service.missing(interval(100, 500))), [
      [100, 500]
    ]);
    // Re-fetching an identical reading uses its existing ID.
    isar.write((db) => db.deviceDatas.put(reading));
    expect(isar.deviceDatas.count(), 1);
  });

  test('cleanup rolls back with failed deletion and clears only its device',
      () {
    service.complete(interval(100, 200));
    service.complete(interval(100, 200, device: 'other'));
    expect(
        () => isar.write((db) {
              HistoryCoverageService.clearDevice(db, 'slim');
              throw StateError('delete failed');
            }),
        throwsStateError);
    expect(service.missing(interval(100, 200)), isEmpty);
    isar.write((db) => HistoryCoverageService.clearDevice(db, 'slim'));
    expect(bounds(service.missing(interval(100, 200))), [
      [100, 200]
    ]);
    expect(service.missing(interval(100, 200, device: 'other')), isEmpty);
  });
}
