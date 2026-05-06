import 'package:airspothealth/core/providers/app_notification_preferences_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/widgets/section_header.dart';
import 'package:airspothealth/features/app_setup/providers/dev_mode_provider.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:airspothealth/features/home/models/menu_item.dart';
import 'package:airspothealth/features/home/widgets/menu_item_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSetupPage extends ConsumerWidget {
  const AppSetupPage({super.key});

  static final _items = <MenuItem>[
    // MenuItem(
    //   title: 'Latest News',
    //   iconAsset: Assets.latestNews,
    //   route: RouteNames.latestNews,
    //   enabled: false,
    // ),
    MenuItem(
        title: 'AirSpot App Updates',
        iconAsset: Assets.deviceUpdate,
        route: RouteNames.appUpdates),
    MenuItem(
      title: 'Privacy Policy',
      iconAsset: Assets.privayPolicy,
      route: RouteNames.privacyPolicy,
    ),
    MenuItem(
      title: 'Report an Issue',
      iconAsset: Assets.reportIssue,
      route: RouteNames.reportIssue,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDevMode = ref.watch(devModeProvider);
    final notificationPrefs = ref.watch(appNotificationPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Menu Items Section
          ..._items.map(
            (menuItem) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MenuItemWidget(
                menuItem: menuItem,
                dense: true,
                iconSize: 24,
              ),
            ),
          ),

          const SizedBox(height: 16),

          const SectionHeader(title: 'Notification Preferences'),

          _buildNotificationToggle(
            context,
            ref,
            title: 'News & Announcements',
            subtitle: 'Important news and company announcements',
            value: notificationPrefs.newsNotifications,
            icon: Icons.newspaper,
            onChanged: (value) {
              ref
                  .read(appNotificationPreferencesProvider.notifier)
                  .toggleNews(value);
            },
          ),

          const SizedBox(height: 10),

          _buildNotificationToggle(
            context,
            ref,
            title: 'Blog Posts',
            subtitle: 'New articles and insights',
            value: notificationPrefs.blogsNotifications,
            icon: Icons.article,
            onChanged: (value) {
              ref
                  .read(appNotificationPreferencesProvider.notifier)
                  .toggleBlogs(value);
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: isDevMode
          ? SettingItemWidget(
              onTap: () {},
              item: SettingItem(
                title: 'Dev Mode',
                leadingWidget: const Icon(Icons.developer_mode),
                enabled: isDevMode,
                suffixWidget: CupertinoSwitch(
                    value: isDevMode,
                    onChanged: (value) {
                      ref.read(devModeProvider.notifier).toggleDevMode();

                      context.showSnackBar('Dev Mode is now disabled');
                    }),
              ),
            )
          : null,
    );
  }

  Widget _buildNotificationToggle(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowPrimary,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(
          icon,
          size: 20,
          color: value ? AppColors.primaryColor : AppColors.textTertiary,
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
