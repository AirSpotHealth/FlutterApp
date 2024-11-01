import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/graph_range_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GraphRangeSelector extends ConsumerWidget {
  const GraphRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GraphDataDuration selectedRange = ref.watch(graphDurationProvider);
    return Container(
      constraints: BoxConstraints(maxWidth: context.width * 0.7),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: GraphDataDuration.values.map((range) {
          final bool isSelected = selectedRange == range;

          return Flexible(
            child: GestureDetector(
              onTap: () =>
                  ref.read(graphDurationProvider.notifier).setDuration(range),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: isSelected
                      ? AppColors.primaryColorDark
                      : AppColors.backgroundSecondary,
                ),
                child: Text(
                  range.name.capitalize(),
                  style: TextStyle(
                    color:
                        isSelected ? Colors.white : AppColors.primaryColorDark,
                    fontSize: context.textTheme.bodyMedium?.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
