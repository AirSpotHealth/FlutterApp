import 'dart:io';
import 'dart:typed_data';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/models/history_coverage.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:airspothealth/core/services/history_coverage_service.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_plus/isar_plus.dart';

import 'history_coverage_test.dart' show initializeHistoryTestDatabase;

class TestIsarService implements IsarService {
  TestIsarService(this.isar);
  final Isar isar;
  bool failWrites = false;
  @override
  void write(void Function(Isar) fn) {
    if (failWrites) throw StateError('disk write failed');
    isar.write(fn);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FailingCoverageService extends HistoryCoverageService {
  FailingCoverageService(super.isar);
  @override
  void complete(HistoryCoverage interval) =>
      throw StateError('coverage write failed');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Isar isar;
  late TestIsarService storage;
  late HistoryCoverageService coverage;
  late ProviderContainer container;
  late List<Uint8List> commands;
  final provider = deviceHistoryDataRequestProvider('slim');

  DateTime day(int value) => DateTime.utc(2026, 9, value);
  GraphDataDuration range(int start, int end) =>
      GraphDataDuration.custom(DateTimeRange(
          start: day(start),
          end: day(end).subtract(const Duration(seconds: 1))));
  HistoryCoverage interval(int start, int end) => HistoryCoverage(
      deviceId: 'slim',
      startSecond: day(start).millisecondsSinceEpoch ~/ 1000,
      endSecond: day(end).millisecondsSinceEpoch ~/ 1000);
  List<DeviceData> readings(int start, int end) => [
        DeviceData(deviceId: 'slim', dateTime: day(start), value: 700),
        DeviceData(deviceId: 'slim', dateTime: day(end), value: 800),
      ];
  ProviderContainer createContainer(
          {DeviceModel model = DeviceModel.airspotSlim}) =>
      ProviderContainer(overrides: [
        isarServiceProvider.overrideWithValue(storage),
        historyCoverageServiceProvider.overrideWithValue(coverage),
        bleDeviceProvider('slim').overrideWithValue(BleDevice(
            deviceId: 'slim',
            name: 'Slim',
            address: 'address',
            platform: 'test',
            firmwareVersion:
                model == DeviceModel.airspotSlim ? '0.17.1' : '3.0.0',
            deviceModelValue: model.index,
            // Deliberately misleading legacy coverage.
            lastFetchedStartDate: day(1),
            lastFetchedEndDate: day(10))),
        historyCommandSenderProvider('slim').overrideWithValue((command) async {
          commands.add(command);
          return true;
        }),
      ]);

  setUpAll(initializeHistoryTestDatabase);
  setUp(() {
    directory = Directory.systemTemp.createTempSync('slim-history-');
    isar = Isar.open(
        schemas: [DeviceDataSchema, BleDeviceSchema, HistoryCoverageSchema],
        directory: directory.path,
        inspector: false);
    storage = TestIsarService(isar);
    coverage = HistoryCoverageService(isar);
    commands = [];
    container = createContainer();
  });
  tearDown(() {
    container.dispose();
    isar.close();
    directory.deleteSync(recursive: true);
  });

  test('day 1 and day 4 downloads leave day 2 and 3 eligible', () {
    final sync = container.read(provider.notifier);
    for (final d in [1, 4]) {
      sync.request(range(d, d + 1));
      sync.handleHistoricalDataResponse(1);
      sync.handleHistoricalDataResponse(readings(d - 1, d), pageNumber: 1);
      expect(container.read(provider), isA<AsyncSuccess>());
    }
    expect(coverage.missing(interval(1, 5)).single.startSecond,
        interval(2, 4).startSecond);
    expect(coverage.missing(interval(1, 5)).single.endSecond,
        interval(2, 4).endSecond);
    sync.request(range(2, 4));
    expect(sync.pendingDateTimeRange!.start, day(2));
    sync.handleHistoricalDataResponse(1);
    sync.handleHistoricalDataResponse(readings(1, 3), pageNumber: 1);
    expect(coverage.missing(interval(1, 5)), isEmpty);
    final count = commands.length;
    sync.request(range(1, 5));
    expect(commands.length, count);
    expect(container.read(provider), isA<AsyncSuccess>());
  });

  test('missing intervals on both sides run sequentially', () {
    coverage.complete(interval(2, 3));
    final sync = container.read(provider.notifier);
    sync.request(range(1, 4));
    expect(sync.pendingDateTimeRange!.start, day(1));
    sync.handleHistoricalDataResponse(1);
    sync.handleHistoricalDataResponse(readings(0, 1), pageNumber: 1);
    expect(container.read(provider), isA<AsyncInProgress>());
    expect(sync.pendingDateTimeRange!.start, day(3));
    sync.handleHistoricalDataResponse(1);
    sync.handleHistoricalDataResponse(readings(2, 3), pageNumber: 1);
    expect(container.read(provider), isA<AsyncSuccess>());
    expect(coverage.missing(interval(1, 4)), isEmpty);
  });

  testWidgets('timeout ignores late pages and remains retryable after restart',
      (tester) async {
    final sync = container.read(provider.notifier);
    sync.request(range(2, 3));
    sync.handleHistoricalDataResponse(1);
    await tester.pump(const Duration(seconds: 31));
    expect(container.read(provider), isA<AsyncFailure>());
    sync.handleHistoricalDataResponse(readings(1, 2), pageNumber: 1);
    expect(isar.historyCoverages.count(), 0);
    container.dispose();
    container = createContainer();
    container.read(provider.notifier).request(range(2, 3));
    expect(container.read(provider), isA<AsyncInProgress>());
    container.read(provider.notifier).clear();
  });

  test('failure in a later interval preserves only earlier completed coverage',
      () {
    coverage.complete(interval(2, 3));
    final sync = container.read(provider.notifier);
    sync.request(range(1, 4));
    sync.handleHistoricalDataResponse(1);
    sync.handleHistoricalDataResponse(readings(0, 1), pageNumber: 1);
    sync.handleHistoricalDataResponse(null);
    expect(container.read(provider), isA<AsyncFailure>());
    expect(coverage.missing(interval(1, 4)).single.startSecond,
        interval(3, 4).startSecond);
  });

  test(
      'coverage write failure preserves readings and leaves the interval retryable',
      () {
    container.dispose();
    coverage = FailingCoverageService(isar);
    container = createContainer();
    final sync = container.read(provider.notifier);
    sync.request(range(2, 3));
    sync.handleHistoricalDataResponse(1);
    sync.handleHistoricalDataResponse(readings(1, 2), pageNumber: 1);
    expect(container.read(provider), isA<AsyncFailure>());
    expect(isar.deviceDatas.count(), 2);
    expect(isar.historyCoverages.count(), 0);
    expect(coverage.missing(interval(2, 3)), hasLength(1));
  });

  test('cancel, malformed response and stale page cannot certify coverage', () {
    final sync = container.read(provider.notifier);
    sync.request(range(2, 3));
    sync.handleHistoricalDataResponse(1);
    sync.handleHistoricalDataResponse(readings(1, 2), pageNumber: 5);
    expect(sync.currentPageNumber, 1);
    sync.clear();
    sync.handleHistoricalDataResponse(readings(1, 2), pageNumber: 1);
    expect(container.read(provider), isA<AsyncNone>());
    sync.request(range(2, 3));
    sync.handleHistoricalDataResponse(null);
    expect(container.read(provider), isA<AsyncFailure>());
    expect(isar.historyCoverages.count(), 0);
  });

  test('disconnect or update pause cannot certify a pending scan', () {
    final sync = container.read(provider.notifier);
    sync.request(range(2, 3));
    sync.handleHistoricalDataResponse(1);
    sync.handleDisconnected();
    sync.handleHistoricalDataResponse(readings(1, 2), pageNumber: 1);
    expect(container.read(provider), isA<AsyncFailure>());
    sync.request(range(2, 3));
    sync.handleHistoricalDataResponse(1);
    sync.pauseForUpdate();
    sync.handleHistoricalDataResponse(readings(1, 2), pageNumber: 1);
    expect(container.read(provider), isA<AsyncNone>());
    expect(isar.historyCoverages.count(), 0);
  });

  test('failed readings write prevents success and coverage; retry saves once',
      () {
    final sync = container.read(provider.notifier);
    sync.request(range(2, 3));
    sync.handleHistoricalDataResponse(1);
    storage.failWrites = true;
    sync.handleHistoricalDataResponse(readings(1, 2), pageNumber: 1);
    expect(container.read(provider), isA<AsyncFailure>());
    expect(isar.historyCoverages.count(), 0);
    expect(isar.deviceDatas.count(), 0);
    storage.failWrites = false;
    sync.request(range(2, 3));
    sync.handleHistoricalDataResponse(1);
    sync.handleHistoricalDataResponse(readings(1, 2), pageNumber: 1);
    expect(container.read(provider), isA<AsyncSuccess>());
    expect(isar.deviceDatas.count(), 2);
    expect(coverage.missing(interval(2, 3)), isEmpty);
  });

  test(
      'reaching page zero before the requested start leaves coverage unverified',
      () {
    final sync = container.read(provider.notifier);
    sync.request(range(1, 4));
    sync.handleHistoricalDataResponse(0);
    sync.handleHistoricalDataResponse(readings(2, 3), pageNumber: 0);
    expect(isar.deviceDatas.count(), 2);
    expect(isar.historyCoverages.count(), 0);
  });

  test('Screen continues using legacy dates without creating Slim coverage',
      () {
    container.dispose();
    container = createContainer(model: DeviceModel.airspotScreen);
    final sync = container.read(provider.notifier);
    sync.request(range(2, 3));
    sync.handleHistoricalDataResponse(1);
    sync.handleHistoricalDataResponse(readings(2, 3));
    expect(container.read(provider), isA<AsyncSuccess>());
    expect(isar.historyCoverages.count(), 0);
  });
}
