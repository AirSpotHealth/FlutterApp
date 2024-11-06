import 'dart:typed_data';

import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
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
  final DeviceThresholds thresholds;

  /// The device id
  @Id()
  final String deviceId;

  /// Whether the high CO2 alarm is enabled or not
  final int? co2AlertThreshold;

  /// auto sync time
  final bool autoSyncTime;

  /// auto calibration
  final bool autoCalibration;

  /// auto connect
  final bool autoConnect;

  /// log data bool
  final bool logData;

  DeviceSettings({
    required this.alarmEnabled,
    required this.vibrationEnabled,
    required this.powerMode,
    required this.continuosScreenEnabled,
    required this.thresholds,
    required this.deviceId,
    required this.co2AlertThreshold,
    this.autoSyncTime = true,
    this.autoCalibration = true,
    this.autoConnect = true,
    this.logData = false,
  });

  DeviceSettings.empty({required this.deviceId})
      : alarmEnabled = false,
        vibrationEnabled = false,
        powerMode = PowerMode.low,
        continuosScreenEnabled = false,
        thresholds = DeviceThresholds.empty(),
        co2AlertThreshold = null,
        autoSyncTime = true,
        autoCalibration = true,
        autoConnect = true,
        logData = false;

  DeviceSettings copyWith({
    bool? alarmEnabled,
    bool? vibrationEnabled,
    PowerMode? powerMode,
    bool? continuosScreenEnabled,
    DeviceThresholds? thresholds,
    String? version,
    String? deviceId,
    int? co2AlertThreshold,
    bool? autoSyncTime,
    bool? autoCalibration,
    bool? autoConnect,
    bool? logData,
  }) {
    return DeviceSettings(
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      powerMode: powerMode ?? this.powerMode,
      continuosScreenEnabled:
          continuosScreenEnabled ?? this.continuosScreenEnabled,
      thresholds: thresholds ?? this.thresholds,
      deviceId: deviceId ?? this.deviceId,
      co2AlertThreshold: co2AlertThreshold ?? this.co2AlertThreshold,
      autoSyncTime: autoSyncTime ?? this.autoSyncTime,
      autoCalibration: autoCalibration ?? this.autoCalibration,
      autoConnect: autoConnect ?? this.autoConnect,
      logData: logData ?? this.logData,
    );
  }

  @ignore
  bool get isLowPowerMode => powerMode == PowerMode.low;

  @ignore
  bool get isMediumPowerMode => powerMode == PowerMode.medium;

  @ignore
  bool get isHighPowerMode => powerMode == PowerMode.high;

  @ignore
  int get greenUpperLimit => thresholds.greenUpperLimit;

  @ignore
  int get yellowUpperLimit => thresholds.yellowUpperLimit;

  set greenUpperLimit(int value) {
    thresholds.copyWith(greenUpperLimit: value);
  }

  set yellowUpperLimit(int value) {
    thresholds.copyWith(yellowUpperLimit: value);
  }

  @ignore
  Uint8List get powerModeCmd => powerMode._deviceCmd;

  @ignore
  Uint8List get alarmCmd =>
      alarmEnabled ? DeviceCmdUtils.openAlarm() : DeviceCmdUtils.closeAlarm();

  @ignore
  Uint8List get vibrationCmd => vibrationEnabled
      ? DeviceCmdUtils.openVibration()
      : DeviceCmdUtils.closeVibration();

  @ignore
  Uint8List get co2Cmd => DeviceCmdUtils.getCO2();

  @ignore
  Uint8List get firmVersionCmd => DeviceCmdUtils.getFirmVersion();

  @ignore
  Uint8List get continuousScreenCmd => continuosScreenEnabled
      ? DeviceCmdUtils.keepDeviceLight()
      : DeviceCmdUtils.closeDeviceLight();

  @ignore
  Uint8List get autoSyncTimeCmd => DeviceCmdUtils.setTime();

  @ignore
  Uint8List get thresholdsCmd =>
      DeviceCmdUtils.setCo2PPM(greenUpperLimit, yellowUpperLimit);

  @ignore
  Uint8List get autoCalibrationCmd => autoCalibration
      ? DeviceCmdUtils.setCalibrationAuto()
      : DeviceCmdUtils.setCalibrationManual();

  Map<String, dynamic> toJson() {
    return {
      'alarmEnabled': alarmEnabled,
      'vibrationEnabled': vibrationEnabled,
      'powerMode': powerMode.index,
      'continuosScreenEnabled': continuosScreenEnabled,
      'thresholds': thresholds.toMap(),
      'deviceId': deviceId,
      'co2AlertThreshold': co2AlertThreshold,
      'autoSyncTime': autoSyncTime,
      'autoCalibration': autoCalibration,
      'autoConnect': autoConnect,
      'logData': logData,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceSettings &&
        other.alarmEnabled == alarmEnabled &&
        other.vibrationEnabled == vibrationEnabled &&
        other.powerMode == powerMode &&
        other.continuosScreenEnabled == continuosScreenEnabled &&
        other.thresholds == thresholds &&
        other.deviceId == deviceId &&
        other.co2AlertThreshold == co2AlertThreshold &&
        other.autoSyncTime == autoSyncTime &&
        other.autoCalibration == autoCalibration &&
        other.autoConnect == autoConnect &&
        other.logData == logData;
  }

  @override
  int get hashCode =>
      alarmEnabled.hashCode ^
      vibrationEnabled.hashCode ^
      powerMode.hashCode ^
      continuosScreenEnabled.hashCode ^
      thresholds.hashCode ^
      deviceId.hashCode ^
      co2AlertThreshold.hashCode ^
      autoSyncTime.hashCode ^
      autoCalibration.hashCode ^
      autoConnect.hashCode ^
      logData.hashCode;

  @override
  String toString() {
    return 'DeviceSettings(alarmEnabled: $alarmEnabled, vibrationEnabled: $vibrationEnabled, powerMode: $powerMode, continuosScreenEnabled: $continuosScreenEnabled, thresholds: $thresholds, deviceId: $deviceId, co2AlertThreshold: $co2AlertThreshold, autoSyncTime: $autoSyncTime, autoCalibration: $autoCalibration, autoConnect: $autoConnect, logData: $logData)';
  }
}

