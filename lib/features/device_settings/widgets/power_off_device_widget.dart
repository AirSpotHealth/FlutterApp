import 'package:airspothealth/core/providers/ble_device_communication_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/device_cmd_utils.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_bottomsheet.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PowerOffDeviceWidget extends ConsumerWidget {
  const PowerOffDeviceWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingItemWidget(
      item: SettingItem(
        title: t.deviceSettings.powerOffDevice,
        assetIcon: Assets.powerOff,
        suffixWidget: const SizedBox(),
      ),
      onTap: () => _showPowerOffSheet(ref),
    );
  }

  void _showPowerOffSheet(WidgetRef ref) {
    showModalBottomSheet(
      context: ref.context,
      builder: (context) => AppBottomSheet(
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 2, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.deviceSettings.areYouSurePowerOff,
                style: context.textTheme.bodyLarge?.weight600,
              ),
              const SizedBox(height: 16),
              Text(
                t.deviceSettings.powerOffDescription,
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Button(
                    wrapWidth: true,
                    label: t.common.cancel,
                    type: ButtonType.text,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Button(
                    wrapWidth: true,
                    label: t.deviceSettings.powerOff,
                    backgroundColor: AppColors.brandColorRed,
                    onPressed: () {
                      ref
                          .read(
                              bleDeviceCommunicationProvider(deviceId).notifier)
                          .sendCommand(DeviceCmdUtils.powerOff());
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
