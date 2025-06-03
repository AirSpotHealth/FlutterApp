import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/app_setup/providers/dev_mode_provider.dart';
import 'package:airspothealth/features/app_setup/widgets/language_selector_widget.dart';
import 'package:airspothealth/features/device_settings/models/setting_item.dart';
import 'package:airspothealth/features/device_settings/widgets/setting_item_widget.dart';
import 'package:airspothealth/features/home/models/menu_item.dart';
import 'package:airspothealth/features/home/widgets/menu_item_widget.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSetupPage extends ConsumerWidget {
  const AppSetupPage({super.key});

  static List<MenuItem> get _items => [
        MenuItem(
            title: t.appSetup.airspotAppUpdates,
            iconAsset: Assets.deviceUpdate,
            route: RouteNames.appUpdates),
        MenuItem(
          title: t.appSetup.privacyPolicy,
          iconAsset: Assets.privayPolicy,
          route: RouteNames.privacyPolicy,
        ),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDevMode = ref.watch(devModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.appSetup.title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: _items.length + 1, // +1 for language selector
        itemBuilder: (context, index) {
          if (index == _items.length) {
            // Show language selector as the last item
            return const LanguageSelectorWidget();
          }

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
                title: t.appSetup.devMode,
                leadingWidget: const Icon(Icons.developer_mode),
                enabled: isDevMode,
                suffixWidget: CupertinoSwitch(
                    value: isDevMode,
                    onChanged: (value) {
                      ref.read(devModeProvider.notifier).toggleDevMode();

                      context.showSnackBar(t.devModeDisabled);
                    }),
              ),
            )
          : null,
    );
  }
}
