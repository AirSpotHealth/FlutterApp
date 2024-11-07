class LogData {
  final String deviceId;
  dynamic value;
  DateTime dateTime;
  bool sent;

  LogData({
    required this.deviceId,
    required this.value,
    required this.dateTime,
    required this.sent,
  });
}
