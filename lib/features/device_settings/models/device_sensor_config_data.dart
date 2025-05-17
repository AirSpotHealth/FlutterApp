import 'package:flutter/foundation.dart';

@immutable
class DeviceSensorConfigData {
  final int temperatureOffset;
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

  // Placeholder fromBytes - actual implementation depends on device response format
  factory DeviceSensorConfigData.fromBytes(List<int> bytes) {
    // Assuming the response for 0x30 is structured and parsed here.
    // This is a placeholder and needs to be implemented based on the
    // actual byte structure returned by the device.
    // Example:
    // finalByteData = ByteData.sublistView(Uint8List.fromList(bytes));
    // int offset = 0; // Start parsing from the beginning of the relevant payload

    // final int tempOffset = byteData.getInt16(offset); offset += 2;
    // final int altitude = byteData.getInt16(offset); offset += 2;
    // final int pressure = byteData.getInt32(offset); offset += 4;
    // final bool asc = byteData.getUint8(offset) == 1; offset += 1;
    // final int ascT = byteData.getUint16(offset); offset += 2;
    // final String serial = String.fromCharCodes(bytes.sublist(offset, offset + 10)); // Assuming 10 bytes for serial
    // offset += 10;
    // final String variant = String.fromCharCodes(bytes.sublist(offset, offset + X)); // Assuming X bytes for variant

    // Replace with actual parsing logic
    debugPrint(
        "DeviceSensorConfigData.fromBytes called with bytes: ${bytes.map((b) => b.toRadixString(16)).join(' ')} - PARSING LOGIC IS A PLACEHOLDER");
    return DeviceSensorConfigData(
      temperatureOffset: 4, // Placeholder
      sensorAltitude: 0, // Placeholder
      ambientPressure: 101300, // Placeholder
      ascEnabled: false, // Placeholder
      ascTarget: 500, // Placeholder
      serialNumber: 'SN_PLACEHOLDER', // Placeholder
      sensorVariant: 'VAR_PLACEHOLDER', // Placeholder
    );
  }

  DeviceSensorConfigData copyWith({
    int? temperatureOffset,
    int? sensorAltitude,
    int? ambientPressure,
    bool? ascEnabled,
    int? ascTarget,
    String? serialNumber,
    String? sensorVariant,
  }) {
    return DeviceSensorConfigData(
      temperatureOffset: temperatureOffset ?? this.temperatureOffset,
      sensorAltitude: sensorAltitude ?? this.sensorAltitude,
      ambientPressure: ambientPressure ?? this.ambientPressure,
      ascEnabled: ascEnabled ?? this.ascEnabled,
      ascTarget: ascTarget ?? this.ascTarget,
      serialNumber: serialNumber ?? this.serialNumber,
      sensorVariant: sensorVariant ?? this.sensorVariant,
    );
  }

  Map<String, dynamic> toJson() => {
        'Temperature Offset': temperatureOffset,
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
