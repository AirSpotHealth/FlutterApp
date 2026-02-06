import 'package:airspothealth/core/models/ble_device.dart';
import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/features/add_device/providers/ble_device_connection_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_card.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ActionsSection extends ConsumerWidget {
  final String deviceId;
  final DeviceSettings settings;
  final BleDevice device;
  final bool isConnected;

  const ActionsSection({
    required this.deviceId,
    required this.settings,
    required this.device,
    required this.isConnected,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'ACTIONS',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        SettingsCard(
          children: [
            SettingsTile(
              assetPath: Assets.flightMode,
              iconBgColor: AppColors.brandColorAmber.withValues(alpha: 0.1),
              title: 'Flight Mode',
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Flight Mode'),
                          content: const Text(
                              'In Flight mode, Bluetooth will be turned off. You will not be able to connect to the device until you plug it in to charge.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Learn more',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch.adaptive(
                    value: settings.flightMode,
                    activeThumbColor: AppColors.primaryColor,
                    onChanged: (value) {
                      if (!_checkConnection(context, isConnected)) return;
                      ref
                          .read(deviceSettingsProvider(deviceId).notifier)
                          .updateSettings(settings.copyWith(flightMode: value));
                    },
                  ),
                ],
              ),
            ),
            SettingsTile(
              assetPath: Assets.disconnectIcon,
              iconBgColor: Colors.transparent,
              title: 'Disconnect Device',
              onTap: () {
                ref
                    .read(bleDeviceConnectionProvider(deviceId).notifier)
                    .disconnect();
                context.pop();
              },
              action: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey),
            ),
            SettingsTile(
              assetPath: Assets.forgetIcon,
              iconBgColor: Colors.transparent,
              title: 'Forget This Device',
              isLast: true,
              onTap: () {
                _showConfirmationDialog(
                  context,
                  'Forget Device',
                  'Are you sure you want to forget this device?',
                  () {
                    ref
                        .read(bleSavedDevicesProvider.notifier)
                        .removeDeviceById(deviceId);
                    context.pop(); // Close dialog
                    context.pop(); // Go back
                  },
                );
              },
              action: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            if (!_checkConnection(context, isConnected)) return;
            _showConfirmationDialog(
              context,
              'Power Off',
              'Are you sure you want to power off the device?',
              () {
                ref
                    .read(bleDeviceCommunicationProvider(deviceId).notifier)
                    .sendCommand(DeviceCmdUtils.powerOff());
                Navigator.pop(context);
              },
              isDestructive: true,
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.power_settings_new, color: AppColors.brandColorRed),
                const SizedBox(width: 8),
                Text(
                  'Power Off Device',
                  style: TextStyle(
                    color: AppColors.brandColorRed,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _checkConnection(BuildContext context, bool isConnected) {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device not connected')),
      );
      return false;
    }
    return true;
  }

  void _showConfirmationDialog(BuildContext context, String title,
      String content, VoidCallback onConfirm,
      {bool isDestructive = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(
          content,
          style: const TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: onConfirm,
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? Colors.red : null,
            ),
            child: Text(title),
          ),
        ],
      ),
    );
  }
}
