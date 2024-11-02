import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/providers/device_forget_status_provider.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForgetDeviceWidget extends ConsumerWidget {
  const ForgetDeviceWidget({
    super.key,
    required this.deviceId,
  });

  final String deviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(deviceForgetStatusProvider(deviceId), (_, forgetStatus) {
      if (forgetStatus == const AsyncValue.data(true)) {
        context.showSnackBar('Device removed successfully');
        context.pop();
      }
    });

    final AsyncValue<bool> forgetStatus =
        ref.watch(deviceForgetStatusProvider(deviceId));

    return SettingItemWidget(
      onTap: () {
        if (forgetStatus == const AsyncValue.loading()) return;

        ref.read(deviceForgetStatusProvider(deviceId).notifier).forget();
      },
      item: SettingItem(
        title: 'Forget This Device',
        assetIcon: Assets.findMyDevice,
        leadingWidget: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.logout,
            color: AppColors.brandColorRed,
          ),
        ),
        suffixWidget: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
