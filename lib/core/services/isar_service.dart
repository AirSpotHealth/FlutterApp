import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/models/notification_preferences.dart';
import 'package:isar_plus/isar_plus.dart';
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
      schemas: [
        BleDeviceSchema,
        DeviceDataSchema,
        DeviceSettingsSchema,
        NotificationPreferencesSchema,
      ],
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

  /// read async method
  Future<T> readAsync<T>(T Function(Isar isar) fn) async {
    return await _isar.readAsync((isar) {
      return fn(isar);
    });
  }

  /// write method
  void write(void Function(Isar isar) fn) {
    _isar.write((isar) {
      fn(isar);
    });
  }

  /// write async method
  /// write async method
  Future<void> writeAsync(void Function(Isar isar) fn) async {
    await _isar.writeAsync((isar) {
      fn(isar);
    });
  }

  /// clear all data
  void clearAllData() {
    _isar.write((isar) {
      isar.clear();
    });
  }

  /// expose the schemas
  IsarCollection<String, BleDevice> get bleDevices => _isar.bleDevices;
  IsarCollection<String, DeviceData> get deviceDatas => _isar.deviceDatas;
  IsarCollection<String, DeviceSettings> get deviceSettings =>
      _isar.deviceSettings;
}
