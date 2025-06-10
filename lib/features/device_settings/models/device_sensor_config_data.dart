import 'package:flutter/foundation.dart';

@immutable
class DeviceSensorConfigData {
  final double temperatureOffset;
  final int sensorAltitude;
  final int ambientPressure;
  final bool ascEnabled;
  final int ascTarget;
  final String serialNumber;
  final String sensorVariant;

  const DeviceSensorConfigData({
    required this.temperatureOffset,
    required this.sensorAltitude,
    required this.ambientPressure,
    required this.ascEnabled,
    required this.ascTarget,
    required this.serialNumber,
    required this.sensorVariant,
  });

  Map<String, dynamic> toJson() => {
        'Temperature Offset': temperatureOffset.toStringAsFixed(2),
        'Sensor Altitude': sensorAltitude,
        'Ambient Pressure': ambientPressure,
        'ASC Enabled': ascEnabled,
        'ASC Target': ascTarget,
        'Serial Number': serialNumber,
        'Sensor Variant': sensorVariant,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceSensorConfigData &&
          runtimeType == other.runtimeType &&
          temperatureOffset == other.temperatureOffset &&
          sensorAltitude == other.sensorAltitude &&
          ambientPressure == other.ambientPressure &&
          ascEnabled == other.ascEnabled &&
          ascTarget == other.ascTarget &&
          serialNumber == other.serialNumber &&
          sensorVariant == other.sensorVariant;

  @override
  int get hashCode =>
      temperatureOffset.hashCode ^
      sensorAltitude.hashCode ^
      ambientPressure.hashCode ^
      ascEnabled.hashCode ^
      ascTarget.hashCode ^
      serialNumber.hashCode ^
      sensorVariant.hashCode;
}
