import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/app_setup/providers/app_version_provider.dart';
import 'package:airspothealth/features/home/models/menu_item.dart';
import 'package:airspothealth/features/home/widgets/menu_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppUpdateBanner extends ConsumerWidget {
  const AppUpdateBanner({
    required this.menuItem,
    super.key,
  });

  final MenuItem menuItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateStatus = ref.watch(appVersionProvider);

    return Stack(
      children: [
        MenuItemWidget(menuItem: menuItem),

        // Only show banner if there's an update available
        updateStatus.when(
          data: (versionStatus) {
            if (versionStatus?.canUpdate ?? false) {
              return Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    if (versionStatus?.appStoreLink != null) {
                      context.tryLaunchUrl(versionStatus!.appStoreLink);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Update Available',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
