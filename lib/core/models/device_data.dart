import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:isar/isar.dart';

part 'device_data.g.dart';

@collection
class DeviceData {
  const DeviceData({
    required this.deviceId,
    required this.dateTime,
    required this.value,
    this.type = 0,
    this.isLiveCo2 = false,
  });

  @Index()
  final String deviceId;

  @Index()
  final DateTime dateTime;

  final short value;

  final bool isLiveCo2;

  @Index()
  final byte type;

  String get id =>
      deviceId +
      dateTime.millisecondsSinceEpoch.toString() +
      DeviceDataType.values[type].name;

  DeviceData copyWith({
    String? deviceId,
    DateTime? dateTime,
    short? value,
    DeviceDataType? type,
    bool? isLiveCo2,
  }) {
    return DeviceData(
      deviceId: deviceId ?? this.deviceId,
      dateTime: dateTime ?? this.dateTime,
      value: value ?? this.value,
      type: type?.index ?? this.type,
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
      'DeviceData(deviceId: $deviceId, dateTime: $dateTime, value: $value, type: ${DeviceDataType.values[type]}, isLiveCo2: $isLiveCo2)';

  @ignore
  String get hexString {
    // convert whole value to hex string
    // first date time to hex
    // then value to hex with swap endian
    // then type to hex
    // then add 0x00 for reserved byte
    final dateTimeHex = dateTime.millisecondsSinceEpoch.toRadixString(16);
    final valueHex = value.toRadixString(16);
    final typeHex = type.toRadixString(16);

    final hexString =
        '${dateTimeHex + valueHex.padLeft(16, '0')}${typeHex.padLeft(2, '0')}00';

    return hexString;
  }

  @ignore
  String get parsedValue {
    if (type == DeviceDataType.reset.index) {
      return resetReasonMap[value] ?? 'Unknown';
    }

    if (type == DeviceDataType.sensorAutoCalibration.index) {
      return value == 0 ? 'Disabled' : 'Enabled';
    }

    return value.toString();
  }

  String toCsvString() {
    return '$deviceId,$dateTime,$value,$type';
  }
}
