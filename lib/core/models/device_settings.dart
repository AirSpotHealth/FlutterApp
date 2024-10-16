import 'package:airspothealth/core/utils/constants.dart';
import 'package:isar/isar.dart';

part 'device_settings.g.dart';

@Collection(ignore: {'copyWith'})
class DeviceSettings {
  /// Whether the alarm is enabled or not
  final bool alarmEnabled;

  /// Whether the vibration is enabled or not
  final bool vibrationEnabled;

  /// The power mode of the device
  @enumValue
  final PowerMode powerMode;

  /// Whether the continuous screen is enabled or not
  final bool continuosScreenEnabled;

  /// The thresholds for the device
  final Map<String, dynamic> thresholds;

  /// The firmware version of the device
  final String version;

  /// The device id
  @Id()
  final String deviceId;

  /// Whether the high CO2 alarm is enabled or not
  final int? co2AlertThreshold;

  /// auto sync time
  final bool autoSyncTime;

  DeviceSettings({
    required this.alarmEnabled,
    required this.vibrationEnabled,
    required this.powerMode,
    required this.continuosScreenEnabled,
    required this.thresholds,
    required this.version,
    required this.deviceId,
    required this.co2AlertThreshold,
    this.autoSyncTime = true,
  });

  DeviceSettings.empty({required this.deviceId})
      : alarmEnabled = false,
        vibrationEnabled = false,
        powerMode = PowerMode.low,
        continuosScreenEnabled = false,
        thresholds = const {
          Constants.greenUpperLimit: Constants.defaultGreenUpperLimit,
          Constants.yellowUpperLimit: Constants.defaultYellowUpperLimit,
        },
        version = '',
        co2AlertThreshold = null,
        autoSyncTime = true;

  DeviceSettings copyWith({
    bool? alarmEnabled,
    bool? vibrationEnabled,
    PowerMode? powerMode,
    bool? continuosScreenEnabled,
    Map<String, int>? thresholds,
    String? version,
    String? deviceId,
    int? co2AlertThreshold,
    bool? autoSyncTime,
  }) {
    return DeviceSettings(
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      powerMode: powerMode ?? this.powerMode,
      continuosScreenEnabled:
          continuosScreenEnabled ?? this.continuosScreenEnabled,
      thresholds: thresholds ?? this.thresholds,
      version: version ?? this.version,
      deviceId: deviceId ?? this.deviceId,
      co2AlertThreshold: co2AlertThreshold ?? this.co2AlertThreshold,
      autoSyncTime: autoSyncTime ?? this.autoSyncTime,
    );
  }

  @ignore
  bool get isLowPowerMode => powerMode == PowerMode.low;

  @ignore
  bool get isMediumPowerMode => powerMode == PowerMode.medium;

  @ignore
  bool get isHighPowerMode => powerMode == PowerMode.high;

  @ignore
  int get greenUpperLimit => thresholds[Constants.greenUpperLimit];

  @ignore
  int get yellowUpperLimit => thresholds[Constants.yellowUpperLimit];
}

enum PowerMode { low, medium, high }
