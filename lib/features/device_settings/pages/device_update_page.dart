// ignore_for_file: use_build_context_synchronously

import 'package:airspothealth/core/models/device_capabilities.dart';
import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/core/providers/ble_saved_devices_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/core/widgets/tappable_widget.dart';
import 'package:airspothealth/features/device_settings/providers/ble_device_version_provider.dart';
import 'package:airspothealth/features/device_settings/providers/firmware_remote_version_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/device_firmware_update_dialog.dart';
import 'package:airspothealth/features/device_settings/widgets/device_settings_name_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_version_update_widget.dart';
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
    ref
        .read(firmwareRemoteVersionProvider(deviceId).notifier)
        .fetchRemoteVersion();
  }

  @override
  Widget build(BuildContext context) {
    final device =
        ref.read(bleSavedDevicesProvider.notifier).getDeviceById(deviceId);
    final caps = DeviceCapabilities.fromModel(
      device?.deviceModel ?? DeviceModel.unknown,
    );
    if (!caps.supportsDeviceUpdate()) {
      return Scaffold(
        appBar: AppBar(
          title: DeviceSettingsNameWidget(
            deviceId: deviceId,
            suffixText: 'Device Update',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Over-the-air updates are not available for this device yet. '
            'Firmware is updated with a J-Link programmer (see firmware README).',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: DeviceSettingsNameWidget(
          deviceId: deviceId,
          suffixText: 'Device Update',
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh:
            _fetchRemoteVersion, // refresh the remote version on pull down
        child: ListView(padding: const EdgeInsets.all(16), children: [
          TappableWidget(
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
          const SizedBox(height: 16),
          CurrentDeviceVersionWidget(deviceId: deviceId),
          const SizedBox(height: 16),
          DeviceVersionUpdateWidget(deviceId: deviceId),
        ]),
      ),
    );
  }

  // allow zip file to be uploaded
  void _showLocalFilePicker(WidgetRef ref, String deviceId) {
    FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ref
                  .read(bleSavedDevicesProvider.notifier)
                  .getDeviceById(deviceId)
                  ?.deviceModel ==
              DeviceModel.airspotSlim
          ? ['zip', 'bin']
          : ['zip'],
    ).then((result) {
      if (result == null) {
        ref.context.showSnackBar('No file selected');
        return;
      }

      final path = result.files.single.path;
      if (path == null) {
        ref.context.showSnackBar(
            'Could not access the selected file. Copy it to On My iPhone first.');
        return;
      }

      showAdaptiveDialog(
        context: ref.context,
        barrierDismissible: false,
        builder: (context) => DeviceFirmwareUpdateDialog.local(
          deviceId: deviceId,
          localFilePath: path,
          currentVersion: ref.read(bleDeviceVersionProvider(deviceId)),
        ),
      );
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('Installed Version: '),
          const Spacer(),
          Text(version ?? 'N/A'),
        ],
      ),
    );
  }
}
