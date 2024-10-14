import 'package:isar/isar.dart';

part 'ble_device.g.dart';

@collection
class BleDevice {
  BleDevice({
    required this.deviceId,
    required this.name,
    required this.address,
    required this.platform,
  });

  @Id()
  final String deviceId;

  @Index()
  final String name;

  @Index()
  final String address;

  final DateTime createdAt = DateTime.now();

  final DateTime lastConnectedAt = DateTime.now();

  final String platform;
}
