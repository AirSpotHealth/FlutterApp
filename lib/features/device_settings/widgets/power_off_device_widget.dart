import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PowerOffDeviceWidget extends ConsumerWidget {
  const PowerOffDeviceWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingItemWidget(
      item: SettingItem(
        title: 'Power Off Device',
        assetIcon: Assets.powerOff,
        suffixWidget: const SizedBox(),
      ),
      onTap: () {
        // show a dialog to confirm the power off action
        showAdaptiveDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Power Off Device'),
            content: const Text(
                'Are you sure you want to power off the device? This will put the device into sleep mode and will only wake up when the button is pressed in the device.'),
            actions: [
              Button(
                type: ButtonType.text,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              Button(
                type: ButtonType.text,
                onPressed: () {
                  ref
                      .read(bleDeviceCommunicationProvider(deviceId).notifier)
                      .sendCommand(DeviceCmdUtils.powerOff());
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Power Off'),
              ),
            ],
          ),
        );
      },
    );
  }
}
