import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/tappable_widget.dart';
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

    return LayoutBuilder(builder: (_, constraints) {
      return TappableWidget(
        onTap: () => ref
            .read(bleDeviceCommunicationProvider(device.deviceId).notifier)
            .sendCommand(DeviceCmdUtils.findDevice()),
        tapCount: 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(device.alias ?? device.name,
                style: context.textTheme.labelLarge?.weight600),
            const SizedBox(height: 4),
            Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight * 0.86,
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
                  _buildHeader(deviceSettings),
                  const SizedBox(height: 6),
                  _buildCo2Value(co2Value),
                  _buildBluetooth(isConnected),
                  _buildActiveIndicator(co2Value, deviceSettings),
                  _showBrandColors(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Align _buildCo2Value(co2Value) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        co2Value.toString(),
        style: const TextStyle(color: Colors.white, fontSize: 24),
        textAlign: TextAlign.center,
      ),
    );
  }

  Row _buildHeader(DeviceSettings deviceSettings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(
          deviceSettings.alarmEnabled ? Icons.volume_up : Icons.volume_off,
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
    );
  }

  Padding _buildBluetooth(bool isConnected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('CO2',
              style: TextStyle(color: Colors.white, fontSize: 10)),
          const Text('PPM',
              style: TextStyle(color: Colors.white, fontSize: 10)),
          Icon(
            Icons.bluetooth,
            color: isConnected ? AppColors.primaryColor : Colors.white,
            size: 12,
          ),
        ],
      ),
    );
  }

  Align _buildActiveIndicator(co2Value, DeviceSettings deviceSettings) {
    return Align(
      alignment: co2Value < deviceSettings.greenUpperLimit
          ? Alignment.centerLeft
          : co2Value < deviceSettings.yellowUpperLimit
              ? Alignment.center
              : Alignment.centerRight,
      child: const Icon(
        Icons.arrow_drop_down_sharp,
        size: 24,
        color: Colors.white,
      ),
    );
  }

  Row _showBrandColors() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}
