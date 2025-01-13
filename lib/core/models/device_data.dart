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
}

enum DeviceDataType {
  co2,
  batteryLow,
  calibration,
  sensorError,
  reset,
  empty;

  static DeviceDataType fromByte(int byte) {
    switch (byte) {
      case 0:
        return DeviceDataType.co2;
      case 1:
        return DeviceDataType.batteryLow;
      case 2:
        return DeviceDataType.calibration;
      case 3:
        return DeviceDataType.sensorError;
      case 4:
        return DeviceDataType.reset;
      default:
        return DeviceDataType.empty;
    }
  }
}
