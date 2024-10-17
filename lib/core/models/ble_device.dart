import 'package:isar/isar.dart';

part 'ble_device.g.dart';

@Collection(ignore: {'copyWith'})
class BleDevice {
  BleDevice({
    required this.deviceId,
    required this.name,
    required this.address,
    required this.platform,
    this.alias,
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

  final String? alias;

  BleDevice copyWith({
    String? deviceId,
    String? name,
    String? address,
    String? platform,
    String? alias,
  }) {
    return BleDevice(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      address: address ?? this.address,
      platform: platform ?? this.platform,
      alias: alias ?? this.alias,
    );
  }
}
