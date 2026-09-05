import 'dart:async';
import 'dart:io';

import 'package:airspothealth/features/device_graph/providers/device_history_data_request_provider.dart';
import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_data.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/models/device_data_type.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/models/live_activity_model.dart';
import 'package:airspothealth/core/providers/ble_connected_devices_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/providers/notification_preferences_provider.dart';
import 'package:airspothealth/core/services/ble_communicator_service.dart';
import 'package:airspothealth/core/services/ble_data_service.dart';
import 'package:airspothealth/core/services/ble_device_communicator.dart';
import 'package:airspothealth/core/services/co2_monitoring_service.dart';
import 'package:airspothealth/core/services/data_logger_service.dart';
import 'package:airspothealth/core/services/isar_service.dart';
import 'package:airspothealth/core/services/live_activity_service.dart';
import 'package:airspothealth/core/services/widget_service.dart';
import 'package:airspothealth/core/services/zone_analysis_service.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/utils/local_date_format.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/features/app_setup/providers/dev_mode_provider.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/features/device_settings/providers/sensor_configuration_provider.dart';
import 'package:airspothealth/features/device_settings/providers/sensor_error_provider.dart';
import 'package:airspothealth/features/devices/providers/device_battery_level_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

final bleDeviceCommunicationProvider =
    NotifierProvider.family<_BleDeviceCommunicationNotifier, dynamic, String>(
  _BleDeviceCommunicationNotifier.new,
);

class _BleDeviceCommunicationNotifier extends FamilyNotifier<dynamic, String> {
  final IsarService _isarService = IsarService();

  late BleDeviceCommunicator _communicator;

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

    // Set up refresh callbacks based on platform
    if (Platform.isIOS) {
      _setupLiveActivityRefreshCallback();
    } else if (Platform.isAndroid) {
      _setupWidgetRefreshCallback();
    }

    // Set up unified dismissal callback for both platforms
    _setupUnifiedDismissalCallback();

