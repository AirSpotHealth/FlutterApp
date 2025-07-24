class LiveActivityModel {
  final String deviceId;
  final String deviceName;
  final int co2Value;
  final String powerMode;
  final int batteryLevel;
  final bool isCharging;
  final bool alarmEnabled;
  final bool vibrationEnabled;
  final bool isConnected;
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
    required this.isConnected,
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
      'isConnected': isConnected,
      'co2History': co2History,
      'greenUpperLimit': greenUpperLimit,
      'yellowUpperLimit': yellowUpperLimit,
      'graphMaxValue': graphMaxValue,
      'graphMinValue': graphMinValue,
    };
  }

  LiveActivityModel copyWith({
    String? deviceId,
    String? deviceName,
    int? co2Value,
    String? powerMode,
    int? batteryLevel,
    bool? isCharging,
    bool? alarmEnabled,
    bool? vibrationEnabled,
    bool? isConnected,
    List<int>? co2History,
    int? greenUpperLimit,
    int? yellowUpperLimit,
    int? graphMaxValue,
    int? graphMinValue,
  }) {
    return LiveActivityModel(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      co2Value: co2Value ?? this.co2Value,
      powerMode: powerMode ?? this.powerMode,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isCharging: isCharging ?? this.isCharging,
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      isConnected: isConnected ?? this.isConnected,
      co2History: co2History ?? this.co2History,
      greenUpperLimit: greenUpperLimit ?? this.greenUpperLimit,
      yellowUpperLimit: yellowUpperLimit ?? this.yellowUpperLimit,
      graphMaxValue: graphMaxValue ?? this.graphMaxValue,
      graphMinValue: graphMinValue ?? this.graphMinValue,
    );
  }
}
