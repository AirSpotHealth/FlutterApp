import 'package:airspothealth/core/providers/bluetooth_state_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/features/add_device/providers/ble_search_results_provider.dart';
import 'package:airspothealth/features/app_setup/providers/app_version_provider.dart';
import 'package:airspothealth/features/device_settings/providers/firmware_remote_version_provider.dart';
import 'package:airspothealth/features/home/widgets/app_update_banner.dart';
import 'package:airspothealth/features/home/widgets/menu_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    _setAppGroupId();
    // NotificationService.checkNotificationPermission();
    _checkFirmwareVersion();
    _checkAppVersion();
    _scanForDevices();
    super.initState();
  }

  void _checkFirmwareVersion() {
    ref.read(firmwareRemoteVersionProvider);
  }

  void _checkAppVersion() {
    // Check for app updates
    ref.read(appVersionProvider);
  }

  void _scanForDevices() {
    // if bluetooth is on, start scanning for devices
    if (ref.read(bluetoothStateProvider) == BluetoothAdapterState.on) {
      ref.read(bluetoothSearchResultsProvider.notifier).startScan();
    }
  }

  void _setAppGroupId() => HomeWidget.setAppGroupId(Constants.appGroupId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Padding(
          padding: EdgeInsets.only(top: 12),
          child: AppLogo(testEnabled: true),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: MenuItems.items.length,
        itemBuilder: (context, index) {
          final menuItem = MenuItems.items[index];

          // Check if this is the App Setup menu item
          if (menuItem.route == RouteNames.appSetup) {
            return AppUpdateBanner(
              menuItem: menuItem,
            );
          }

          return MenuItemWidget(menuItem: menuItem);
        },
      ),
    );
  }
}
