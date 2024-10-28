import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';

class GraphLegends extends StatelessWidget {
  const GraphLegends({super.key});

  static const _items = [
    {'color': AppColors.brandColorRed, 'label': '> 1000'},
    {'color': AppColors.brandColorAmber, 'label': '800 - 1000'},
    {'color': AppColors.brandColorGreen, 'label': '< 800'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 14,
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.only(right: 4),
                  ),
                  const SizedBox(width: 4),
                  Text(item['label'] as String,
                      style: context.textTheme.labelSmall),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
