/// Device model types for AirSpot devices
enum DeviceModel {
  /// AirSpot Screen - Original device with e-ink display, buzzer, and vibration
  airspotScreen,

  /// AirSpot Slim - Compact version without screen, using LED indicators
  airspotSlim,

  /// Unknown device model (defaults to Screen capabilities for backward compatibility)
  unknown;

  /// Create DeviceModel from a value (e.g., from firmware response)
  /// Returns unknown if value is null or doesn't match known models
  static DeviceModel fromValue(int? value) {
    if (value == null) return unknown;
    // Add mapping logic here if firmware provides device model value
    // For now, we'll detect via device name pattern
    return unknown;
  }

  /// Persisted Slim identity or a discovered SMP service selects MCUboot DFU.
  static DeviceModel forDfu(DeviceModel? savedModel,
          {required bool hasSmpService}) =>
      savedModel == DeviceModel.airspotSlim || hasSmpService
          ? DeviceModel.airspotSlim
          : DeviceModel.airspotScreen;

  /// Get display name for the device model
  String get displayName {
    switch (this) {
      case DeviceModel.airspotScreen:
        return 'AirSpot Screen';
      case DeviceModel.airspotSlim:
        return 'AirSpot Slim';
      case DeviceModel.unknown:
        return 'AirSpot Screen'; // Default to Screen for backward compatibility
    }
  }

  /// Detect device model from device name.
  /// Both Screen and Slim advertise as "AirSpot-XXXXXX" — name alone cannot
  /// distinguish them. Use [BLEService.deviceModelFromScan] (SMP UUID check)
  /// for scan-time detection, or the persisted [BleDevice.deviceModel] field
  /// for saved devices.
  static DeviceModel fromDeviceName(String name) {
    return DeviceModel.airspotScreen;
  }
}
