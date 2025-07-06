class LiveActivityModel {
  final int co2Value;
  final String powerMode;
  final int batteryLevel;
  final bool alarmEnabled;
  final bool vibrationEnabled;

  LiveActivityModel({
    required this.co2Value,
    required this.powerMode,
    required this.batteryLevel,
    required this.alarmEnabled,
    required this.vibrationEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'co2Value': co2Value,
      'powerMode': powerMode,
      'batteryLevel': batteryLevel,
      'alarmEnabled': alarmEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }
}
