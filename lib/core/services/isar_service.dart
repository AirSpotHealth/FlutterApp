import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

/// A service class for interacting with the Isar database.
class IsarService {
  /// Creates a new instance of [IsarService].
  factory IsarService() => _instance;

  IsarService._();

  /// Singleton instance of [IsarService].
  static final IsarService _instance = IsarService._();

  late final Isar _isar;

  /// Initializes the Isar instance.
  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = Isar.open(
      schemas: [BleDeviceSchema, DeviceDataSchema],
      directory: dir.path,
    );
  }

  /// Closes the Isar instance.
  void close() {
    _isar.close();
  }

  /// read method
  T read<T>(T Function(Isar isar) fn) {
    return _isar.read((isar) {
      return fn(isar);
    });
  }

  /// write method
  void write(void Function(Isar isar) fn) {
    _isar.write((isar) {
      fn(isar);
    });
  }

  /// expose the schemas
  IsarCollection<String, BleDevice> get bleDevices => _isar.bleDevices;
  IsarCollection<String, DeviceData> get deviceDatas => _isar.deviceDatas;
}
