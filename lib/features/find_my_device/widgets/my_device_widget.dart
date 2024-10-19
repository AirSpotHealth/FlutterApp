import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyDeviceWidget extends ConsumerWidget {
  const MyDeviceWidget({required this.device, super.key});

  final BleDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceSettings deviceSettings =
        ref.read(deviceSettingsProvider(device.deviceId));

    final dynamic co2Value =
        ref.watch(bleDeviceCommunicationProvider(device.deviceId));

    final bool isConnected =
        ref.watch(bleDeviceConnectionProvider(device.deviceId)) ==
            BluetoothBondState.bonded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.airSpotBg),
          fit: BoxFit.contain,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                deviceSettings.alarmEnabled
                    ? Icons.volume_up
                    : Icons.volume_off,
                color: Colors.white,
                size: 16,
              ),
              Text(
                "${DateTime.now().hour} : ${DateTime.now().minute}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                deviceSettings.powerMode.name.capitalize(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.center,
            child: Text(
              co2Value.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CO2',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                const Text('PPM',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
                Icon(
                  Icons.bluetooth,
                  color: isConnected ? AppColors.primaryColor : Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
          Align(
            alignment: co2Value < deviceSettings.greenUpperLimit
                ? Alignment.centerLeft
                : co2Value < deviceSettings.yellowUpperLimit
                    ? Alignment.center
                    : Alignment.centerRight,
            child: const Icon(
              Icons.arrow_drop_down_sharp,
              size: 28,
              color: Colors.white,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const SizedBox(
                  height: 8,
                  width: 24,
                  child: ColoredBox(
                    color: AppColors.brandColorGreen,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const SizedBox(
                  height: 8,
                  width: 24,
                  child: ColoredBox(
                    color: AppColors.brandColorAmber,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const SizedBox(
                  height: 8,
                  width: 24,
                  child: ColoredBox(
                    color: AppColors.brandColorRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
