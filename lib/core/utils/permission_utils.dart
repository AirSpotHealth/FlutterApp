import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static final _permissionList = Platform.isIOS
      ? [Permission.locationWhenInUse, Permission.bluetooth]
      : [
          Permission.locationWhenInUse,
          Permission.bluetoothConnect,
          Permission.bluetoothScan
        ];

  static Future<String?> requestPermissions() async {
    final statuses = await _permissionList.request();

    debugPrint('statuses: $statuses');

    // check each permission status is denied or permanently denied
    // if permantly denied then show dialog to open settings
    // get the name of the permanently denied permissions and show them in the dialog
    final deniedPermissions = statuses.entries
        .where((entry) =>
            entry.value == PermissionStatus.denied ||
            entry.value == PermissionStatus.permanentlyDenied)
        .map((entry) => entry.key)
        .toList();

    return deniedPermissions.isNotEmpty
        ? deniedPermissions
            .map((permission) => _permissionNames[permission])
            .toSet()
            .join(', ')
        : null;
  }

  static Future<bool> checkPermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  static final _permissionNames = {
    Permission.bluetoothConnect: 'Bluetooth',
    Permission.bluetoothScan: 'Bluetooth',
    Permission.bluetooth: 'Bluetooth',
    Permission.locationWhenInUse: 'Location',
    Permission.locationAlways: 'Location',
  };
}
