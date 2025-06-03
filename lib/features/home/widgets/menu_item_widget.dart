import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/utils/external_urls.dart';
import 'package:airspothealth/features/home/models/menu_item.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({
    super.key,
    required this.menuItem,
    this.iconSize = 32,
    this.dense = false,
  });

  final MenuItem menuItem;

  final double iconSize;

  final bool dense;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      contentPadding: dense ? null : const EdgeInsets.all(16),
      tileColor: Colors.white,
      enabled: menuItem.enabled,
      title: Text(menuItem.title,
          style: context.textTheme.bodyMedium?.weight600
              ?.copyWith(color: menuItem.enabled ? null : Colors.grey)),
      subtitle: menuItem.description != null
          ? Text(menuItem.description!, style: context.textTheme.bodySmall)
          : null,
      leading: Image.asset(
        menuItem.iconAsset,
        width: 32,
      ),
      trailing: Icon(
          menuItem.enabled ? Icons.arrow_forward_ios : FontAwesomeIcons.ban,
          size: 16),
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (menuItem.route != null) {
            context.pushNamed(menuItem.route!);
          }

          if (menuItem.externalUrl != null) {
            context.tryLaunchUrl(menuItem.externalUrl!);
          }

          if (menuItem.onTap != null) {
            menuItem.onTap!(context);
          }
        });
      },
    );
  }
}

class MenuItems {
  static List<MenuItem> get items => [
        MenuItem(
          title: t.home.menu.devices,
          description: t.home.menu.devicesDescription,
          iconAsset: Assets.device,
          route: RouteNames.devices,
        ),
        MenuItem(
          title: t.home.menu.airMap,
          description: t.home.menu.airMapDescription,
          iconAsset: Assets.airMap,
          externalUrl: ExternalUrls.airmap,
        ),
        MenuItem(
          title: t.home.menu.appSetup,
          description: t.home.menu.appSetupDescription,
          iconAsset: Assets.appSetup,
          route: RouteNames.appSetup,
        ),
        MenuItem(
          title: t.home.menu.solutions,
          description: t.home.menu.solutionsDescription,
          iconAsset: Assets.solutions,
          route: RouteNames.solutions,
        ),
        MenuItem(
          title: t.home.menu.shop,
          description: t.home.menu.shopDescription,
          iconAsset: Assets.shop,
          externalUrl: ExternalUrls.shop,
        ),
        MenuItem(
          title: t.home.menu.news,
          description: t.home.menu.newsDescription,
          iconAsset: Assets.news,
          externalUrl: ExternalUrls.news,
        ),
      ];
}