    ref.onDispose(() {
      _notifySubscription?.cancel();
      // Clear refresh callbacks when this provider is disposed
      LiveActivityService().clearDeviceRefreshCallback(deviceId);
      // Clear dismissal callbacks when this provider is disposed
      LiveActivityService().clearDeviceDismissalCallback(deviceId);
    });
    return lastValue;
  }

  void _setupLiveActivityRefreshCallback() {
    LiveActivityService().setDeviceRefreshCallback(deviceId, () {
      debugPrint('Live Activity refresh triggered for device: $deviceId');
      _handleLiveActivityRefresh();
    });
  }

  void _setupUnifiedDismissalCallback() {
    LiveActivityService().setDeviceDismissalCallback(deviceId,
        (String dismissedDeviceId) {
      debugPrint(
          'Live Activity/Notification dismissed for device: $dismissedDeviceId');
      _handleUnifiedDismissal(dismissedDeviceId);
    });
  }

  void _handleUnifiedDismissal(String dismissedDeviceId) {
    debugPrint(
        'Handling unified dismissal for device: $dismissedDeviceId, disabling setting');

    try {
      // Update the device settings to disable live activity
      final currentSettings =
          ref.read(deviceSettingsProvider(dismissedDeviceId));
      ref
          .read(deviceSettingsProvider(dismissedDeviceId).notifier)
          .updateSettings(
            currentSettings.copyWith(showLiveActivity: false),
            sendCommands: false, // Don't send BLE commands for this setting
          );

      debugPrint(
          'Live Activity setting disabled for device: $dismissedDeviceId');
    } catch (e) {
      debugPrint(
          'Error disabling live activity setting for device $dismissedDeviceId: $e');
    }
  }

  void _handleLiveActivityRefresh() {
    // Request fresh CO2 data from the device
    debugPrint('Requesting fresh CO2 data for Live Activity refresh');

    if (device == null || device!.isConnected == false) {
      debugPrint('Device not connected, cannot refresh CO2 data');
      return;
    }

    // Send CO2 request command to get fresh data
    sendCommand(DeviceCmdUtils.refreshCO2()).then((success) {
      if (success) {
        debugPrint('CO2 refresh command sent successfully');
      } else {
        debugPrint('Failed to send CO2 refresh command');
      }
    });
  }

  void _setupWidgetRefreshCallback() {
    // Use unified LiveActivityService for both widget and notification refresh
    LiveActivityService().setDeviceRefreshCallback(deviceId, () {
      debugPrint('Unified refresh triggered for device: $deviceId');
      _handleWidgetRefresh();
    });
  }

  void _handleWidgetRefresh() {
    // Request fresh CO2 data from the device
    debugPrint('Requesting fresh CO2 data for Widget refresh');

    if (device == null || device!.isConnected == false) {
      debugPrint('Device not connected, cannot refresh CO2 data');
      return;
    }

    // Send CO2 request command to get fresh data
    sendCommand(DeviceCmdUtils.refreshCO2()).then((success) {
      if (success) {
        debugPrint('CO2 refresh command sent successfully');
      } else {
        debugPrint('Failed to send CO2 refresh command');
      }
    });
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

  Future<bool>? _connectionSetup;

  Future<bool> setConnected() {
    if (_communicator.isSuspended) return Future.value(false);
    return _connectionSetup ??= _initializeConnection().whenComplete(() {
      _connectionSetup = null;
    });
  }

  Future<bool> _initializeConnection() async {
    _communicator.reset();
    if (!await _communicator.initialize()) {
      debugPrint('BLE GATT setup failed for $deviceId');
      return false;
    }
    _updateDeviceModel();
    await _getInitialData();
    ref
        .read(deviceHistoryDataRequestProvider(deviceId).notifier)
        .resumeAfterUpdate();
    return true;
  }

  void _updateDeviceModel() {
    final saved = ref.read(bleSavedDevicesProvider.notifier).getDeviceById(arg);
    // Slim is identified from scan-response SMP UUID; without MCUmgr GATT we must
    // not downgrade a known Slim to Screen on reconnect.
    if (saved?.deviceModel == DeviceModel.airspotSlim) {
      return;
    }
    if (_communicator.isSlimDevice) {
      ref
          .read(bleSavedDevicesProvider.notifier)
          .updateDeviceModel(arg, DeviceModel.airspotSlim);
      debugPrint('Device $arg model set to ${DeviceModel.airspotSlim}');
      return;
    }
    if (saved?.deviceModel == null) {
      ref
          .read(bleSavedDevicesProvider.notifier)
          .updateDeviceModel(arg, DeviceModel.airspotScreen);
      debugPrint('Device $arg model set to ${DeviceModel.airspotScreen}');
    }
  }

  void _handleNotificationData(List<int> data) async {
    debugPrint(
        'Data received: $deviceId, ${BleDataService.bytesToHexStr(data)}');

    _checkIfLogData(data, DateTime.now());

    final BleDevice device = ref.read(bleDeviceProvider(deviceId));
    final dynamic co2Data =
        BleDataService.parseResponseCommand(ref, device, data);

    if (co2Data is DeviceData) {
      // Check if this is a sensor error (CO2 = 0xFFFF)
      if (co2Data.type == DeviceDataType.sensorError.index) {
        debugPrint('Sensor error detected for device: $deviceId');

        // Extract error info from the original data if available (11-byte format)
        int errorCode = co2Data.value;
        int recoveryAttempts = 0;

        // If we have the full 11-byte response, extract recovery attempts from byte 5
        if (data.length >= 11) {
          recoveryAttempts = data[5];
        }

        // Update sensor error provider
        ref.read(sensorErrorProvider(deviceId).notifier).setError(
              errorCode: errorCode,
              recoveryAttempts: recoveryAttempts,
            );

        // Set state to null to indicate error (UI will show "----")
        state = null;

        // Store error in database for diagnostics
        if (co2Data.isLiveCo2) {
          _isarService.write((isar) {
            isar.deviceDatas.put(co2Data);
          });
        }
        return;
      }

      // Normal CO2 reading - clear any previous error
      ref.read(sensorErrorProvider(deviceId).notifier).clearError();

      state = co2Data.value == 0 ? null : co2Data.value;

      // Store data in database FIRST (before calculating zone analysis)
      if (co2Data.isLiveCo2) {
        _isarService.write((isar) {
          isar.deviceDatas.put(co2Data);
        });
        // Note: Zone cache will be invalidated automatically when data count changes
      }

      // Update home widget with new CO2 value (after data is stored)
      setHomeValue(co2Data);
    }
  }

  Future<void> setHomeValue(DeviceData co2Data) async {
    debugPrint(
        'BLE: FRESH CO2 DATA RECEIVED: ${co2Data.value} - Delegating to LiveActivityService for unified update');

    try {
      // 1. Get device name (prefer alias over advertised name)
      // Read directly from Isar to ensure we get the latest alias
      BleDevice? bleDevice;
      try {
        // First try to read from Isar directly to get the latest alias
        bleDevice = _isarService.read<BleDevice?>((isar) {
          return isar.bleDevices.where().deviceIdEqualTo(deviceId).findFirst();
        });

        // If not found in Isar, try the provider as fallback
        bleDevice ??= ref.read(bleDeviceProvider(deviceId));
      } catch (e) {
        debugPrint('BLE: Error reading device: $e');
        bleDevice = null;
      }

      String deviceName = 'AirSpot Device';

      // Prefer alias if it exists and is not empty
      if (bleDevice?.alias != null && bleDevice!.alias!.isNotEmpty) {
        deviceName = bleDevice.alias!;
        debugPrint('BLE: Using alias for device name: $deviceName');
      }
      // Fall back to advertised name if available
      else if (device?.advName.isNotEmpty == true) {
        deviceName = device!.advName;
        debugPrint('BLE: Using advertised name for device name: $deviceName');
      }
      // Fall back to device name if available
      else if (bleDevice?.name.isNotEmpty == true) {
        deviceName = bleDevice!.name;
        debugPrint('BLE: Using device name for device name: $deviceName');
      } else {
        debugPrint('BLE: Using default device name: $deviceName');
      }

      // 2. Get device settings
      DeviceSettings? deviceSettings;
      try {
        deviceSettings = IsarService().read<DeviceSettings?>((isar) {
          return isar.deviceSettings
              .where()
              .deviceIdEqualTo(deviceId)
              .findFirst();
        });
      } catch (e) {
        debugPrint('BLE: Could not read device settings: $e');
      }

      // 3. Get battery info
      String batteryLevel = '0';
      bool isCharging = false;
      try {
        final batteryState = ref.read(deviceBatteryLevelProvider(deviceId));
        batteryLevel = batteryState.level?.toString() ?? '0';
        isCharging = batteryState.isCharging;
      } catch (e) {
        debugPrint('BLE: Could not read battery state: $e');
      }

      // 4. Get historical CO2 data
      final historicalData = _isarService.read<List<int>>((isar) {
        final co2DataList = isar.deviceDatas
            .where()
            .deviceIdEqualTo(deviceId)
            .typeEqualTo(DeviceDataType.co2.index)
            .sortByDateTimeDesc()
            .findAll(limit: 39);
        return co2DataList.map((e) => e.value).toList().reversed.toList();
      });

      // 5. Include current value as the latest
      final co2History = [...historicalData, co2Data.value];

      // 6. Check CO2 levels and trigger notifications if needed
      try {
        final notificationPrefs =
            ref.read(notificationPreferencesProvider(deviceId));
        final updatedPrefs = await Co2MonitoringService.checkAndNotify(
          deviceId: deviceId,
          deviceName: deviceName,
          co2Value: co2Data.value,
          preferences: notificationPrefs,
        );

        // Update preferences if they were modified (e.g., triggered thresholds changed)
        if (updatedPrefs != null) {
          debugPrint(
              'BLE Provider - Updating preferences with triggered thresholds: ${updatedPrefs.triggeredThresholds}');
          ref
              .read(notificationPreferencesProvider(deviceId).notifier)
              .updatePreferences((_) => updatedPrefs);
        }

        // Update last notification time if needed
        if (notificationPrefs.smartphoneNotificationsEnabled) {
          // This will be handled by the monitoring service
        }
      } catch (e) {
        debugPrint('BLE: Error checking CO2 notifications: $e');
      }

      // 7. Update LiveActivityService (for Live Activity notifications)
      await LiveActivityService().updateWithCO2Data(
        deviceId: deviceId,
        co2Value: co2Data.value.toString(),
        deviceName: deviceName,
        deviceSettings: deviceSettings,
        batteryLevel: batteryLevel,
        isCharging: isCharging,
        isConnected: device?.isConnected ?? false,
        co2History: co2History,
      );

      // 8. Update WidgetService (for home screen widgets) - INDEPENDENT
      final widgetData = await _buildLiveActivityModel(
        deviceId: deviceId,
        deviceName: deviceName,
        co2Value: co2Data.value,
        deviceSettings: deviceSettings,
        batteryLevel: batteryLevel,
        isCharging: isCharging,
        isConnected: device?.isConnected ?? false,
        co2History: co2History,
      );

      await WidgetService().updateWidgetData(
        deviceId: deviceId,
        data: widgetData,
      );
    } catch (e) {
      debugPrint('BLE: Error updating services: $e');
    }
  }

  /// Helper method to build LiveActivityModel with zone calculations
  Future<LiveActivityModel> _buildLiveActivityModel({
    required String deviceId,
    required String deviceName,
    required int co2Value,
    required DeviceSettings? deviceSettings,
    required String batteryLevel,
    required bool isCharging,
    required bool isConnected,
    required List<int> co2History,
  }) async {
    final displayCO2Value = co2Value < 400 ? 400 : co2Value;
    final displayCO2History =
        co2History.map((value) => value < 400 ? 400 : value).toList();

    // Calculate zone percentages for today (same as LiveActivityService)
    final zoneAnalysisService = ZoneAnalysisService();
    final zoneResult = await zoneAnalysisService.calculateZonePercentages(
      deviceId: deviceId,
      greenUpperLimit: deviceSettings?.thresholds.greenUpperLimit ?? 800,
      yellowUpperLimit: deviceSettings?.thresholds.yellowUpperLimit ?? 1000,
    );

    return LiveActivityModel(
      deviceId: deviceId,
      deviceName: deviceName,
      co2Value: displayCO2Value,
      powerMode: deviceSettings?.powerMode.name ?? 'Now',
      batteryLevel: int.parse(batteryLevel),
      isCharging: isCharging,
      isConnected: isConnected,
      alarmEnabled: deviceSettings?.alarmEnabled ?? false,
      vibrationEnabled: deviceSettings?.vibrationEnabled ?? false,
      co2History: displayCO2History,
      greenUpperLimit: deviceSettings?.thresholds.greenUpperLimit ?? 800,
      yellowUpperLimit: deviceSettings?.thresholds.yellowUpperLimit ?? 1000,
      graphMaxValue: deviceSettings?.graphMaxValue ?? 1600,
      graphMinValue: deviceSettings?.graphMinValue ?? 0,
      isRefreshing: false,
      greenZonePercentage: zoneResult.greenZonePercentage,
      yellowZonePercentage: zoneResult.yellowZonePercentage,
      redZonePercentage: zoneResult.redZonePercentage,
      dominantZone: zoneResult.dominantZone,
      dominantZonePercentage: zoneResult.dominantZonePercentage,
    );
  }

  Future<void> _getInitialData() async {
    final DeviceSettings? deviceSettings =
        ref.read(deviceSettingsProvider(deviceId));

    final commands = [
      if (deviceSettings?.autoSyncTime == true) DeviceCmdUtils.setTime(),
      DeviceCmdUtils.getBatteryLevel(),
      DeviceCmdUtils.getCO2(),
      DeviceCmdUtils.getInitialData(),
      DeviceCmdUtils.getFirmVersion(),
      DeviceCmdUtils.getAlias(),
    ];

    for (final command in commands) {
      await sendCommand(command);
    }

    ref.read(sensorConfigurationProvider(deviceId));
  }

  Future<bool> sendCommand(List<int> data) async {
    if (_communicator.isSuspended) return false;
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
