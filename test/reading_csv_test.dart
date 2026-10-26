import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/features/device_settings/service/reading_csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final time = DateTime(2026, 10, 18, 12);
  DeviceData row(DeviceDataType type, int value,
          {DateTime? at, String id = 'slim'}) =>
      DeviceData(
          deviceId: id, dateTime: at ?? time, value: value, type: type.index);
  List<DeviceData> sample({DateTime? at, int asc = 1, int flags = 111}) => [
        row(DeviceDataType.co2, 420, at: at),
        row(DeviceDataType.rawCo2, 380, at: at),
        row(DeviceDataType.sampleCorrection, 40, at: at),
        row(DeviceDataType.sampleTemperature, -250, at: at),
        row(DeviceDataType.sampleHumidity, 5025, at: at),
        row(DeviceDataType.samplePressure, 1013, at: at),
        row(DeviceDataType.sampleBatteryPercent, 72, at: at),
        row(DeviceDataType.sampleBatteryMv, 3800, at: at),
        row(DeviceDataType.sampleAscMode, asc, at: at),
        row(DeviceDataType.sampleStatus, 32768, at: at),
        row(DeviceDataType.sampleFlags, flags, at: at),
        row(DeviceDataType.sampleQi, 1, at: at),
      ];
  test('twelve internal records become exactly one complete measurement row',
      () {
    final csv = generateReadingCsv(sample().reversed.toList());
    final lines = csv.split('\n');
    expect(lines.length, 2);
    expect(lines.last,
        contains('"CO2","420","380","40","-2.50","50.25","1013","72","3800"'));
    expect(lines.last, contains('"Software on","32768"'));
    expect(lines.last, contains('"Low (3 min)"'));
    expect(csv, isNot(contains('SAMPLE QI')));
    expect(csv, isNot(contains('SAMPLE BATTERY')));
    expect(lines.last.split(',').length, lines.first.split(',').length);
  });
  test('measurements and explicit mode changes are separate chronological rows',
      () {
    final later = time.add(const Duration(minutes: 1));
    final csv = generateReadingCsv([
      ...sample(at: later, flags: 255),
      row(DeviceDataType.measurementModeChange, 3, at: later),
      ...sample(),
    ]);
    final lines = csv.split('\n');
    expect(lines.length, 4);
    expect(lines[1], contains('"CO2"'));
    expect(lines[2], contains('"MEASUREMENT MODE CHANGE",""'));
    expect(lines[2], contains('Measurement mode changed to High (5 sec)'));
    expect(lines[3], contains('"High (5 sec)"'));
  });
  test(
      'calibration policy changes produce one descriptive event, not sample rows',
      () {
    final csv = generateReadingCsv([
      ...sample(asc: 2),
      ...sample(at: time.add(const Duration(minutes: 1)), asc: 3)
    ]);
    expect(csv.split('\n').length, 4);
    expect(csv, contains('"CALIBRATION MODE CHANGE"'));
    expect(
        csv,
        contains(
            'Native paused -> Native learning (first observed in readings)'));
  });
  test('first calibration policy and unchanged policies are not change events',
      () {
    final csv = generateReadingCsv(
        [...sample(), ...sample(at: time.add(const Duration(minutes: 1)))]);
    expect(csv.split('\n').length, 3);
    expect(csv, isNot(contains('CALIBRATION MODE CHANGE')));
  });
  test(
      'failed and partial measurements each use one row without fabricated CO2',
      () {
    final csv = generateReadingCsv([
      row(DeviceDataType.sampleFlags, 9),
      row(DeviceDataType.rawCo2, -20),
      row(DeviceDataType.sampleStatus, 32768),
      row(DeviceDataType.sampleBatteryPercent, 72),
    ]);
    expect(csv.split('\n').length, 2);
    expect(csv, contains('"MEASUREMENT FAILED","","-20"'));
    expect(generateReadingCsv([row(DeviceDataType.sampleBatteryPercent, 72)]),
        contains('"INCOMPLETE MEASUREMENT"'));
  });
  test('never joins measurements across times or devices', () {
    final csv = generateReadingCsv([
      row(DeviceDataType.co2, 500,
          at: time.subtract(const Duration(minutes: 3))),
      row(DeviceDataType.co2, 510, id: 'screen'),
      row(DeviceDataType.sampleBatteryPercent, 72),
    ]);
    for (final line in csv.split('\n').where((s) => s.contains('"CO2"'))) {
      expect(line.split(',').skip(3).every((s) => s == '""'), isTrue);
    }
  });
  test('ambiguous timestamps are labelled without arbitrary joined values', () {
    final csv =
        generateReadingCsv([...sample(), row(DeviceDataType.rawCo2, 490)]);
    expect(csv.split('\n').length, 2);
    expect(csv, contains('Conflicting records'));
    expect(csv, isNot(contains('"490"')));
    expect(csv, isNot(contains('"380"')));
  });
  test(
      'flattened CSV import/export round trip preserves all measurement fields and events',
      () {
    final records = [
      ...sample(),
      row(DeviceDataType.measurementModeChange, 3),
      row(DeviceDataType.reset, 3,
          at: time.subtract(const Duration(minutes: 1)))
    ];
    final csv = generateReadingCsv(records);
    final restored = parseReadingCsv(
        'DEVICE NAME: Slim\nDEVICE VERSION: 0.20.0\n\n$csv', 'slim');
    expect(restored.map((r) => r.id).toSet(), records.map((r) => r.id).toSet());
    expect(generateReadingCsv(restored), csv);
  });
  test('legacy exports including internal diagnostic rows still import', () {
    final records = parseReadingCsv(
        'DateTime,Value,Type\n"2026-10-18-12-00-00","420","CO2"\n"2026-10-18-12-00-00","72","SAMPLE BATTERY PERCENT"\n"2026-10-18-12-00-00","Enabled","AUTOMATIC CALIBRATION"',
        'slim');
    expect(records.length, 3);
    expect(records.last.value, 1);
    expect(
        generateReadingCsv(records), isNot(contains('SAMPLE BATTERY PERCENT')));
    expect(DeviceDataType.empty.index, 23);
  });
}
