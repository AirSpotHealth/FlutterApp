import 'dart:async';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_connected_devices_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/services/ble_communicator_service.dart';
import 'package:airspothealth/core/services/ble_data_service.dart';
import 'package:airspothealth/core/services/ble_device_communicator.dart';
import 'package:airspothealth/core/services/data_logger_service.dart';
import 'package:airspothealth/core/services/home_widget_service.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/utils/local_date_format.dart';
import 'package:airspothealth/features/app_setup/providers/dev_mode_provider.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/devices/providers/device_battery_level_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:isar/isar.dart';

final bleDeviceCommunicationProvider =
    NotifierProvider.family<_BleDeviceCommunicationNotifier, dynamic, String>(
  _BleDeviceCommunicationNotifier.new,
);

class _BleDeviceCommunicationNotifier extends FamilyNotifier<dynamic, String> {
  final IsarService _isarService = IsarService();

  late final BleDeviceCommunicator _communicator;

  BluetoothDevice? get device => ref
      .read(bleConnectedDevicesProvider)
      .firstWhereOrNull((device) => device.remoteId.str == arg);

  String get deviceId => arg;

  int notifySubscriptionRetryCount = 0;

  StreamSubscription<List<int>>? _notifySubscription;

  @override
  dynamic build(String arg) {
    final dynamic lastValue = _getLastStoredValue(arg);

    _communicator = BleCommunicatorService.instance.communicator(arg);
    _notifySubscription?.cancel();
    _notifySubscription =
        _communicator.dataStream.listen(_handleNotificationData);

    ref.onDispose(() {
      _notifySubscription?.cancel();
    });
    return lastValue;
  }

  dynamic _getLastStoredValue(String deviceId) {
    return _isarService.read<dynamic>((isar) {
      final deviceData = isar.deviceDatas
          .where()
          .deviceIdEqualTo(deviceId)
          .typeEqualTo(DeviceDataType.co2.index)
          .sortByDateTimeDesc()
          .findFirst();

      return deviceData?.value;
    });
  }

  void setConnected() {
    _communicator.reset();
    _communicator.initialize().then((_) {
      _getInitialData();
    });
  }

  void _handleNotificationData(List<int> data) {
    debugPrint(
        'Data received: $deviceId, ${BleDataService.bytesToHexStr(data)}');

    _checkIfLogData(data, DateTime.now());

    final BleDevice device = ref.read(bleDeviceProvider(deviceId));
    final dynamic co2Data =
        BleDataService.parseResponseCommand(ref, device, data);

    if (co2Data is DeviceData) {
      state = co2Data.value == 0 ? null : co2Data.value;

      // Update home widget with new CO2 value
      setHomeValue(co2Data);

      if (co2Data.isLiveCo2) {
        _isarService.write((isar) {
          isar.deviceDatas.put(co2Data);
        });
      }
    }
  }

  void setHomeValue(DeviceData co2Data) {
    debugPrint(
        'BLE: FRESH CO2 DATA RECEIVED: ${co2Data.value} - Updating widget with all data');

    try {
      // 1. We have the fresh CO2 value
      final String co2Value = co2Data.value.toString();

      // 2. Get device name
      final String deviceName = device?.advName ?? 'AirSpot Device';

      // 3. Get device settings (power mode, alarms, etc.)
      String powerMode = 'Now';
      bool alarmEnabled = false;
      bool vibrationEnabled = false;

      try {
        final deviceSettings = ref.read(deviceSettingsProvider(deviceId));
        powerMode = deviceSettings.powerMode.name;
        alarmEnabled = deviceSettings.alarmEnabled;
        vibrationEnabled = deviceSettings.vibrationEnabled;
      } catch (e) {
        debugPrint('BLE: Could not read device settings: $e');
      }

      // 4. Get battery info
      String batteryLevel = '0';
      bool isCharging = false;

      try {
        final batteryState = ref.read(deviceBatteryLevelProvider(deviceId));
        batteryLevel = batteryState.level?.toString() ?? '0';
        isCharging = batteryState.isCharging;
      } catch (e) {
        debugPrint('BLE: Could not read battery state: $e');
      }

      // 5. Create complete widget data
      final widgetData = WidgetUpdateData(
        deviceId: deviceId,
        co2Value: co2Value,
        deviceName: deviceName,
        powerMode: powerMode,
        batteryLevel: batteryLevel,
        isCharging: isCharging,
        alarmEnabled: alarmEnabled,
        vibrationEnabled: vibrationEnabled,
      );

      // 6. Call service to update home widget with all data
      debugPrint(
          'BLE: Updating widget with: CO2=$co2Value, Device=$deviceName, PowerMode=$powerMode, Battery=$batteryLevel');
      HomeWidgetService.instance.updateHomeWidget(data: widgetData);
    } catch (e) {
      debugPrint('BLE: Error gathering widget data: $e');
      // Fallback to basic CO2 update
      HomeWidget.saveWidgetData(
          Constants.homeWidgetKey, co2Data.value.toString());
      HomeWidget.updateWidget(
        iOSName: Constants.iOSWidgetName,
        androidName: Constants.androidWidgetName,
      );
    }
  }

  Future<void> _getInitialData() async {
    final DeviceSettings? deviceSettings =
        ref.read(deviceSettingsProvider(deviceId));

    final commands = [
      if (deviceSettings?.autoSyncTime == true) DeviceCmdUtils.setTime(),
      DeviceCmdUtils.getCO2(),
      DeviceCmdUtils.getInitialData(),
      DeviceCmdUtils.getFirmVersion(),
      DeviceCmdUtils.getAlias(),
      DeviceCmdUtils.getBatteryLevel(),
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

    final bool success = await _communicator.sendCommand(data);
    final DateTime dateTime = DateTime.now();

    if (success) {
      debugPrint(
          'Current date time: ${LocalDateFormat.instance.systemDateFormat.format(dateTime)} ${LocalDateFormat.instance.systemTimeFormat.format(dateTime)}');
      _checkIfLogData(data, dateTime, sent: true, st: true);
    } else {
      DataLoggerService().logData(
        deviceId: device?.advName ?? deviceId,
        value: BleDataService.bytesToHexStr(data),
        dateTime: dateTime,
        sent: true,
      );
    }
    return success;
  }

  void _checkIfLogData(dynamic value, DateTime dateTime,
      {bool sent = false, bool st = false}) {
    final bool? devMode = ref.read(devModeProvider);

    if (devMode == true) {
      DataLoggerService().logData(
        deviceId: deviceId,
        value: BleDataService.bytesToHexStr(value),
        dateTime: dateTime,
        sent: sent,
        st: st,
      );
    }
  }
}
