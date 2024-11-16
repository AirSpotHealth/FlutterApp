import 'package:airspothealth/core/models/device_settings.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';

class GraphLegends extends StatelessWidget {
  const GraphLegends({
    super.key,
    required this.deviceSettings,
  });

  final DeviceSettings deviceSettings;

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'color': AppColors.brandColorRed,
        'label': '> ${deviceSettings.yellowUpperLimit}'
      },
      {
        'color': AppColors.brandColorAmber,
        'label':
            '${deviceSettings.greenUpperLimit} - ${deviceSettings.yellowUpperLimit}'
      },
      {
        'color': AppColors.brandColorGreen,
        'label': '< ${deviceSettings.greenUpperLimit}'
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
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
