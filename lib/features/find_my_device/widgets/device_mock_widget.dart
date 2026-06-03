import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/app_utils.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/tappable_widget.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/devices/providers/device_battery_level_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DeviceMockWidget extends ConsumerWidget {
  const DeviceMockWidget({required this.device, super.key});

  final BleDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(device.deviceId));

    final dynamic co2Value =
        ref.watch(bleDeviceCommunicationProvider(device.deviceId));

    final bool isConnected =
        ref.watch(bleDeviceConnectionProvider(device.deviceId)) ==
            BluetoothBondState.bonded;

    final BatteryState batteryState =
        ref.watch(deviceBatteryLevelProvider(device.deviceId));

    return TappableWidget(
      debounceTime: 5000,
      onTap: () => ref
          .read(bleDeviceCommunicationProvider(device.deviceId).notifier)
          .sendCommand(DeviceCmdUtils.findDevice()),
      tapCount: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
              "${device.alias != null ? ('${device.alias!}/') : ''}${device.name}",
              style: context.textTheme.labelLarge?.weight600),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.airSpotBg),
                fit: BoxFit.contain,
              ),
            ),
            width: context.width * 0.5,
            height: context.height * 0.35,
            constraints: const BoxConstraints(
              maxWidth: 200,
              maxHeight: 200,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(deviceSettings, batteryState),
                const SizedBox(height: 6),
                _buildCo2Value(co2Value),
                _buildPowerModeBluetooth(deviceSettings.powerMode, isConnected),
                _buildActiveIndicator(co2Value, deviceSettings),
                _showBrandColors(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Align _buildCo2Value(dynamic co2Value) {
    final displayValue =
        co2Value != null ? AppUtils.getDisplayCO2Value(co2Value) : null;
    return Align(
      alignment: Alignment.center,
      child: Text(
        displayValue?.toString() ?? "----",
        style: TextStyle(
            color: co2Value == null
                ? Colors.white
                : AppUtils.getDataColorFromValue(co2Value),
            fontSize: 32),
        textAlign: TextAlign.center,
      ),
    );
  }

  Row _buildHeader(DeviceSettings deviceSettings, BatteryState batteryState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 8),
        Icon(
          deviceSettings.alarmEnabled ? Icons.volume_up : Icons.volume_off,
          color: Colors.white,
          size: 14,
        ),
        Icon(
          deviceSettings.vibrationEnabled ? Icons.power : Icons.power_off,
          color: Colors.white,
          size: 14,
        ),
        const Spacer(),
        Text(
          "${DateTime.now().hour.toString().padLeft(2)} : ${DateTime.now().minute.toString().padLeft(2, '0')}",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const Spacer(),
        Stack(
          children: [
            const FaIcon(
              FontAwesomeIcons.batteryEmpty,
              color: Colors.white,
              size: 16,
            ),
            !batteryState.isCharging
                ? const Positioned(
                    right: 2,
                    bottom: 4,
                    left: 2,
                    child: Icon(
                      Icons.bolt,
                      color: Colors.amberAccent,
                      size: 8,
                    ),
                  )
                : Positioned(
                    right: 1,
                    bottom: 4,
                    child: Text(
                      '${batteryState.level}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Padding _buildPowerModeBluetooth(PowerMode mode, bool isConnected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(mode.name, style: TextStyle(color: Colors.white, fontSize: 10)),
          const Spacer(),
          Text(Constants.co2Text,
              style: TextStyle(color: Colors.white, fontSize: 10)),
          const SizedBox(width: 8),
          const Text('PPM',
              style: TextStyle(color: Colors.white, fontSize: 10)),
          const Spacer(),
          Icon(
            Icons.bluetooth,
            color: isConnected ? AppColors.primaryColor : Colors.white,
            size: 12,
          ),
        ],
      ),
    );
  }

  Align _buildActiveIndicator(dynamic co2Value, DeviceSettings deviceSettings) {
    // Use display value for positioning but actual value for color logic
    final displayValue =
        co2Value != null ? AppUtils.getDisplayCO2Value(co2Value) : 0;
    return Align(
      alignment: displayValue < deviceSettings.greenUpperLimit
          ? Alignment.topLeft
          : displayValue < deviceSettings.yellowUpperLimit
              ? Alignment.topCenter
              : Alignment.topRight,
      child: const Icon(
        Icons.arrow_drop_down_sharp,
        size: 20,
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
