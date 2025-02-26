import 'package:isar/isar.dart';

part 'device_data.g.dart';

@collection
class DeviceData {
  DeviceData({
    required this.deviceId,
    required this.dateTime,
    required this.value,
    this.type = DeviceDataType.co2,
    this.isLiveCo2 = false,
  });

  final String deviceId;

  @Index()
  final DateTime dateTime;

  final dynamic value;

  final bool isLiveCo2;

  @enumValue
  final DeviceDataType type;

  String get id => deviceId + dateTime.millisecondsSinceEpoch.toString();

  DeviceData copyWith({
    String? deviceId,
    DateTime? dateTime,
    dynamic value,
    DeviceDataType? type,
    bool? isLiveCo2,
  }) {
    return DeviceData(
      deviceId: deviceId ?? this.deviceId,
      dateTime: dateTime ?? this.dateTime,
      value: value ?? this.value,
      type: type ?? this.type,
      isLiveCo2: isLiveCo2 ?? this.isLiveCo2,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceData &&
        other.deviceId == deviceId &&
        other.dateTime == dateTime &&
        other.value == value &&
        other.type == type &&
        other.isLiveCo2 == isLiveCo2;
  }

  @override
  int get hashCode =>
      deviceId.hashCode ^
      dateTime.hashCode ^
      value.hashCode ^
      type.hashCode ^
      isLiveCo2.hashCode;

  @override
  String toString() =>
      'DeviceData(deviceId: $deviceId, dateTime: $dateTime, value: $value, type: $type, isLiveCo2: $isLiveCo2)';

  @ignore
  String get hexString {
    // convert whole value to hex string
    // first date time to hex
    // then value to hex with swap endian
    // then type to hex
    // then add 0x00 for reserved byte
    final dateTimeHex = dateTime.millisecondsSinceEpoch.toRadixString(16);
    final valueHex = value.toRadixString(16);
    final typeHex = type.index.toRadixString(16);

    final hexString =
        '${dateTimeHex + valueHex.padLeft(16, '0')}${typeHex.padLeft(2, '0')}00';

    return hexString;
  }

  @ignore
  String get parsedValue {
    if (type == DeviceDataType.reset) {
      return resetReasonMap[value] ?? 'Unknown';
    }

    if (type == DeviceDataType.sensorAutoCalibration) {
      return value == 0 ? 'Disabled' : 'Enabled';
    }

    return value.toString();
  }

  String toCsvString() {
    return '$deviceId,$dateTime,$value,$type';
  }
}

enum DeviceDataType {
  co2,
  batteryLow,
  calibration,
  sensorError,
  reset,
  sensorFactoryReset,
  calibrationCorrection,
  sensorAutoCalibration,
  integrityError,
  calibrationTarget,
  timeSync,
  calibrationAdjustment,
  ascLowest,
  empty;

  static DeviceDataType fromByte(int byte) =>
      deviceDataByteMap[byte] ?? DeviceDataType.empty;

  @override
  String toString() => humanizedName();

  String humanizedName() => deviceDataTypeMap[this] ?? '-';
}

const resetReasonMap = {
  0: 'Unknown',
  1: 'Pin Reset',
  2: 'Watchdog',
  3: 'Soft Reset',
  4: 'CPU Lock-up',
  5: 'Wake up from System OFF mode (GPIO)',
  6: 'Wake up from System OFF mode (LPCOMP)',
  7: 'Wake up from System OFF mode (Debug Interface)',
  8: 'Wake up from System OFF mode (NFC)',
};

const deviceDataByteMap = {
  0x00: DeviceDataType.co2,
  0x01: DeviceDataType.batteryLow,
  0x02: DeviceDataType.calibration,
  0x03: DeviceDataType.sensorError,
  0x04: DeviceDataType.reset,
  0x05: DeviceDataType.sensorFactoryReset,
  0x06: DeviceDataType.calibrationCorrection,
  0x07: DeviceDataType.sensorAutoCalibration,
  0x08: DeviceDataType.integrityError,
  0x09: DeviceDataType.calibrationTarget,
  0x0A: DeviceDataType.timeSync,
  0x0B: DeviceDataType.calibrationAdjustment,
  0x0C: DeviceDataType.ascLowest,
  // 0x0D: DeviceDataType.empty,
};

const deviceDataTypeMap = {
  DeviceDataType.co2: 'CO2',
  DeviceDataType.batteryLow: 'Battery Low',
  DeviceDataType.calibration: 'Calibration Start',
  DeviceDataType.sensorError: 'Sensor Error',
  DeviceDataType.reset: 'Device Reset',
  DeviceDataType.sensorFactoryReset: 'Sensor Factory Reset',
  DeviceDataType.calibrationCorrection: 'Calibration Correction',
  DeviceDataType.sensorAutoCalibration: 'Sensor Auto Calibration',
  DeviceDataType.integrityError: 'Integrity Error',
  DeviceDataType.calibrationTarget: 'Calibration Target',
  DeviceDataType.timeSync: 'Time Sync',
  DeviceDataType.calibrationAdjustment: 'Calibration Adjustment',
  DeviceDataType.ascLowest: 'ASC Lowest',
  DeviceDataType.empty: '-',
};
