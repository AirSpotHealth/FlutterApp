import 'package:airspothealth/core/models/device_model.dart';

/// Abstract base class for device capabilities
/// Follows Strategy pattern to allow different implementations for different device models
abstract class DeviceCapabilities {
  /// Whether the device has a screen (e-ink display)
  bool hasScreen();

  /// Whether the device has alarm/buzzer functionality
  bool hasAlarm();

  /// Whether the device has vibration motor
  bool hasVibration();

  /// Whether the device supports time settings
  bool supportsTimeSettings();

  /// Whether the device supports screen settings
  bool supportsScreenSettings();

  /// Whether the device supports notification settings
  bool supportsNotificationSettings();

  /// Whether the device supports Do Not Disturb mode
  bool supportsDnd();

  /// Whether the device supports manual flight mode toggle
  /// (Slim has auto-calculated flight mode, so manual toggle is not available)
  bool supportsManualFlightMode();

  /// Whether the device supports device update
  bool supportsDeviceUpdate();

  /// Whether the device supports calibration
  bool supportsCalibration();

  /// Whether the device supports locate functionality
  bool supportsLocate();

  /// Slim RGB LED guide and CO₂ threshold settings (no screen)
  bool supportsSlimLedStatus();

  /// Factory method to create appropriate capabilities instance based on device model
  factory DeviceCapabilities.fromModel(DeviceModel model) {
    switch (model) {
      case DeviceModel.airspotScreen:
        return AirSpotScreenCapabilities();
      case DeviceModel.airspotSlim:
        return AirSpotSlimCapabilities();
      case DeviceModel.unknown:
        // Default to Screen capabilities for backward compatibility
        return AirSpotScreenCapabilities();
    }
  }
}

/// Capabilities for AirSpot Screen device
class AirSpotScreenCapabilities implements DeviceCapabilities {
  @override
  bool hasScreen() => true;

  @override
  bool hasAlarm() => true;

  @override
  bool hasVibration() => true;

  @override
  bool supportsTimeSettings() => true;

  @override
  bool supportsScreenSettings() => true;

  @override
  bool supportsNotificationSettings() => true;

  @override
  bool supportsDnd() => true;

  @override
  bool supportsManualFlightMode() => true;

  @override
  bool supportsDeviceUpdate() => true;

  @override
  bool supportsCalibration() => true;

  @override
  bool supportsLocate() => true;

  @override
  bool supportsSlimLedStatus() => false;
}

/// Capabilities for AirSpot Slim device
class AirSpotSlimCapabilities implements DeviceCapabilities {
  @override
  bool hasScreen() => false;

  @override
  bool hasAlarm() => false;

  @override
  bool hasVibration() => false;

  @override
  bool supportsTimeSettings() => false;

  @override
  bool supportsScreenSettings() => false;

  @override
  bool supportsNotificationSettings() => true;

  @override
  bool supportsDnd() => false;

  @override
  bool supportsManualFlightMode() => false; // Auto-calculated based on pressure

  @override
  bool supportsDeviceUpdate() => true; // Local signed-image qualification.

  @override
  bool supportsCalibration() => true; // Manual calibration supported (no auto-calib)

  @override
  bool supportsLocate() => false;

  @override
  bool supportsSlimLedStatus() => true;
}
