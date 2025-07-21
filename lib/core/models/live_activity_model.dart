class LiveActivityModel {
  final String deviceId;
  final String deviceName;
  final int co2Value;
  final String powerMode;
  final int batteryLevel;
  final bool isCharging;
  final bool alarmEnabled;
  final bool vibrationEnabled;
  final List<int> co2History;
  final int greenUpperLimit;
  final int yellowUpperLimit;
  final int graphMaxValue;
  final int graphMinValue;

  LiveActivityModel({
    required this.deviceId,
    required this.deviceName,
    required this.co2Value,
    required this.powerMode,
    required this.batteryLevel,
    required this.isCharging,
    required this.alarmEnabled,
    required this.vibrationEnabled,
    required this.co2History,
    required this.greenUpperLimit,
    required this.yellowUpperLimit,
    required this.graphMaxValue,
    required this.graphMinValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'co2Value': co2Value,
      'powerMode': powerMode,
      'batteryLevel': batteryLevel,
      'isCharging': isCharging,
      'alarmEnabled': alarmEnabled,
      'vibrationEnabled': vibrationEnabled,
      'co2History': co2History,
      'greenUpperLimit': greenUpperLimit,
      'yellowUpperLimit': yellowUpperLimit,
      'graphMaxValue': graphMaxValue,
      'graphMinValue': graphMinValue,
    };
  }
}
