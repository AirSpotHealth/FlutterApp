import 'package:airspothealth/core/models/device_model.dart';
import 'package:airspothealth/features/device_graph/providers/ble_device_provider.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_bottomsheet.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/providers/device_factory_reset_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FactoryResetWidget extends ConsumerWidget {
  const FactoryResetWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingItemWidget(
      item: SettingItem(
        title: 'Factory Reset',
        assetIcon: Assets.factoryReset, // Placeholder icon
        leadingWidget: Image.asset(
          Assets.factoryReset, // Placeholder icon
          width: 32,
        ),
        suffixWidget: const SizedBox(),
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isDismissible: false,
          backgroundColor: Colors.white,
          builder: (context) => _FactoryResetSheet(deviceId: deviceId),
        );
      },
    );
  }
}

class _FactoryResetSheet extends ConsumerWidget {
  const _FactoryResetSheet({
    required this.deviceId,
  });

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSlim = ref.watch(bleDeviceProvider(deviceId)).deviceModel ==
        DeviceModel.airspotSlim;
    ref.listen(deviceFactoryResetProvider(deviceId), (_, state) {
      if (state is AsyncSuccess) {
        context.pop();
        context.pop();
        context.showSnackBar(isSlim
            ? 'Reset complete. Keep it off the charger and release the button. Wait 5 seconds, then press the button to turn it on.'
            : 'Device factory reset successfully');
      }
    });
    final AsyncProgressValue resetProgress =
        ref.watch(deviceFactoryResetProvider(deviceId));

    return AppBottomSheet(
      canBeDismissed: resetProgress is! AsyncInProgress,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isSlim
                  ? 'Factory reset this Slim?'
                  : 'Are you sure you want to factory reset this device?',
              style: context.textTheme.bodyMedium?.weight600,
            ),
            const SizedBox(height: 4),
            Text(
              isSlim
                  ? 'Remove your Slim from its charger and release its button before continuing. This erases settings, saved readings and sensor calibration. The Slim then powers off. Wait 5 seconds after completion, then press the button to turn it on. Readings may be inaccurate while the sensor settles. This cannot be undone.'
                  : 'Factory reset erases device settings, saved readings, manual calibration and the sensor’s learned auto-calibration history. This action cannot be undone.',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.neutralGrey,
              ),
            ),
            const SizedBox(height: 16),
            if (resetProgress is AsyncFailure)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "${resetProgress.error}",
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.brandColorRed,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(
                  disabled: resetProgress is AsyncInProgress,
                  label: 'Cancel',
                  type: ButtonType.outlined,
                  wrapWidth: true,
                  onPressed: () {
                    context.pop();
                  },
                ),
                Button(
                  disabled: resetProgress is AsyncInProgress,
                  label: resetProgress is AsyncInProgress
                      ? resetProgress.message ?? 'Resetting device....'
                      : 'Factory Reset',
                  suffixIcon: resetProgress is AsyncInProgress
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : null,
                  backgroundColor: Colors.red,
                  wrapWidth: true,
                  onPressed: () {
                    ref
                        .read(deviceFactoryResetProvider(deviceId).notifier)
                        .factoryResetDevice();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
