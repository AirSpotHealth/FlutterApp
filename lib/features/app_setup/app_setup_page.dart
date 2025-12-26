import 'package:airspothealth/core/providers/app_notification_preferences_provider.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
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
      backgroundColor: Colors.grey[100],
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

          // Notification Preferences Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.notifications_outlined,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Notification Preferences',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Icon(
          icon,
          size: 20,
          color: value ? context.theme.primaryColor : Colors.grey,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
