import 'package:isar/isar.dart';

part 'device_data.g.dart';

@collection
class DeviceData {
  DeviceData({
    required this.deviceId,
    required this.dateTime,
    required this.value,
  });

  final String deviceId;

  @Index()
  final DateTime dateTime;

  final dynamic value;

  String get id => deviceId + dateTime.millisecondsSinceEpoch.toString();

  DeviceData copyWith({
    String? deviceId,
    DateTime? dateTime,
    dynamic value,
  }) {
    return DeviceData(
      deviceId: deviceId ?? this.deviceId,
      dateTime: dateTime ?? this.dateTime,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceData &&
        other.deviceId == deviceId &&
        other.dateTime == dateTime &&
        other.value == value;
  }

  @override
  int get hashCode => deviceId.hashCode ^ dateTime.hashCode ^ value.hashCode;

  @override
  String toString() =>
      'DeviceData(deviceId: $deviceId, dateTime: $dateTime, value: $value)';
}
