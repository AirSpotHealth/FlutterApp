import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_bottomsheet.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/providers/device_data_erase_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EraseDeviceRecordWidget extends ConsumerWidget {
  const EraseDeviceRecordWidget({required this.deviceId, super.key});

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingItemWidget(
      item: SettingItem(
        title: t.deviceSettings.eraseDeviceData,
        assetIcon: Assets.airGraph,
        leadingWidget: Image.asset(
          Assets.eraseIcon,
          width: 32,
        ),
        suffixWidget: const SizedBox(),
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isDismissible: false,
          backgroundColor: Colors.white,
          builder: (context) => _DataEraseSheet(deviceId: deviceId),
        );
      },
    );
  }
}

class _DataEraseSheet extends ConsumerWidget {
  const _DataEraseSheet({
    required this.deviceId,
  });

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(deviceDataEraseProvider(deviceId), (_, state) {
      if (state is AsyncSuccess) {
        context.pop();

        context.showSnackBar(t.deviceDataErasedSuccessfully);
      }
    });
    final AsyncProgressValue eraseProgress =
        ref.watch(deviceDataEraseProvider(deviceId));

    return AppBottomSheet(
      canBeDismissed: eraseProgress is! AsyncInProgress,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.deviceSettings.areYouSureEraseData,
              style: context.textTheme.bodyMedium?.weight600,
            ),
            const SizedBox(height: 4),
            Text(
              t.deviceSettings.eraseDataWarning,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.neutralGrey,
              ),
            ),
            const SizedBox(height: 16),
            if (eraseProgress is AsyncFailure)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "${eraseProgress.error}",
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
                  disabled: eraseProgress is AsyncInProgress,
                  label: t.common.cancel,
                  type: ButtonType.outlined,
                  wrapWidth: true,
                  onPressed: () {
                    context.pop();
                  },
                ),
                Button(
                  disabled: eraseProgress is AsyncInProgress,
                  label: eraseProgress is AsyncInProgress
                      ? eraseProgress.message ??
                          t.deviceSettings.erasingDeviceData
                      : t.deviceSettings.eraseDeviceData,
                  suffixIcon: eraseProgress is AsyncInProgress
                      ? AnimateIcon(
                          onTap: () {},
                          iconType: IconType.continueAnimation,
                          animateIcon: AnimateIcons.trashBin,
                          color: Colors.white,
                          height: 20,
                          width: 20,
                        )
                      : null,
                  backgroundColor: Colors.red,
                  wrapWidth: true,
                  onPressed: () {
                    ref
                        .read(deviceDataEraseProvider(deviceId).notifier)
                        .eraseDeviceData();
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
