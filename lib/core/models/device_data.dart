import 'package:isar/isar.dart';

part 'device_data.g.dart';

@collection
class DeviceData {
  DeviceData({
    required this.deviceId,
    required this.dateTime,
    required this.value,
    this.type = DeviceDataType.co2,
  });

  final String deviceId;

  @Index()
  final DateTime dateTime;

  final dynamic value;

  @enumValue
  final DeviceDataType type;

  String get id => deviceId + dateTime.millisecondsSinceEpoch.toString();

  DeviceData copyWith({
    String? deviceId,
    DateTime? dateTime,
    dynamic value,
    DeviceDataType? type,
  }) {
    return DeviceData(
      deviceId: deviceId ?? this.deviceId,
      dateTime: dateTime ?? this.dateTime,
      value: value ?? this.value,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceData &&
        other.deviceId == deviceId &&
        other.dateTime == dateTime &&
        other.value == value &&
        other.type == type;
  }

  @override
  int get hashCode =>
      deviceId.hashCode ^ dateTime.hashCode ^ value.hashCode ^ type.hashCode;

  @override
  String toString() =>
      'DeviceData(deviceId: $deviceId, dateTime: $dateTime, value: $value), type: $type';

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
  empty;

  static DeviceDataType fromByte(int byte) {
    switch (byte) {
      case 0x00:
        return DeviceDataType.co2;
      case 0x01:
        return DeviceDataType.batteryLow;
      case 0x02:
        return DeviceDataType.calibration;
      case 0x03:
        return DeviceDataType.sensorError;
      case 0x04:
        return DeviceDataType.reset;
      case 0x05:
        return DeviceDataType.sensorFactoryReset;
      case 0x06:
        return DeviceDataType.calibrationCorrection;
      case 0x07:
        return DeviceDataType.sensorAutoCalibration;
      case 0x08:
        return DeviceDataType.integrityError;
      case 0x09:
        return DeviceDataType.calibrationTarget;
      case 0x0A:
        return DeviceDataType.timeSync;
      default:
        return DeviceDataType.empty;
    }
  }

  String humanizedName() {
    switch (this) {
      case DeviceDataType.co2:
        return 'CO2';
      case DeviceDataType.batteryLow:
        return 'Battery Low';
      case DeviceDataType.calibration:
        return 'Calibration Start';
      case DeviceDataType.sensorError:
        return 'Sensor Error';
      case DeviceDataType.reset:
        return 'Device Reset';
      case DeviceDataType.sensorFactoryReset:
        return 'Sensor Factory Reset';
      case DeviceDataType.calibrationCorrection:
        return 'Calibration Correction';
      case DeviceDataType.sensorAutoCalibration:
        return 'Sensor Auto Calibration';
      case DeviceDataType.integrityError:
        return 'Integrity Error';
      case DeviceDataType.calibrationTarget:
        return 'Calibration Target';
      case DeviceDataType.timeSync:
        return 'Time Sync';
      default:
        return '-';
    }
  }

  @override
  String toString() {
    return humanizedName();
  }
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