@Embedded(ignore: {'copyWith'})
class DeviceThresholds {
  final int greenUpperLimit;
  final int yellowUpperLimit;

  DeviceThresholds({
    required this.greenUpperLimit,
    required this.yellowUpperLimit,
  });

  DeviceThresholds.empty()
      : greenUpperLimit = Constants.defaultGreenUpperLimit,
        yellowUpperLimit = Constants.defaultYellowUpperLimit;

  DeviceThresholds copyWith({
    int? greenUpperLimit,
    int? yellowUpperLimit,
  }) {
    return DeviceThresholds(
      greenUpperLimit: greenUpperLimit ?? this.greenUpperLimit,
      yellowUpperLimit: yellowUpperLimit ?? this.yellowUpperLimit,
    );
  }

  Map<String, int> toMap() {
    return {
      Constants.greenUpperLimit: greenUpperLimit,
      Constants.yellowUpperLimit: yellowUpperLimit,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceThresholds &&
        other.greenUpperLimit == greenUpperLimit &&
        other.yellowUpperLimit == yellowUpperLimit;
  }

  @override
  @ignore
  int get hashCode => greenUpperLimit.hashCode ^ yellowUpperLimit.hashCode;

  DeviceThresholds.fromJson(Map<String, dynamic> json)
      : greenUpperLimit = json[Constants.greenUpperLimit],
        yellowUpperLimit = json[Constants.yellowUpperLimit];

  Map<String, dynamic> toJson() {
    return {
      Constants.greenUpperLimit: greenUpperLimit,
      Constants.yellowUpperLimit: yellowUpperLimit,
    };
  }

  @override
  String toString() {
    return 'DeviceThresholds(greenUpperLimit: $greenUpperLimit, yellowUpperLimit: $yellowUpperLimit)';
  }
}

enum PowerMode {
  low,
  medium,
  high;

  Uint8List get _deviceCmd {
    switch (this) {
      case PowerMode.low:
        return DeviceCmdUtils.setPowerLow();
      case PowerMode.medium:
        return DeviceCmdUtils.setPowerMed();
      case PowerMode.high:
        return DeviceCmdUtils.setPowerHi();
    }
  }

  static PowerMode fromValue(int value) {
    switch (value) {
      case 0:
        return PowerMode.low;
      case 1:
        return PowerMode.medium;
      case 2:
        return PowerMode.high;
      default:
        return PowerMode.low;
    }
  }
}
