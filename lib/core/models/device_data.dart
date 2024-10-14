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

  String get id => deviceId + dateTime.toIso8601String();
}
