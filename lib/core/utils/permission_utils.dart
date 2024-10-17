import 'package:airspothealth/core/services/ble_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static const _permissionList = [
    Permission.locationWhenInUse,
    Permission.bluetoothConnect,
    Permission.bluetoothScan
  ];
  static void requestPermissions() {
    _permissionList.request().then((statuses) {
      if (statuses.containsValue(PermissionStatus.denied)) {
        debugPrint('Permissions denied');
      }

      if (statuses.values
          .every((element) => element == PermissionStatus.granted)) {
        BLEService.instance.enable().then((_) {
          debugPrint('Bluetooth enabled');
          BLEService.instance.startScan();
        });
      }
    });
  }

  static Future<bool> checkPermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }
}
