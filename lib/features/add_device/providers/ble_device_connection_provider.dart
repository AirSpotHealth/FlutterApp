import 'dart:async';

import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/providers/ble_connected_devices_provider.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/router/app_router.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/services/ble_service.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/providers/dfu_update_provider.dart';
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

  @override
  BluetoothBondState build(String arg) {
    debugPrint('bleDeviceConnectionProvider build $arg');
    ref.onDispose(() {
      deviceSubscription?.cancel();
    });

    return _bleService
                .connectedDevices()
                .firstWhereOrNull((device) => device.remoteId.str == arg)
                ?.isConnected ==
            true
        ? BluetoothBondState.bonded
        : BluetoothBondState.none;
  }

  bool get isConnected => state == BluetoothBondState.bonded;

  bool get isConnecting => state == BluetoothBondState.bonding;

  void connect() {
    debugPrint('bleDeviceConnectionProvider connect $arg, $state');

    if (isConnected || isConnecting) return;
    debugPrint('Connecting to device: ${device.advName}');

    state = BluetoothBondState.bonding;

    deviceSubscription = device.connectionState.listen((bState) {
      debugPrint('Device connection state: $bState');

      if (bState == BluetoothConnectionState.connected) {
        if (state == BluetoothBondState.bonded) return;

        state = BluetoothBondState.bonded;
        _refreshAndAddDevice();
      } else if (bState == BluetoothConnectionState.disconnected) {
        debugPrint('Device disconnected, $state');

        if (state == BluetoothBondState.none) return;

        _checkRouteAndPop();
        state = BluetoothBondState.none;
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

    _bleService.connect(device);
  }

  void _refreshAndAddDevice() {
    ref.read(bleConnectedDevicesProvider.notifier).refresh();
    ref.read(bleSavedDevicesProvider.notifier).addDevice(BleDevice(
          deviceId: device.remoteId.str,
          name: device.advName,
          platform: device.platformName,
          address: device.remoteId.str,
        ));
  }

  Future<void> disconnect() async {
    await _bleService.disconnect(device);
    deviceSubscription?.cancel();
    state = BluetoothBondState.none;
  }

  void _checkRouteAndPop() {
    // check whether the disconnect was intitiated from the dfu update
    if (ref.read(dfuUpdateProvider) is AsyncInProgress) {
      debugPrint('DFU update in progress, not popping');
      return;
    }

    final BuildContext? context = AppRouter.navigatorKey.currentContext;

    debugPrint('Checking route and popping');

    if (context == null) return;

    final router = GoRouter.of(context);

    final path =
        router.routerDelegate.currentConfiguration.last.matchedLocation;

    debugPrint('Path: $path');

    // if the path pattern matches this /devices/FF%3A51%3A34%3A9D%3A86%3A32/settings
    // then pop the route
    // and show a snackbar that the device is disconnected
    if (RegExp(Constants.devicesPathRegex).hasMatch(path)) {
      context.showSnackBar('Device disconnected.');

      router.popUntilPath(RouteNames.devices);
    }
  }
}
