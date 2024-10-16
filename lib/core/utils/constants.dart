class Constants {
  static const String baseUrl = 'http://eyht.laodiyuncha.com/';

  // UUIDs for the service and characteristics
  static const String serviceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String notifyUuid = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String writeUuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";

  static const String greenUpperLimit = "greenThreshold";
  static const int defaultGreenUpperLimit = 800;

  static const String yellowUpperLimit = "yellowThreshold";
  static const int defaultYellowUpperLimit = 1000;

  static const int defaultco2AlertThreshold = 2000;

  static const List<int> co2PPMValues = [
    400,
    500,
    600,
    700,
    800,
    900,
    1000,
    1100,
    1200,
    1300,
    1400,
    1500,
    1600,
    1700,
    1800,
    1900,
    2000
  ];
}
