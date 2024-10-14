import 'package:airspothealth/core/providers/ble_active_device_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/features/home/widgets/active_device_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BluetoothDevice? activeDevice = ref.watch(bleActiveDeviceProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const AppLogo(),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activeDevice != null)
            ListTile(
              dense: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              tileColor: Colors.white,
              title: Text(
                'Active Device',
                style: context.textTheme.labelLarge?.weight600,
              ),
              subtitle: Text(activeDevice.platformName),
              leading: const Icon(Icons.bluetooth_connected,
                  color: AppColors.primaryColor),
              trailing: const ActiveDeviceValueWidget(),
            ),
          const SizedBox(height: 16),
          ListTile(
            dense: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            tileColor: Colors.white,
            title:
                Text('Devices', style: context.textTheme.labelLarge?.weight600),
            subtitle: const Text('Manage your devices'),
            leading: Image.asset(Assets.icDevice, width: 24),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => context.pushNamed(RouteNames.devices),
          ),
        ],
      ),
    );
  }
}
