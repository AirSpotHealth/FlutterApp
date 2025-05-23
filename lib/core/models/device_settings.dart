import 'dart:typed_data';

import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/device_settings/widgets/device_ui_mode_widget.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'device_settings.g.dart';

@Collection(ignore: {'copyWith'})
class DeviceSettings {
  /// Whether the alarm is enabled or not
  final bool alarmEnabled;

  /// Whether the vibration is enabled or not
  final bool vibrationEnabled;

  /// The power mode of the device
  @EnumValue()
  final PowerMode powerMode;

  /// Whether the continuous screen is enabled or not
  final bool continuosScreenEnabled;

  /// The thresholds for the device
  final DeviceThresholds thresholds;

  /// The device id
  @Id()
  final String deviceId;

  /// The med alert boolean
  final bool co2MedAlertEnabled;

  /// The high alert boolean
  final bool co2HighAlertEnabled;

  /// auto sync time
  final bool autoSyncTime;

  /// auto calibration
  final bool autoCalibration;

  /// auto connect
  final bool autoConnect;

  /// log data bool
  final bool logData;

  /// Dnd enabled bool
  final bool dndEnabled;

  /// Dnd start time
  final DateTime? dndStartTime;

  /// Dnd end time
  final DateTime? dndEndTime;

  /// Recalibration target
  final int recalibrationTarget;

  /// Graph max value
  final int graphMaxValue;

  /// Graph min value
  final int graphMinValue;

  /// UI Mode
  @EnumValue()
  final UIMode uiMode;

  /// Show rebreathe percentage
  final bool showRebreathePercentage;

  /// Advanced alarm settings
  final bool screenOnAlarm;
  final bool alarmOnCo2Fall;
  final List<AlarmLevel> alarmLevels;

  /// Scaling factor
  final double scaling;

  const DeviceSettings({
    required this.alarmEnabled,
    required this.vibrationEnabled,
    required this.powerMode,
    required this.continuosScreenEnabled,
    required this.thresholds,
    required this.deviceId,
    this.co2MedAlertEnabled = false,
    this.co2HighAlertEnabled = false,
    this.autoSyncTime = true,
    this.autoCalibration = false,
    this.autoConnect = true,
    this.logData = false,
    this.dndEnabled = false,
    this.dndStartTime,
    this.dndEndTime,
    this.recalibrationTarget = 426,
    this.graphMaxValue = 1600,
    this.uiMode = UIMode.graph,
    this.showRebreathePercentage = false,
    this.graphMinValue = 0,
    this.screenOnAlarm = true,
    this.alarmOnCo2Fall = false,
    this.alarmLevels = defaultAlarmLevels,
    this.scaling = 1.0,
  });

  DeviceSettings.empty({required this.deviceId})
      : alarmEnabled = false,
        vibrationEnabled = false,
        powerMode = PowerMode.onDemand,
        continuosScreenEnabled = false,
        thresholds = DeviceThresholds.empty(),
        co2MedAlertEnabled = false,
        co2HighAlertEnabled = false,
        autoSyncTime = true,
        autoCalibration = true,
        autoConnect = true,
        logData = false,
        dndEnabled = false,
        dndStartTime = null,
        dndEndTime = null,
        recalibrationTarget = 426,
        graphMaxValue = 1600,
        uiMode = UIMode.graph,
        showRebreathePercentage = false,
        graphMinValue = 0,
        screenOnAlarm = true,
        alarmOnCo2Fall = false,
        alarmLevels = defaultAlarmLevels,
        scaling = 1.0;

