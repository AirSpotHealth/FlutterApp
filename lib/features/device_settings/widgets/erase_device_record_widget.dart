import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/app_bottomsheet.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:airspothealth/features/device_settings/models/progress_model.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/providers/device_data_erase_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/cupertino.dart';
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
        title: 'Erase Device Data',
        assetIcon: Assets.airGraph,
        leadingWidget: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            CupertinoIcons.delete,
            color: AppColors.brandColorRed,
          ),
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

        context.showSnackBar('Device data erased successfully');
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
              'Are you sure you want to erase all data from this device?',
              style: context.textTheme.bodyMedium?.weight600,
            ),
            const SizedBox(height: 4),
            Text(
              'Erasing data will remove all the CO2 history stored in the device. This action cannot be undone.',
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
                  label: 'Cancel',
                  type: ButtonType.outlined,
                  wrapWidth: true,
                  onPressed: () {
                    context.pop();
                  },
                ),
                Button(
                  disabled: eraseProgress is AsyncInProgress,
                  label: eraseProgress is AsyncInProgress
                      ? eraseProgress.message ?? 'Erasing device data....'
                      : 'Erase Device Data',
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
