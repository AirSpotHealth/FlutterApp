import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/utils/assets.dart';
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
    MenuItem(
      title: 'Latest News',
      iconAsset: Assets.latestNews,
      route: RouteNames.latestNews,
      enabled: false,
    ),
    MenuItem(
        title: 'AirSpot App Updates',
        iconAsset: Assets.deviceUpdate,
        route: RouteNames.appUpdates),
    MenuItem(
      title: 'Privacy Policy',
      iconAsset: Assets.privayPolicy,
      route: RouteNames.privacyPolicy,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDevMode = ref.watch(devModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final menuItem = _items[index];
          return MenuItemWidget(
            menuItem: menuItem,
            dense: true,
            iconSize: 24,
          );
        },
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
                    }),
              ),
            )
          : null,
    );
  }
}
