import 'package:airspothealth/core/models/device_capabilities.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:isar_plus/isar_plus.dart';

part 'ble_device.g.dart';

@Collection(ignore: {'copyWith'})
class BleDevice {
  BleDevice({
    required this.deviceId,
    required this.name,
    required this.address,
    required this.platform,
    this.alias,
    this.firmwareVersion = '-.-.-',
    this.lastFetchedStartDate,
    this.lastFetchedEndDate,
    this.deviceModel,
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

  final String firmwareVersion;

  final DateTime? lastFetchedStartDate;
  final DateTime? lastFetchedEndDate;

  /// Device model type (Screen, Slim, or unknown)
  /// If null or unknown, defaults to Screen capabilities for backward compatibility
  final DeviceModel? deviceModel;

  BleDevice copyWith({
    String? deviceId,
    String? name,
    String? address,
    String? platform,
    String? alias,
    String? firmwareVersion,
    DateTime? lastFetchedStartDate,
    DateTime? lastFetchedEndDate,
    DeviceModel? deviceModel,
  }) {
    return BleDevice(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      address: address ?? this.address,
      platform: platform ?? this.platform,
      alias: alias ?? this.alias,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      lastFetchedStartDate: lastFetchedStartDate ?? this.lastFetchedStartDate,
      lastFetchedEndDate: lastFetchedEndDate ?? this.lastFetchedEndDate,
      deviceModel: deviceModel ?? this.deviceModel,
    );
  }

  @ignore
  DeviceSettings? get settings => IsarService().read<DeviceSettings?>((isar) =>
      isar.deviceSettings.where().deviceIdEqualTo(deviceId).findFirst());

  /// Get device capabilities based on device model
  /// Defaults to Screen capabilities if model is unknown or null (backward compatibility)
  @ignore
  DeviceCapabilities get capabilities {
    final model = deviceModel ?? DeviceModel.fromDeviceName(name);
    return DeviceCapabilities.fromModel(model);
  }

  @override
  String toString() {
    return 'BleDevice{deviceId: $deviceId, name: $name, address: $address, platform: $platform, alias: $alias, firmwareVersion: $firmwareVersion, deviceModel: $deviceModel, lastFetchedStartDate: $lastFetchedStartDate, lastFetchedEndDate: $lastFetchedEndDate}';
  }

  @ignore
  DateTimeRange? get lastFetchedDateTimeRange {
    if (lastFetchedStartDate == null || lastFetchedEndDate == null) {
      return null;
    }

    return DateTimeRange(
      start: lastFetchedStartDate!,
      end: lastFetchedEndDate!,
    );
  }
}
