import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/core/utils/external_urls.dart';
import 'package:airspothealth/features/home/models/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({
    super.key,
    required this.menuItem,
  });

  final MenuItem menuItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      contentPadding: const EdgeInsets.all(16),
      tileColor: Colors.white,
      title:
          Text(menuItem.title, style: context.textTheme.bodyMedium?.weight600),
      subtitle: Text(menuItem.description, style: context.textTheme.bodySmall),
      leading: Image.asset(menuItem.iconAsset, width: 32),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (menuItem.route != null) {
            context.pushNamed(menuItem.route!);
          }

          if (menuItem.externalUrl != null) {
            context.tryLaunchUrl(menuItem.externalUrl!);
          }
        });
      },
    );
  }
}

class MenuItems {
  static final List<MenuItem> items = [
    MenuItem(
      title: 'AirMap',
      description: 'Geolocate indoor air quality with the Clean Air Map.',
      iconAsset: Assets.airMap,
      externalUrl: ExternalUrls.airmap,
    ),
    MenuItem(
      title: 'AirGraph',
      description: 'Review your AirSpots CO2 levels with time.',
      iconAsset: Assets.airGraph,
      route: RouteNames.deviceGraph,
    ),
    MenuItem(
      title: 'Devices',
      description: 'Device List and Management',
      iconAsset: Assets.device,
      route: RouteNames.devices,
    ),
    MenuItem(
      title: 'App Set Up',
      description: 'Review app notifications, updates and privacy policy.',
      iconAsset: Assets.appSetup,
      route: RouteNames.appSetup,
    ),
    MenuItem(
      title: 'Solutions',
      description: 'Great advice for healthy living in fresh air.',
      iconAsset: Assets.solutions,
      route: RouteNames.solutions,
    ),
    MenuItem(
      title: 'Find My AirSpot',
      description: 'Deliver a 5 second alarm to your BlueTooth linked device.',
      iconAsset: Assets.findMyDevice,
      route: RouteNames.findMyDevice,
    ),
    MenuItem(
      title: 'Shop',
      description: 'Great products from AirSpot and our affiliate partners.',
      iconAsset: Assets.shop,
      externalUrl: ExternalUrls.shop,
    ),
    MenuItem(
      title: 'News',
      description: 'Latest updates on fresh air living.',
      iconAsset: Assets.news,
      externalUrl: ExternalUrls.news,
    ),
  ];
}
