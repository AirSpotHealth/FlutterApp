// ignore_for_file: use_build_context_synchronously

import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/core/widgets/tappable_widget.dart';
import 'package:airspothealth/features/device_settings/providers/ble_device_version_provider.dart';
import 'package:airspothealth/features/device_settings/providers/firmware_remote_version_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/device_firmware_update_dialog.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_version_update_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_card.dart';
import 'package:airspothealth/features/device_settings/widgets/settings_tile.dart';
import 'package:airspothealth/features/devices/providers/device_battery_level_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceUpdatePage extends ConsumerStatefulWidget {
  const DeviceUpdatePage({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeviceUpdatePageState();
}

class _DeviceUpdatePageState extends ConsumerState<DeviceUpdatePage> {
  String get deviceId => widget.deviceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRemoteVersion();
    });
  }

  Future<void> _fetchRemoteVersion() async {
    ref.read(firmwareRemoteVersionProvider.notifier).fetchRemoteVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: DeviceSettingsNameWidget(
          deviceId: deviceId,
          suffixText: 'Device Update',
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: _fetchRemoteVersion,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          SettingsCard(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: TappableWidget(
                  onTap: () {
                    final batteryState =
                        ref.read(deviceBatteryLevelProvider(deviceId));
                    if (!batteryState.isCharging &&
                        batteryState.level != null &&
                        batteryState.level! < 20) {
                      context.showSnackBar(
                          'Battery too low for updating. Please connect charger.');
                      return;
                    }
                    _showLocalFilePicker(ref, deviceId);
                  },
                  tapCount: 8,
                  child: const SizedBox(
                    height: 64,
                    child: AppLogo(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CurrentDeviceVersionWidget(deviceId: deviceId),
          const SizedBox(height: 24),
          SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DeviceVersionUpdateWidget(deviceId: deviceId),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  // allow zip file to be uploaded
  void _showLocalFilePicker(WidgetRef ref, String deviceId) {
    FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    ).then((result) {
      if (result != null) {
        showAdaptiveDialog(
          context: ref.context,
          barrierDismissible: false,
          builder: (context) => DeviceFirmwareUpdateDialog.local(
            deviceId: deviceId,
            localFilePath: result.files.single.path,
            currentVersion: ref.read(bleDeviceVersionProvider(deviceId)),
          ),
        );
      } else {
        ref.context.showSnackBar('No file selected');
      }
    }).catchError((e) {
      ref.context.showSnackBar('Error selecting file: $e');
    });
  }
}

class CurrentDeviceVersionWidget extends ConsumerWidget {
  const CurrentDeviceVersionWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? version = ref.read(bleDeviceVersionProvider(deviceId));

    return SettingsCard(
      children: [
        SettingsTile(
          assetPath: Assets.deviceUpdate,
          iconBgColor: AppColors.primaryColor.withValues(alpha: 0.1),
          title: 'Installed Version',
          isLast: true,
          action: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              version ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
