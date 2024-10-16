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
  final bool highCo2AlarmEnabled;

  DeviceSettings({
    required this.alarmEnabled,
    required this.vibrationEnabled,
    required this.powerMode,
    required this.continuosScreenEnabled,
    required this.thresholds,
    required this.version,
    required this.deviceId,
    required this.highCo2AlarmEnabled,
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
        highCo2AlarmEnabled = false;

  DeviceSettings copyWith({
    bool? alarmEnabled,
    bool? vibrationEnabled,
    PowerMode? powerMode,
    bool? continuosScreenEnabled,
    Map<String, int>? thresholds,
    String? version,
    String? deviceId,
    bool? highCo2AlarmEnabled,
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
      highCo2AlarmEnabled: highCo2AlarmEnabled ?? this.highCo2AlarmEnabled,
    );
  }
}

enum PowerMode { low, medium, high }
