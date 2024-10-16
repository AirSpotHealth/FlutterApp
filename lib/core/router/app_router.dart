import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/features/app_setup/app_setup_page.dart';
import 'package:airspothealth/features/app_setup/app_updates_page.dart';
import 'package:airspothealth/features/app_setup/latest_news_page.dart';
import 'package:airspothealth/features/app_setup/privacy_policy_page.dart';
import 'package:airspothealth/features/device_graph/device_graph_page.dart';
import 'package:airspothealth/features/device_settings/device_settings_page.dart';
import 'package:airspothealth/features/device_settings/pages/co2_alert_settings_page.dart';
import 'package:airspothealth/features/device_settings/pages/co2_ppm_settings_page.dart';
import 'package:airspothealth/features/device_settings/pages/device_update_page.dart';
import 'package:airspothealth/features/device_settings/pages/powe_mode_settings_page.dart';
import 'package:airspothealth/features/device_settings/pages/recalibrate_device_page.dart';
import 'package:airspothealth/features/device_settings/pages/time_settings_page.dart';
import 'package:airspothealth/features/devices/devices_page.dart';
import 'package:airspothealth/features/find_my_device/find_my_device_page.dart';
import 'package:airspothealth/features/home/homepage.dart';
import 'package:airspothealth/features/solutions/solutions_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      // Route for HomePage
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),

      // Route for Devices List
      GoRoute(
        path: RouteNames.devices,
        name: RouteNames.devices,
        builder: (context, state) => const DevicesPage(),
        routes: [
          // Route for a specific device by ID
          GoRoute(
            path: ':deviceId',
            name: RouteNames.deviceDetails,
            builder: (context, state) {
              final deviceId = state.pathParameters['deviceId'];
              if (deviceId == null) {
                throw ErrorDescription('Device ID is required');
              }
              return DeviceSettingsPage(deviceId: deviceId);
            },
            routes: [
              // Route for device settings
              GoRoute(
                path: 'settings',
                name: RouteNames.deviceSettings,
                builder: (context, state) {
                  final deviceId = state.pathParameters['deviceId'];
                  if (deviceId == null) {
                    throw ErrorDescription('Device ID is required');
                  }
                  return DeviceSettingsPage(deviceId: deviceId);
                },
                routes: [
                  // Route for time settings within device settings
                  GoRoute(
                    path: 'time-settings',
                    name: RouteNames.timeSettings,
                    builder: (context, state) {
                      final deviceId = state.pathParameters['deviceId'];
                      if (deviceId == null) {
                        throw ErrorDescription('Device ID is required');
                      }
                      return TimeSettingsPage(deviceId: deviceId);
                    },
                  ),
                  // Route for power mode settings within device settings
                  GoRoute(
                    path: 'power-mode-settings',
                    name: RouteNames.powerModeSettings,
                    builder: (context, state) {
                      final deviceId = state.pathParameters['deviceId'];
                      if (deviceId == null) {
                        throw ErrorDescription('Device ID is required');
                      }
                      return PowerModeSettingsPage(deviceId: deviceId);
                    },
                  ),
                  // Route for co2 ppm settings within device settings
                  GoRoute(
                    path: 'ppm-settings',
                    name: RouteNames.ppmSettings,
                    builder: (context, state) {
                      final deviceId = state.pathParameters['deviceId'];
                      if (deviceId == null) {
                        throw ErrorDescription('Device ID is required');
                      }
                      return Co2PpmSettingsPage(deviceId: deviceId);
                    },
                  ),
                  // Route for CO2 alert settings within device settings
                  GoRoute(
                    path: 'co2-alert-settings',
                    name: RouteNames.co2Settings,
                    builder: (context, state) {
                      final deviceId = state.pathParameters['deviceId'];
                      if (deviceId == null) {
                        throw ErrorDescription('Device ID is required');
                      }
                      return Co2AlertSettingsPage(deviceId: deviceId);
                    },
                  ),
                  // Route for recalibrate settings within device settings
                  GoRoute(
                    path: 'recalibrate-settings',
                    name: RouteNames.recalibrateSettings,
                    builder: (context, state) {
                      final deviceId = state.pathParameters['deviceId'];
                      if (deviceId == null) {
                        throw ErrorDescription('Device ID is required');
                      }
                      return RecalibrateDevicePage(deviceId: deviceId);
                    },
                  ),
                  // Route for device update settings within device settings
                  GoRoute(
                    path: 'device-update',
                    name: RouteNames.deviceUpdate,
                    builder: (context, state) {
                      final deviceId = state.pathParameters['deviceId'];
                      if (deviceId == null) {
                        throw ErrorDescription('Device ID is required');
                      }
                      return DeviceUpdatePage(deviceId: deviceId);
                    },
                  ),
                ],
              ),
              // Route for device graph
              GoRoute(
                path: 'graph',
                name: RouteNames.deviceGraph,
                builder: (context, state) {
                  final deviceId = state.pathParameters['deviceId'];
                  if (deviceId == null) {
                    throw ErrorDescription('Device ID is required');
                  }
                  return DeviceGraphPage(deviceId: deviceId);
                },
              ),
              // Route for finding a specific device
              GoRoute(
                path: 'find-my-device',
                name: RouteNames.findMyDevice,
                builder: (context, state) {
                  final deviceId = state.pathParameters['deviceId'];
                  if (deviceId == null) {
                    throw ErrorDescription('Device ID is required');
                  }
                  return FindMyDevicePage(deviceId: deviceId);
                },
              ),
            ],
          ),
        ],
      ),

      // Other routes (app setup, privacy policy, latest news, etc.)
      GoRoute(
        name: RouteNames.appSetup,
        path: RouteNames.appSetup,
        builder: (context, state) => const AppSetupPage(),
      ),
      GoRoute(
        name: RouteNames.solutions,
        path: RouteNames.solutions,
        builder: (context, state) => const SolutionsPage(),
      ),
      GoRoute(
        name: RouteNames.appUpdates,
        path: RouteNames.appUpdates,
        builder: (context, state) => const AppUpdatesPage(),
      ),
      GoRoute(
        name: RouteNames.privacyPolicy,
        path: RouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        name: RouteNames.latestNews,
        path: RouteNames.latestNews,
        builder: (context, state) => const LatestNewsPage(),
      ),
    ],
  );
}
