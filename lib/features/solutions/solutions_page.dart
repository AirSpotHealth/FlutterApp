import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/features/home/models/menu_item.dart';
import 'package:airspothealth/features/solutions/widgets/solution_widget.dart';
import 'package:airspothealth/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SolutionsPage extends ConsumerWidget {
  const SolutionsPage({super.key});

  static List<MenuItem> get _solutionsList => [
        MenuItem(
            title: t.solutions.naturalVent,
            iconAsset: Assets.naturalVentIcon,
            externalUrl: '${Constants.solutionsUrl}natural-ventilation'),
        MenuItem(
            title: t.solutions.mechanicalVent,
            iconAsset: Assets.mechanicalVentIcon,
            externalUrl: '${Constants.solutionsUrl}mechanical-ventilation'),
        MenuItem(
            title: t.solutions.co2Monitors(co2Text: Constants.co2Text),
            iconAsset: Assets.co2MonitorIcon,
            externalUrl: '${Constants.solutionsUrl}co2-monitors'),
        MenuItem(
            title: t.solutions.uvLight,
            iconAsset: Assets.uvLightIcon,
            externalUrl: '${Constants.solutionsUrl}ultraviolet-light'),
        MenuItem(
            title: t.solutions.airFilters,
            iconAsset: Assets.airFiltersIcon,
            externalUrl: '${Constants.solutionsUrl}air-filters'),
        MenuItem(
            title: t.solutions.regulations,
            iconAsset: Assets.regulationsIcon,
            externalUrl: '${Constants.solutionsUrl}regulations'),
        MenuItem(
            title: t.solutions.links,
            iconAsset: Assets.linksIcon,
            externalUrl: '${Constants.solutionsUrl}links'),
        MenuItem(
            title: t.solutions.protection,
            iconAsset: Assets.protectionIcon,
            externalUrl: '${Constants.solutionsUrl}protection'),
        MenuItem(
            title: t.solutions.masks,
            iconAsset: Assets.masksIcon,
            externalUrl: '${Constants.solutionsUrl}masks'),
        MenuItem(
            title: t.solutions.successStories,
            iconAsset: Assets.successStoriesIcon,
            externalUrl: '${Constants.solutionsUrl}success'),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.solutions.title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const SizedBox(height: 4),
        itemCount: _solutionsList.length,
        itemBuilder: (context, index) {
          final menuItem = _solutionsList[index];
          return SolutionWidget(item: menuItem);
        },
      ),
    );
  }
}
