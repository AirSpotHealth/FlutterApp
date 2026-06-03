import 'dart:async';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_connected_devices_provider.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/router/app_router.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/services/ble_service.dart';
import 'package:airspothealth/core/services/live_activity_service.dart';
import 'package:airspothealth/core/services/widget_service.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/dfu_update_provider.dart';
import 'package:airspothealth/features/devices/providers/device_battery_level_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final bleDeviceConnectionProvider = NotifierProvider.family<
    _BleDeviceConnectionNotifier,
    BluetoothBondState,
    String>(_BleDeviceConnectionNotifier.new);

class _BleDeviceConnectionNotifier
    extends FamilyNotifier<BluetoothBondState, String> {
  final BLEService _bleService = BLEService.instance;

  BluetoothDevice get device => BluetoothDevice.fromId(arg);

  StreamSubscription<BluetoothConnectionState>? deviceSubscription;
  Timer? _connectTimeout;
  bool _connectInFlight = false;
  bool _connectedThisAttempt = false;

  @override
  BluetoothBondState build(String arg) {
    ref.onDispose(() {
      _connectTimeout?.cancel();
      deviceSubscription?.cancel();
    });

    final alreadyConnected = _bleService
            .connectedDevices()
            .firstWhereOrNull((device) => device.remoteId.str == arg)
            ?.isConnected ==
        true;

    if (alreadyConnected) {
      // Device was connected before this provider was built (auto-connect).
      // Run model detection now so the UI reflects the correct device type.
      Future.microtask(() => ref
          .read(bleDeviceCommunicationProvider(arg).notifier)
          .setConnected());
      return BluetoothBondState.bonded;
    }

    return BluetoothBondState.none;
  }

  bool get isConnected => state == BluetoothBondState.bonded;

  bool get isConnecting => state == BluetoothBondState.bonding;

  /// User tapped Connect — use a direct GATT connection (not background autoConnect).
  void connect() => _startConnect(useBackgroundAutoConnect: false);

  /// App-level reconnect when Bluetooth turns on (background autoConnect).
  void connectBackground() => _startConnect(useBackgroundAutoConnect: true);

  void _startConnect({required bool useBackgroundAutoConnect}) {
    if (isConnected || isConnecting || _connectInFlight) {
      debugPrint(
          'Connect skipped for $arg: state=$state inFlight=$_connectInFlight');
      return;
    }

    _connectedThisAttempt = false;
    _connectInFlight = true;
    state = BluetoothBondState.bonding;

    final label = device.advName.isNotEmpty
        ? device.advName
        : (device.platformName.isNotEmpty
            ? device.platformName
            : device.remoteId.str);
    debugPrint(
        'Connecting to device: $label (${device.remoteId.str}), background=$useBackgroundAutoConnect');

    deviceSubscription?.cancel();
    deviceSubscription = device.connectionState.listen((bState) {
      debugPrint('Device connection state ($arg): $bState');

      if (bState == BluetoothConnectionState.connected) {
        _onConnected();
      } else if (bState == BluetoothConnectionState.disconnected) {
        _onDisconnected();
      }
    });

    if (!ref.read(deviceSettingsProvider(arg)).autoConnect &&
        deviceSubscription != null) {
      device.cancelWhenDisconnected(
        deviceSubscription!,
        delayed: true,
        next: true,
      );
    }

    _connectTimeout?.cancel();
    _connectTimeout = Timer(const Duration(seconds: 35), () {
      if (state == BluetoothBondState.bonding) {
        debugPrint('Connect timed out for $arg');
        _resetConnectionAttempt();
      }
    });

    final connectFuture = useBackgroundAutoConnect
        ? _bleService.connectBackground(device)
        : _bleService.connectDirect(device);

    connectFuture.whenComplete(() {
      _connectInFlight = false;
    }).catchError((Object e) {
      debugPrint('Connect failed for $arg: $e');
      if (state == BluetoothBondState.bonding) {
        _resetConnectionAttempt();
      }
    });
  }

  void _onConnected() {
    _connectTimeout?.cancel();
    _connectedThisAttempt = true;

    if (state == BluetoothBondState.bonded) {
      return;
    }

    _refreshAndAddDevice();
    _handleDeviceReconnection();
    state = BluetoothBondState.bonded;
    ref.read(bleDeviceCommunicationProvider(arg).notifier).setConnected();
  }

  void _onDisconnected() {
    if (state == BluetoothBondState.none) {
      return;
    }

    // connectionState emits disconnected as its initial value. Ignore that
    // while bonding until we have connected at least once this attempt.
    if (state == BluetoothBondState.bonding && !_connectedThisAttempt) {
      return;
    }

    if (state == BluetoothBondState.bonding) {
      _resetConnectionAttempt();
      return;
    }

    debugPrint(
        'Device disconnected, updating Live Activity with disconnected state');
    // Preserve the low-battery lockout flag across the disconnect so the UI can
    // explain *why* the device dropped (it is protecting a near-empty cell and
    // will reconnect once charged) instead of showing a generic error. The flag
    // clears on reconnect when a fresh battery-level frame arrives.
    final bool lowBatteryLockout =
        ref.read(deviceBatteryLevelProvider(arg)).lowBatteryLockout;
    ref.read(deviceBatteryLevelProvider(arg).notifier).updateBatteryLevel(
          BatteryState(null, false, lowBatteryLockout: lowBatteryLockout),
        );
    _updateLiveActivityOnDisconnect();
    _checkRouteAndPop(lowBatteryLockout);
    state = BluetoothBondState.none;
  }

  void _resetConnectionAttempt() {
    _connectTimeout?.cancel();
    _connectInFlight = false;
    _connectedThisAttempt = false;
    state = BluetoothBondState.none;
  }

  void _refreshAndAddDevice() {
    ref.read(bleConnectedDevicesProvider.notifier).refresh();

    final deviceModel = _bleService.deviceModelFromScan(device.remoteId.str);
    ref.read(bleSavedDevicesProvider.notifier).addDevice(BleDevice(
          deviceId: device.remoteId.str,
          name: device.advName.isNotEmpty
              ? device.advName
              : device.platformName,
          platform: device.platformName,
          address: device.remoteId.str,
          deviceModelValue: deviceModel?.index,
        ));

    WidgetService().refreshDeviceList();
  }

  Future<void> disconnect() async {
    _connectTimeout?.cancel();
    _connectInFlight = false;
    await _bleService.disconnect(device);
    deviceSubscription?.cancel();
    state = BluetoothBondState.none;
  }

  void _checkRouteAndPop([bool lowBatteryLockout = false]) {
    if (ref.read(dfuUpdateProvider) is AsyncInProgress) {
      return;
    }

    final BuildContext? context = AppRouter.navigatorKey.currentContext;

    if (context == null) return;

    final router = GoRouter.of(context);

    final path = router.routerDelegate.currentConfiguration.last.matchedLocation
        .replaceAll(
      RegExp(r'%3A'),
      ':',
    );

    debugPrint('Current path: ${path.replaceAll("%3A", ":")}');

    if (path.contains(device.remoteId.str) &&
        RegExp(r'^\/devices\/[A-Za-z0-9:%_-]+(?:\/[A-Za-z0-9:%_-]+)*$')
            .hasMatch(path)) {
      context.showSnackBar(lowBatteryLockout
          ? 'Low battery — device is charging. It will reconnect '
              'automatically once charged.'
          : 'Device disconnected.');

      router.popUntilPath(RouteNames.devices);
    }
  }

  void _updateLiveActivityOnDisconnect() async {
    try {
      await LiveActivityService().updateWithDisconnectedState(
        deviceId: arg,
      );

      final widgetData = WidgetService().getWidgetData(arg);
      if (widgetData != null) {
        await WidgetService().updateWidgetData(
          deviceId: arg,
          data: widgetData.copyWith(
            isConnected: false,
            isRefreshing: false,
          ),
        );
        debugPrint('✅ Widget updated with disconnected state for: $arg');
      }
    } catch (e) {
      debugPrint('Error updating live activity/widget on disconnect: $e');
    }
  }

  void _handleDeviceReconnection() async {
    try {
      debugPrint(
          'Device reconnected: $arg - Live Activity will restart automatically with fresh data');

      final widgetData = WidgetService().getWidgetData(arg);
      if (widgetData != null) {
        await WidgetService().updateWidgetData(
          deviceId: arg,
          data: widgetData.copyWith(
            isConnected: true,
            isRefreshing: false,
          ),
        );
        debugPrint('✅ Widget updated with reconnected state for: $arg');
      }
    } catch (e) {
      debugPrint('Error handling device reconnection: $e');
    }
  }
}
