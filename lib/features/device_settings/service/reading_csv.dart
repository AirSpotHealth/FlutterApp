import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:intl/intl.dart';

const _ascModes = {
  0: 'Software off',
  1: 'Software on',
  2: 'Native paused',
  3: 'Native learning'
};
const _measurementModes = {
  0: 'On-demand',
  1: 'Low (3 min)',
  2: 'Mid (1 min)',
  3: 'High (5 sec)'
};
const _nativeMeasurementModes = {
  1: 'Single shot',
  3: 'Continuous',
  4: 'Single shot with sleep'
};
final _dateFormat = DateFormat('yyyy-MM-dd-HH-mm-ss');
const _headers = [
  'DateTime',
  'Type',
  'CO2 (ppm)',
  'Raw CO2 (ppm)',
  'Software Correction (ppm)',
  'Temperature (C)',
  'Humidity (%RH)',
  'Pressure (hPa)',
  'Battery (%)',
  'Battery (mV)',
  'ASC Mode',
  'Sensor Status',
  'Sample Accepted',
  'Conditioning Complete',
  'Sensor Operation',
  'Qi Active',
  'Measurement Mode',
  'Event Value',
  'Details',
  'Sample Flags'
];
const _fields = <DeviceDataType, String>{
  DeviceDataType.rawCo2: 'Raw CO2 (ppm)',
  DeviceDataType.sampleCorrection: 'Software Correction (ppm)',
  DeviceDataType.sampleTemperature: 'Temperature (C)',
  DeviceDataType.sampleHumidity: 'Humidity (%RH)',
  DeviceDataType.samplePressure: 'Pressure (hPa)',
  DeviceDataType.sampleBatteryPercent: 'Battery (%)',
  DeviceDataType.sampleBatteryMv: 'Battery (mV)',
  DeviceDataType.sampleStatus: 'Sensor Status',
  DeviceDataType.sampleQi: 'Qi Active',
  DeviceDataType.sampleFlags: 'Sample Flags',
};
bool _diagnostic(int type) =>
    type >= DeviceDataType.rawCo2.index &&
    type <= DeviceDataType.sampleQi.index;
String? _label(Map<int, String> labels, int? value) =>
    value == null ? null : labels[value] ?? 'Unknown ($value)';

/// Firmware stores a measurement as several records. Export exactly one row for
/// that measurement, plus real events. Never carry current values into the past.
String generateReadingCsv(List<DeviceData> records) {
  final groups = <(String, DateTime), List<DeviceData>>{};
  for (final r in records) {
    if (r.type < 0 ||
        r.type >= DeviceDataType.values.length ||
        r.type == DeviceDataType.empty.index) {
      continue;
    }
    groups.putIfAbsent((r.deviceId, r.dateTime), () => []).add(r);
  }
  final keys = groups.keys.toList()..sort((a, b) => a.$2.compareTo(b.$2));
  final output = <Map<String, Object?>>[];
  final lastAsc = <String, int>{};
  for (final key in keys) {
    final group = groups[key]!;
    Map<String, Object?> base(String type) =>
        {'DateTime': _dateFormat.format(key.$2), 'Type': type};
    final sample = <DeviceDataType, int>{};
    final conflicts = <DeviceDataType>{};
    for (final r in group.where((r) => _diagnostic(r.type))) {
      final type = DeviceDataType.values[r.type];
      if (sample.containsKey(type) && sample[type] != r.value) {
        conflicts.add(type);
      }
      sample[type] = r.value;
    }
    // Multiple attempts in the same second cannot be reliably joined.
    if (conflicts.isNotEmpty) sample.clear();
    final co2 = group.where((r) => r.type == DeviceDataType.co2.index).toList();
    final events = group
        .where(
            (r) => !_diagnostic(r.type) && r.type != DeviceDataType.co2.index)
        .toList();
    if (events.any((r) =>
        r.type == DeviceDataType.reset.index ||
        r.type == DeviceDataType.sensorFactoryReset.index)) {
      lastAsc.remove(key.$1);
    }
    for (final event in events) {
      final type = DeviceDataType.values[event.type];
      final row = base(type.humanizedName.toUpperCase());
      row['Event Value'] = event.value;
      row['Details'] = event.parsedValue;
      if (type == DeviceDataType.measurementModeChange) {
        row['Measurement Mode'] = event.value & 0x100 != 0
            ? _label(_nativeMeasurementModes, event.value & 0xff)
            : _label(_measurementModes, event.value);
        row['Details'] =
            'Measurement mode changed to ${row['Measurement Mode']}';
      }
      if (type == DeviceDataType.sensorAutoCalibration) {
        row['Details'] =
            'Software automatic calibration ${event.value == 0 ? 'disabled' : 'enabled'}';
      }
      output.add(row);
    }
    final asc = sample[DeviceDataType.sampleAscMode];
    final previousAsc = lastAsc[key.$1];
    if (asc != null &&
        previousAsc != null &&
        asc != previousAsc &&
        !events
            .any((e) => e.type == DeviceDataType.sensorAutoCalibration.index)) {
      output.add(base('CALIBRATION MODE CHANGE')
        ..addAll({
          'Event Value': asc,
          'ASC Mode': _label(_ascModes, asc),
          'Details':
              '${_label(_ascModes, previousAsc)} -> ${_label(_ascModes, asc)} (first observed in readings)',
        }));
    }
    if (asc != null) lastAsc[key.$1] = asc;
    if (co2.isEmpty && sample.isEmpty && conflicts.isEmpty) continue;
    final flags = sample[DeviceDataType.sampleFlags];
    final row = base(co2.isNotEmpty
        ? 'CO2'
        : flags != null && flags & 4 == 0
            ? 'MEASUREMENT FAILED'
            : 'INCOMPLETE MEASUREMENT');
    if (co2.length == 1) row['CO2 (ppm)'] = co2.single.value;
    if (co2.length > 1 || conflicts.isNotEmpty) {
      row['Details'] =
          'Conflicting records at this timestamp; diagnostic columns left blank';
      sample.clear();
    }
    for (final entry in _fields.entries) {
      final value = sample[entry.key];
      row[entry.value] = value == null
          ? null
          : (entry.key == DeviceDataType.sampleTemperature ||
                  entry.key == DeviceDataType.sampleHumidity)
              ? (value / 100).toStringAsFixed(2)
              : value;
    }
    row['ASC Mode'] = _label(_ascModes, sample[DeviceDataType.sampleAscMode]);
    final validFlags = sample[DeviceDataType.sampleFlags];
    if (validFlags != null) {
      row['Sample Accepted'] = validFlags & 4 != 0 ? 1 : 0;
      row['Conditioning Complete'] = validFlags & 8 != 0 ? 1 : 0;
      row['Sensor Operation'] =
          validFlags & 512 != 0 && ((validFlags >> 6) & 7) == 4
              ? 'Single shot with sleep'
              : (validFlags & 16 != 0 ? 'Continuous' : 'Single shot');
      if (validFlags & 32 != 0) {
        row['Measurement Mode'] = validFlags & 512 != 0
            ? _label(_nativeMeasurementModes, (validFlags >> 6) & 7)
            : _label(_measurementModes, (validFlags >> 6) & 3);
      }
    }
    if (co2.length > 1) {
      for (final reading in co2) {
        output.add({...row, 'CO2 (ppm)': reading.value});
      }
    } else {
      if (co2.length == 1 && conflicts.isEmpty) {
        row['Temperature (C)'] ??= co2.single.temperature?.toStringAsFixed(2);
        row['Humidity (%RH)'] ??= co2.single.humidity?.toStringAsFixed(2);
      }
      output.add(row);
    }
  }
  String quote(Object? value) =>
      '"${(value ?? '').toString().replaceAll('"', '""')}"';
  return '${_headers.join(',')}\n${output.map((r) => _headers.map((h) => quote(r[h])).join(',')).join('\n')}';
}

