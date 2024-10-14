import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/features/add_device/add_device_page.dart';
import 'package:airspothealth/features/device_data/device_data_page.dart';
import 'package:airspothealth/features/device_settings/device_settings_page.dart';
import 'package:airspothealth/features/devices/devices_page.dart';
import 'package:airspothealth/features/home/homepage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// AppRouter class is used to define the routes of the application.
/// App uses GoRouter package to manage the routes. Please refer to the GoRouter documentation for more information.
/// https://pub.dev/packages/go_router
class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RouteNames.devices,
        name: RouteNames.devices,
        builder: (context, state) => const DevicesPage(),
      ),
      GoRoute(
        path: RouteNames.addDevice,
        name: RouteNames.addDevice,
        builder: (context, state) => const AddDevicePage(),
      ),
      GoRoute(
        path: RouteNames.deviceSettings,
        name: RouteNames.deviceSettings,
        builder: (context, state) {
          final deviceId = state.pathParameters['deviceId'];

          if (deviceId == null) {
            throw ErrorDescription('Device ID is required');
          }

          return DeviceSettingsPage(deviceId: deviceId);
        },
      ),
      GoRoute(
        path: RouteNames.deviceData,
        name: RouteNames.deviceData,
        builder: (context, state) {
          final deviceId = state.pathParameters['deviceId'];

          if (deviceId == null) {
            throw ErrorDescription('Device ID is required');
          }

          return DeviceDataPage(deviceId: deviceId);
        },
      ),
    ],
  );
}
