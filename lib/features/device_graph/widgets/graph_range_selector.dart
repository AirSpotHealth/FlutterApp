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

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => _DatePickerSheet(
            selectedRange: selectedRange,
            onRangeSelected: (range) {
              ref.read(graphDurationProvider.notifier).setDuration(range);
              Navigator.pop(context);
            },
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 14,
            color: AppColors.primaryColorDark,
          ),
          const SizedBox(width: 4),
          Text(
            selectedRange.durationString,
            style: TextStyle(
              color: AppColors.primaryColorDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerSheet extends StatelessWidget {
  final GraphDataDuration selectedRange;
  final Function(GraphDataDuration) onRangeSelected;

  const _DatePickerSheet({
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColorDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          const Divider(),
          _QuickDateOptions(
            selectedRange: selectedRange,
            onRangeSelected: onRangeSelected,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _QuickDateOptions extends StatelessWidget {
  final GraphDataDuration selectedRange;
  final Function(GraphDataDuration) onRangeSelected;

  const _QuickDateOptions({
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DateOption(
          title: 'Today',
          isSelected: selectedRange.name == 'today',
          onTap: () => onRangeSelected(GraphDataDuration.today),
        ),
        _DateOption(
          title: 'Yesterday',
          isSelected: false,
          onTap: () {
            final yesterday = DateTime.now().subtract(const Duration(days: 1));
            onRangeSelected(GraphDataDuration.custom(
              DateTimeRange(
                start: DateTime(yesterday.year, yesterday.month, yesterday.day),
                end: DateTime(
                    yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
              ),
            ));
          },
        ),
        _DateOption(
          title: 'Last 7 Days',
          isSelected: false,
          onTap: () {
            final now = DateTime.now();
            final sevenDaysAgo = now.subtract(const Duration(days: 7));
            onRangeSelected(GraphDataDuration.custom(
              DateTimeRange(
                start: DateTime(
                    sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day),
                end: now,
              ),
            ));
          },
        ),
        _DateOption(
          title: 'Custom Range',
          isSelected: false,
          onTap: () async {
            Navigator.pop(context);
            final picked = await showDateRangePicker(
              context: context,
              initialDateRange: selectedRange.dateTimeRange,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primaryColorDark,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: AppColors.primaryColorDark,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              if (picked.end.isToday) {
                onRangeSelected(GraphDataDuration.custom(
                  DateTimeRange(
                    start: DateTime(picked.start.year, picked.start.month,
                        picked.start.day),
                    end: DateTime.now(),
                  ),
                ));
              } else {
                onRangeSelected(GraphDataDuration.custom(
                  DateTimeRange(
                    start: DateTime(picked.start.year, picked.start.month,
                        picked.start.day),
                    end: DateTime(picked.end.year, picked.end.month,
                        picked.end.day, 23, 59, 59),
                  ),
                ));
              }
            }
          },
        ),
      ],
    );
  }
}

class _DateOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? AppColors.primaryColorDark : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check,
                color: AppColors.primaryColorDark,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
