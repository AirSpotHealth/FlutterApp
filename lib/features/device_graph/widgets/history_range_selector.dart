import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/models/history_data_duration.dart';
import 'package:flutter/material.dart';

class HistoryRangeSelector extends StatefulWidget {
  const HistoryRangeSelector({super.key, required this.onRangeSelected});
  final void Function(HistoryDataDuration) onRangeSelected;

  @override
  State<HistoryRangeSelector> createState() => _HistoryRangeSelectorState();
}

class _HistoryRangeSelectorState extends State<HistoryRangeSelector> {
  static const List<HistoryDataDuration> _rangeOptions = [
    HistoryDataDuration.today,
    HistoryDataDuration.yesterday,
    HistoryDataDuration.last7Days,
  ];

  HistoryDataDuration _selectedRange = HistoryDataDuration.today;

  void _onRangeSelected(HistoryDataDuration range) {
    widget.onRangeSelected(range);
    setState(() {
      _selectedRange = range;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Range',
            style: context.textTheme.labelLarge?.weight600,
          ),
          const SizedBox(height: 8.0),
          Row(
            children: _rangeOptions.map((range) {
              final bool isSelected = _selectedRange == range;

              return GestureDetector(
                onTap: () => _onRangeSelected(range),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: isSelected
                        ? Colors.white
                        : AppColors.backgroundSecondary,
                  ),
                  child: Text.rich(
                    TextSpan(text: range.name.capitalize()),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
