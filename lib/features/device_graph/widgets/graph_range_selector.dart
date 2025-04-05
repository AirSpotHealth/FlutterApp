import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:airspothealth/features/device_graph/providers/graph_range_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class GraphRangeSelector extends ConsumerWidget {
  const GraphRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GraphDataDuration selectedRange = ref.watch(graphDurationProvider);
    final dateFormat = DateFormat('MMM d');

    final String selectedRangeString = selectedRange.name == 'today'
        ? 'Today'
        : selectedRange.dateTimeRange.end
                .isSameDay(selectedRange.dateTimeRange.start)
            ? dateFormat.format(selectedRange.dateTimeRange.start)
            : "${dateFormat.format(selectedRange.dateTimeRange.start)} - ${dateFormat.format(selectedRange.dateTimeRange.end)}";

    debugPrint("Selected range: $selectedRangeString");

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryColorDark.withValues(alpha: .2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => _DatePickerSheet(
                selectedRange: selectedRange,
                onRangeSelected: (range) {
                  ref.read(graphDurationProvider.notifier).setDuration(range);
                  Navigator.pop(context);
                },
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.primaryColorDark,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedRangeString,
                  style: TextStyle(
                    color: AppColors.primaryColorDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: AppColors.primaryColorDark,
                ),
              ],
            ),
          ),
        ),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: SafeArea(
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
                    'Select Date Range',
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
          ],
        ),
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
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final lastWeek = now.subtract(const Duration(days: 7));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDateOption(
          context,
          title: 'Today',
          subtitle: _formatDate(now),
          isSelected: _isToday(selectedRange.dateTimeRange),
          onTap: () => onRangeSelected(GraphDataDuration.today),
        ),
        _buildDateOption(
          context,
          title: 'Yesterday',
          subtitle: _formatDate(yesterday),
          isSelected: _isYesterday(selectedRange.dateTimeRange),
          onTap: () => onRangeSelected(GraphDataDuration.yesterday),
        ),
        _buildDateOption(
          context,
          title: 'Last 7 Days',
          subtitle: '${_formatDate(lastWeek)} - ${_formatDate(now)}',
          isSelected: _isLastWeek(selectedRange.dateTimeRange),
          onTap: () {
            onRangeSelected(GraphDataDuration.custom(
              DateTimeRange(
                start: DateTime(lastWeek.year, lastWeek.month, lastWeek.day),
                end: now,
              ),
            ));
          },
        ),
        _buildDateOption(
          context,
          title: 'Custom Range',
          subtitle: 'Select specific dates',
          isSelected: _isCustomRange(selectedRange.dateTimeRange),
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

  Widget _buildDateOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColorDark.withValues(alpha: .05)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected
                        ? AppColors.primaryColorDark
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColorDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  bool _isToday(DateTimeRange range) {
    final now = DateTime.now();
    return range.start.year == now.year &&
        range.start.month == now.month &&
        range.start.day == now.day &&
        range.end.year == now.year &&
        range.end.month == now.month &&
        range.end.day == now.day;
  }

  bool _isYesterday(DateTimeRange range) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return range.start.year == yesterday.year &&
        range.start.month == yesterday.month &&
        range.start.day == yesterday.day &&
        range.end.year == yesterday.year &&
        range.end.month == yesterday.month &&
        range.end.day == yesterday.day;
  }

  bool _isLastWeek(DateTimeRange range) {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    return range.start.year == lastWeek.year &&
        range.start.month == lastWeek.month &&
        range.start.day == lastWeek.day &&
        range.end.isToday;
  }

  bool _isLastMonth(DateTimeRange range) {
    final now = DateTime.now();
    final lastMonth = now.subtract(const Duration(days: 30));
    return range.start.year == lastMonth.year &&
        range.start.month == lastMonth.month &&
        range.start.day == lastMonth.day &&
        range.end.isToday;
  }

  bool _isCustomRange(DateTimeRange range) {
    return !_isToday(range) &&
        !_isYesterday(range) &&
        !_isLastWeek(range) &&
        !_isLastMonth(range);
  }
}