/// Read both flattened exports and legacy event-per-row exports. Recreate the
/// internal records so a subsequent export retains measurement diagnostics.
List<DeviceData> parseReadingCsv(String csv, String deviceId) {
  final lines = csv.split(RegExp(r'\r?\n'));
  final headerIndex = lines.indexWhere((l) => l.startsWith('DateTime,'));
  if (headerIndex < 0) return [];
  final headers = _parseLine(lines[headerIndex]);
  final records = <String, DeviceData>{};
  for (final line in lines.skip(headerIndex + 1)) {
    if (line.trim().isEmpty) continue;
    final values = _parseLine(line);
    String cell(String name) {
      final i = headers.indexOf(name);
      return i < 0 || i >= values.length ? '' : values[i];
    }

    DateTime time;
    try {
      time = _dateFormat.parseStrict(cell('DateTime'));
    } catch (_) {
      continue;
    }
    void add(DeviceDataType type, int? value) {
      if (value == null) return;
      final r = DeviceData(
          deviceId: deviceId, dateTime: time, value: value, type: type.index);
      records[r.id] = r;
    }

    final name = cell('Type').toUpperCase();
    DeviceDataType? type;
    for (final t in DeviceDataType.values) {
      if (t != DeviceDataType.empty && t.humanizedName.toUpperCase() == name) {
        type = t;
        break;
      }
    }
    final legacy = headers.contains('Value');
    if (type != null) {
      final valueText = legacy
          ? cell('Value')
          : type == DeviceDataType.co2
              ? cell('CO2 (ppm)')
              : cell('Event Value');
      int? value = int.tryParse(valueText);
      if (value == null && legacy) {
        if (type == DeviceDataType.sensorAutoCalibration ||
            type == DeviceDataType.flightMode) {
          value = valueText == 'Enabled'
              ? 1
              : valueText == 'Disabled'
                  ? 0
                  : null;
        } else if (type == DeviceDataType.reset ||
            type == DeviceDataType.sensorError) {
          final labels =
              type == DeviceDataType.reset ? resetReasonMap : sensorErrorMap;
          for (final e in labels.entries) {
            if (e.value == valueText) value = e.key;
          }
        }
      }
      add(type, value);
    }
    final measurement = type == DeviceDataType.co2 ||
        name == 'MEASUREMENT FAILED' ||
        name == 'INCOMPLETE MEASUREMENT';
    if (measurement) {
      for (final entry in _fields.entries) {
        final value = num.tryParse(cell(entry.value));
        add(
            entry.key,
            value == null
                ? null
                : (entry.key == DeviceDataType.sampleTemperature ||
                        entry.key == DeviceDataType.sampleHumidity)
                    ? (value * 100).round()
                    : value.toInt());
      }
      for (final e in _ascModes.entries) {
        if (e.value == cell('ASC Mode')) {
          add(DeviceDataType.sampleAscMode, e.key);
        }
      }
    }
  }
  return records.values.toList();
}

List<String> _parseLine(String line) {
  final cells = <String>[];
  var cell = StringBuffer();
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      if (quoted && i + 1 < line.length && line[i + 1] == '"') {
        cell.write('"');
        i++;
      } else {
        quoted = !quoted;
      }
    } else if (c == ',' && !quoted) {
      cells.add(cell.toString());
      cell = StringBuffer();
    } else {
      cell.write(c);
    }
  }
  cells.add(cell.toString());
  return cells;
}
