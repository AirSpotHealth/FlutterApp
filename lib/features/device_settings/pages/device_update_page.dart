// ignore_for_file: use_build_context_synchronously

import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/providers/device_settings_provider.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_logo.dart';
import 'package:airspothealth/core/widgets/tappable_widget.dart';
import 'package:airspothealth/features/device_settings/widgets/device_firmware_update_dialog.dart';
import 'package:airspothealth/features/device_settings/widgets/device_version_update_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceUpdatePage extends ConsumerWidget {
  const DeviceUpdatePage({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DeviceSettings deviceSettings =
        ref.watch(deviceSettingsProvider(deviceId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AirSpot Device Update'),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TappableWidget(
          onTap: () => _showLocalFilePicker(ref, deviceId),
          tapCount: 8,
          child: const SizedBox(
            height: 64,
            child: AppLogo(),
          ),
        ),
        const SizedBox(height: 16),
        CurrentDeviceVersionWidget(
          version: deviceSettings.version,
        ),
        const SizedBox(height: 16),
        DeviceVersionUpdateWidget(deviceId: deviceId),
      ]),
    );
  }

  // allow zip file to be uploaded
  void _showLocalFilePicker(WidgetRef ref, String deviceId) {
    FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    ).then((result) {
      if (result != null) {
        showAdaptiveDialog(
          context: ref.context,
          barrierDismissible: false,
          builder: (context) => DeviceFirmwareUpdateDialog.local(
              deviceId: deviceId, localFilePath: result.files.single.path),
        );
      } else {
        ref.context.showSnackBar('No file selected');
      }
    }).catchError((e) {
      ref.context.showSnackBar('Error selecting file: $e');
    });
  }
}

class CurrentDeviceVersionWidget extends StatelessWidget {
  const CurrentDeviceVersionWidget({required this.version, super.key});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('Current Version: '),
          const Spacer(),
          Text(version.isEmpty ? 'N/A' : version),
        ],
      ),
    );
  }
}
