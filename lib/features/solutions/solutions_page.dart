import 'package:airspothealth/core/utils/assets.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:airspothealth/features/home/models/menu_item.dart';
import 'package:airspothealth/features/solutions/widgets/solution_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SolutionsPage extends ConsumerWidget {
  const SolutionsPage({super.key});

  static final _solutionsList = <MenuItem>[
    MenuItem(
        title: 'Natural Vent',
        iconAsset: Assets.naturalVentIcon,
        externalUrl: '${Constants.solutionsUrl}natural-ventilation'),
    MenuItem(
        title: 'Mechanical Vent',
        iconAsset: Assets.mechanicalVentIcon,
        externalUrl: '${Constants.solutionsUrl}mechanical-ventilation'),
    MenuItem(
        title: 'CO${Constants.subscript2} Monitors',
        iconAsset: Assets.co2MonitorIcon,
        externalUrl: '${Constants.solutionsUrl}co2-monitors'),
    MenuItem(
        title: 'UV Light',
        iconAsset: Assets.uvLightIcon,
        externalUrl: '${Constants.solutionsUrl}ultraviolet-light'),
    MenuItem(
        title: 'Air Filters',
        iconAsset: Assets.airFiltersIcon,
        externalUrl: '${Constants.solutionsUrl}air-filters'),
    MenuItem(
        title: 'Regulations',
        iconAsset: Assets.regulationsIcon,
        externalUrl: '${Constants.solutionsUrl}regulations'),
    MenuItem(
        title: 'Links',
        iconAsset: Assets.linksIcon,
        externalUrl: '${Constants.solutionsUrl}links'),
    MenuItem(
        title: 'Protection',
        iconAsset: Assets.protectionIcon,
        externalUrl: '${Constants.solutionsUrl}protection'),
    MenuItem(
        title: 'Masks',
        iconAsset: Assets.masksIcon,
        externalUrl: '${Constants.solutionsUrl}masks'),
    MenuItem(
        title: 'Success Stories',
        iconAsset: Assets.successStoriesIcon,
        externalUrl: '${Constants.solutionsUrl}success'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solutions'),
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
