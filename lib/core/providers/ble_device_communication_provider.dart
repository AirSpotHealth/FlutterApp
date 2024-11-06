import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_connected_devices_provider.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/services/data_logger_service.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/ble_data_utils.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_settings/providers/recalibration_time_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

final bleDeviceCommunicationProvider =
    NotifierProvider.family<_BleDeviceCommunicationNotifier, dynamic, String>(
  _BleDeviceCommunicationNotifier.new,
);

class _BleDeviceCommunicationNotifier extends FamilyNotifier<dynamic, String> {
  BluetoothCharacteristic? _writeCharacteristic;
  final IsarService _isarService = IsarService();

  BluetoothDevice? get device => ref
      .read(bleConnectedDevicesProvider)
      .firstWhereOrNull((device) => device.remoteId.str == arg);

  String get deviceId => arg;

  @override
  dynamic build(String arg) {
    final dynamic lastValue = _getLastStoredValue(arg);

    if (device?.isConnected == true) {
      setConnected();
    }
    return lastValue;
  }

  dynamic _getLastStoredValue(String deviceId) {
    return _isarService.read<dynamic>((isar) {
      final deviceData = isar.deviceDatas
          .where()
          .deviceIdEqualTo(deviceId)
          .sortByDateTimeDesc()
          .findFirst();

      return deviceData?.value;
    });
  }

  void setConnected() {
    _resetCharacteristics();
    startListeningToNotifications();
  }

  void setDisconnected() {
    state = false;
    _resetCharacteristics();
  }

  void _resetCharacteristics() => _writeCharacteristic = null;

  Future<void> startListeningToNotifications() async {
    if (device == null || device!.isConnected == false) {
      debugPrint('Device not found or not connected');
      return;
    }

    try {
      final BluetoothService? service =
          await _findService(device!, Constants.serviceUuid);
      if (service == null) {
        debugPrint('Service not found');
        return;
      }

      await _subscribeToCharacteristic(
        service,
        Constants.notifyUuid,
      );

      _writeCharacteristic = _findCharacteristic(service, Constants.writeUuid);

      await _getInitialData();
    } catch (e) {
      debugPrint('Error starting notification stream: $e');
    }
  }

  Future<BluetoothService?> _findService(
      BluetoothDevice device, String serviceUuid) async {
    final services = await device.discoverServices();
    return services.firstWhereOrNull(
        (service) => service.uuid.toString().toUpperCase() == serviceUuid);
  }

  BluetoothCharacteristic? _findCharacteristic(
      BluetoothService service, String characteristicUuid) {
    return service.characteristics.firstWhereOrNull(
      (char) => char.uuid.toString().toUpperCase() == characteristicUuid,
    );
  }

  Future<void> _subscribeToCharacteristic(
      BluetoothService service, String notifyUuid) async {
    final notifyCharacteristic = _findCharacteristic(service, notifyUuid);
    if (notifyCharacteristic == null) {
      debugPrint('Notify characteristic not found');
      return;
    }

    await notifyCharacteristic.setNotifyValue(true);
    final notificationStream = notifyCharacteristic.lastValueStream;

    notificationStream.listen((data) {
      _handleNotificationData(data);
    });
  }

  void _handleNotificationData(List<int> data) {
    debugPrint('Data received: $deviceId, ${BleDataUtils.bytesToHexStr(data)}');
    final dynamic value = BleDataUtils.parseResponseCommand(deviceId, data);

    if (value == null) return;

    if (data[2] == ResponseCommand.firmwareVersion.value) {
      ref.read(bleSavedDevicesProvider.notifier).reloadDevices();
      ref.invalidate(bleDeviceProvider(deviceId));
      return;
    }

    if (data[2] == ResponseCommand.initialData.value) {
      debugPrint('Initial data invalidating');
      ref.invalidate(deviceSettingsProvider(deviceId));
      return;
    }

    if (data[2] == ResponseCommand.recalibrationTime.value) {
      ref
          .read(recalibrationTimeProvider(deviceId).notifier)
          .setRecalibrationTime(value);
      return;
    }

    // Recalibration done confirmation
    // value is 0x02 for start confirmation and 0x03 for end confirmation
    if (data[2] == ResponseCommand.recalibrationConfirm.value &&
        value == 0x03) {
      ref
          .read(recalibrationTimeProvider(deviceId).notifier)
          // set recalibration time to -1 to indicate that the recalibration is done
          .setRecalibrationTime(-1);
      return;
    }

    // _setHomeValue(value);

    try {
      final DateTime dateTime = DateTime.now();

      debugPrint('Saving data for: $deviceId,  $value, $dateTime');

      _isarService.write((isar) {
        isar.deviceDatas.put(DeviceData(
          deviceId: deviceId,
          value: value,
          dateTime: dateTime,
        ));
      });

      _checkIfLogData(data, dateTime);
    } catch (e) {
      debugPrint('Error saving data: $e');
    }

    state = value;
  }

  // void _setHomeValue(dynamic value) {
  //   HomeWidget.saveWidgetData(Constants.homeWidgetKey, value.toString());
  //   HomeWidget.updateWidget(
  //     iOSName: Constants.iOSWidgetName,
  //     androidName: Constants.androidWidgetName,
  //   );
  // }

  Future<void> _getInitialData() async {
    final DeviceSettings? deviceSettings =
        ref.read(deviceSettingsProvider(deviceId));

    final commands = [
      if (deviceSettings?.autoSyncTime == true) DeviceCmdUtils.setTime(),
      DeviceCmdUtils.getCO2(),
      DeviceCmdUtils.getInitialData(),
      DeviceCmdUtils.getFirmVersion(),
      DeviceCmdUtils.getAlias(),
    ];

    for (final command in commands) {
      await sendCommand(command);
    }
  }

  Future<bool> sendCommand(List<int> data) async {
    if (device == null || device!.isConnected == false) {
      debugPrint('Device not found or not connected');
      return false;
    }

    if (_writeCharacteristic == null) {
      debugPrint('Write characteristic not found');
      return false;
    }

    try {
      await _writeCharacteristic!.write(data);
      debugPrint('Command sent: ${BleDataUtils.bytesToHexStr(data)}');
      return true;
    } catch (e) {
      ref.read(bleDeviceConnectionProvider(deviceId).notifier).disconnect();
      return false;
    }
  }

  void _checkIfLogData(dynamic value, DateTime dateTime) {
    final DeviceSettings? deviceSettings =
        ref.read(deviceSettingsProvider(deviceId));

    debugPrint('Log data: ${deviceSettings?.logData}');

    if (deviceSettings?.logData == true) {
      DataLoggerService().logData(
        deviceId: deviceId,
        value: BleDataUtils.bytesToHexStr(value),
        dateTime: dateTime,
      );
    }
  }
}
