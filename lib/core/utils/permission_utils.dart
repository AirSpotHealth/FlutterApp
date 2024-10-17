import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static const _permissionList = [
    Permission.locationWhenInUse,
    Permission.bluetoothConnect,
    Permission.bluetoothScan
  ];
  static Future<bool> requestPermissions() async {
    final statuses = await _permissionList.request();

    if (statuses.containsValue(PermissionStatus.denied)) {
      return false;
    }

    return true;
  }

  static Future<bool> checkPermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }
}