  DeviceSettings copyWith({
    bool? alarmEnabled,
    bool? vibrationEnabled,
    PowerMode? powerMode,
    bool? continuosScreenEnabled,
    DeviceThresholds? thresholds,
    String? version,
    String? deviceId,
    bool? co2MedAlertEnabled,
    bool? co2HighAlertEnabled,
    bool? autoSyncTime,
    bool? autoCalibration,
    bool? autoConnect,
    bool? logData,
    bool? dndEnabled,
    DateTime? dndStartTime,
    DateTime? dndEndTime,
    int? recalibrationTarget,
    int? graphMaxValue,
    int? graphMinValue,
    UIMode? uiMode,
    bool? showRebreathePercentage,
    bool? screenOnAlarm,
    bool? alarmOnCo2Fall,
    List<AlarmLevel>? alarmLevels,
    double? scaling,
  }) {
    return DeviceSettings(
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      powerMode: powerMode ?? this.powerMode,
      continuosScreenEnabled:
          continuosScreenEnabled ?? this.continuosScreenEnabled,
      thresholds: thresholds ?? this.thresholds,
      deviceId: deviceId ?? this.deviceId,
      co2MedAlertEnabled: co2MedAlertEnabled ?? this.co2MedAlertEnabled,
      co2HighAlertEnabled: co2HighAlertEnabled ?? this.co2HighAlertEnabled,
      autoSyncTime: autoSyncTime ?? this.autoSyncTime,
      autoCalibration: autoCalibration ?? this.autoCalibration,
      autoConnect: autoConnect ?? this.autoConnect,
      logData: logData ?? this.logData,
      dndEnabled: dndEnabled ?? this.dndEnabled,
      dndStartTime: dndStartTime ?? this.dndStartTime,
      dndEndTime: dndEndTime ?? this.dndEndTime,
      recalibrationTarget: recalibrationTarget ?? this.recalibrationTarget,
      graphMaxValue: graphMaxValue ?? this.graphMaxValue,
      uiMode: uiMode ?? this.uiMode,
      showRebreathePercentage:
          showRebreathePercentage ?? this.showRebreathePercentage,
      graphMinValue: graphMinValue ?? this.graphMinValue,
      screenOnAlarm: screenOnAlarm ?? this.screenOnAlarm,
      alarmOnCo2Fall: alarmOnCo2Fall ?? this.alarmOnCo2Fall,
      alarmLevels: alarmLevels ?? this.alarmLevels,
      scaling: scaling ?? this.scaling,
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
      ? DeviceCmdUtils.setScreenOnContinuously()
      : DeviceCmdUtils.resetScreenOnContinuously();

  @ignore
  Uint8List get autoSyncTimeCmd => DeviceCmdUtils.setTime();

  @ignore
  Uint8List get thresholdsCmd =>
      DeviceCmdUtils.setGraphThreshold(greenUpperLimit, yellowUpperLimit);

  @ignore
  Uint8List get autoCalibrationCmd => autoCalibration
      ? DeviceCmdUtils.setCalibrationAuto()
      : DeviceCmdUtils.setCalibrationManual();

  Color getValueColor(dynamic value) {
    if (value == null) {
      return AppColors.brandColorGreen;
    }

    if (value >= 0 && value < greenUpperLimit) {
      return AppColors.brandColorGreen;
    } else if (value >= greenUpperLimit && value < yellowUpperLimit) {
      return AppColors.brandColorAmber;
    } else {
      return AppColors.brandColorRed;
    }
  }

  @ignore
  Uint8List get dndCmd => dndEnabled
      ? DeviceCmdUtils.setDND(dndStartTime, dndEndTime)
      : DeviceCmdUtils.resetDND();

  @ignore
  DateTime get defaultDndStartTime =>
      DateTime.now().copyWith(hour: 22, minute: 0);

  @ignore
  DateTime get defaultDndEndTime => DateTime.now().copyWith(hour: 6, minute: 0);

  Map<String, dynamic> toJson() {
    return {
      'alarmEnabled': alarmEnabled,
      'vibrationEnabled': vibrationEnabled,
      'powerMode': powerMode.index,
      'continuosScreenEnabled': continuosScreenEnabled,
      'thresholds': thresholds.toMap(),
      'deviceId': deviceId,
      'co2MedAlertEnabled': co2MedAlertEnabled,
      'co2HighAlertEnabled': co2HighAlertEnabled,
      'autoSyncTime': autoSyncTime,
      'autoCalibration': autoCalibration,
      'autoConnect': autoConnect,
      'logData': logData,
      'dndEnabled': dndEnabled,
      'dndStartTime': dndStartTime,
      'dndEndTime': dndEndTime,
      'recalibrationTarget': recalibrationTarget,
      'graphMaxValue': graphMaxValue,
      'uiMode': uiMode.index,
      'showRebreathePercentage': showRebreathePercentage,
      'graphMinValue': graphMinValue,
      'scaling': scaling,
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
        other.co2MedAlertEnabled == co2MedAlertEnabled &&
        other.co2HighAlertEnabled == co2HighAlertEnabled &&
        other.autoSyncTime == autoSyncTime &&
        other.autoCalibration == autoCalibration &&
        other.autoConnect == autoConnect &&
        other.logData == logData &&
        other.dndEnabled == dndEnabled &&
        other.dndStartTime == dndStartTime &&
        other.dndEndTime == dndEndTime &&
        other.recalibrationTarget == recalibrationTarget &&
        other.graphMaxValue == graphMaxValue &&
        other.uiMode == uiMode &&
        other.showRebreathePercentage == showRebreathePercentage &&
        other.screenOnAlarm == screenOnAlarm &&
        other.alarmOnCo2Fall == alarmOnCo2Fall &&
        other.alarmLevels == alarmLevels &&
        other.graphMinValue == graphMinValue &&
        other.scaling == scaling;
  }

  @override
  int get hashCode =>
      alarmEnabled.hashCode ^
      vibrationEnabled.hashCode ^
      powerMode.hashCode ^
      continuosScreenEnabled.hashCode ^
      thresholds.hashCode ^
      deviceId.hashCode ^
      co2MedAlertEnabled.hashCode ^
      co2HighAlertEnabled.hashCode ^
      autoSyncTime.hashCode ^
      autoCalibration.hashCode ^
      autoConnect.hashCode ^
      logData.hashCode ^
      dndEnabled.hashCode ^
      dndStartTime.hashCode ^
      dndEndTime.hashCode ^
      recalibrationTarget.hashCode ^
      graphMaxValue.hashCode ^
      uiMode.hashCode ^
      showRebreathePercentage.hashCode ^
      screenOnAlarm.hashCode ^
      alarmOnCo2Fall.hashCode ^
      alarmLevels.hashCode ^
      graphMinValue.hashCode ^
      scaling.hashCode;

  @override
  String toString() {
    return 'DeviceSettings(alarmEnabled: $alarmEnabled, vibrationEnabled: $vibrationEnabled, powerMode: $powerMode, continuosScreenEnabled: $continuosScreenEnabled, thresholds: $thresholds, deviceId: $deviceId, co2MedAlertEnabled: $co2MedAlertEnabled, co2HighAlertEnabled: $co2HighAlertEnabled, autoSyncTime: $autoSyncTime, autoCalibration: $autoCalibration, autoConnect: $autoConnect, logData: $logData, dndEnabled: $dndEnabled, dndStartTime: $dndStartTime, dndEndTime: $dndEndTime, recalibrationTarget: $recalibrationTarget, graphMaxValue: $graphMaxValue, uiMode: $uiMode, showRebreathePercentage: $showRebreathePercentage, graphMinValue: $graphMinValue, screenOnAlarm: $screenOnAlarm, alarmOnCo2Fall: $alarmOnCo2Fall, alarmLevels: $alarmLevels, scaling: $scaling)';
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
  onDemand,
  low,
  medium,
  high;

  String get name {
    switch (this) {
      case PowerMode.onDemand:
        return 'Now';
      case PowerMode.low:
        return '3 Min';
      case PowerMode.medium:
        return '1 Min';
      case PowerMode.high:
        return '5 Sec';
    }
  }

  Uint8List get _deviceCmd {
    switch (this) {
      case PowerMode.onDemand:
        return DeviceCmdUtils.setPowerOnDemand();
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
        return PowerMode.onDemand;
      case 1:
        return PowerMode.low;
      case 2:
        return PowerMode.medium;
      case 3:
        return PowerMode.high;
      default:
        return PowerMode.onDemand;
    }
  }

  String get assetIcon {
    switch (this) {
      case PowerMode.onDemand:
        return Assets.powerModeOnDemand;
      case PowerMode.low:
        return Assets.powerMode3min;
      case PowerMode.medium:
        return Assets.powerMode1min;
      case PowerMode.high:
        return Assets.powerMode5sec;
    }
  }
}

@Embedded(ignore: {'copyWith'})
class AlarmLevel {
  final int
      id; // For UI list key or an actual ID if MAX_ALARM_LEVELS is not fixed
  final int co2Threshold;
  final int repeatCount;
  final bool enabled;

  const AlarmLevel({
    required this.id,
    required this.co2Threshold,
    required this.repeatCount,
    required this.enabled,
  });

  AlarmLevel copyWith({
    int? id,
    int? co2Threshold,
    int? repeatCount,
    bool? enabled,
  }) {
    return AlarmLevel(
      id: id ?? this.id,
      co2Threshold: co2Threshold ?? this.co2Threshold,
      repeatCount: repeatCount ?? this.repeatCount,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmLevel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          co2Threshold == other.co2Threshold &&
          repeatCount == other.repeatCount &&
          enabled == other.enabled;

  @override
  int get hashCode =>
      id.hashCode ^
      co2Threshold.hashCode ^
      repeatCount.hashCode ^
      enabled.hashCode;

  // It might be useful to have a factory for default/empty alarm levels
  factory AlarmLevel.empty(int id) {
    return AlarmLevel(
      id: id,
      co2Threshold: 0,
      repeatCount: 0,
      enabled: false,
    );
  }

  // Factory for default alarm levels as per the C code
  factory AlarmLevel.defaultLevel(int id, int co2, int repeats, bool enabled) {
    return AlarmLevel(
      id: id,
      co2Threshold: co2,
      repeatCount: repeats,
      enabled: enabled,
    );
  }
}

const defaultAlarmLevels = [
  AlarmLevel(id: 0, co2Threshold: 800, repeatCount: 1, enabled: true),
  AlarmLevel(id: 1, co2Threshold: 1000, repeatCount: 2, enabled: true),
  AlarmLevel(id: 2, co2Threshold: 1200, repeatCount: 3, enabled: true),
  AlarmLevel(id: 3, co2Threshold: 1500, repeatCount: 5, enabled: true),
  AlarmLevel(id: 4, co2Threshold: 0, repeatCount: 0, enabled: false),
  AlarmLevel(id: 5, co2Threshold: 0, repeatCount: 0, enabled: false),
  AlarmLevel(id: 6, co2Threshold: 0, repeatCount: 0, enabled: false),
  AlarmLevel(id: 7, co2Threshold: 0, repeatCount: 0, enabled: false),
  AlarmLevel(id: 8, co2Threshold: 0, repeatCount: 0, enabled: false),
  AlarmLevel(id: 9, co2Threshold: 0, repeatCount: 0, enabled: false),
];
