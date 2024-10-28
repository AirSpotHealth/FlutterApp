import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:flutter/material.dart';

class GraphRangeSelector extends StatefulWidget {
  const GraphRangeSelector({super.key, required this.onRangeSelected});
  final void Function(GraphDataDuration) onRangeSelected;

  @override
  State<GraphRangeSelector> createState() => _GraphRangeSelectorState();
}

class _GraphRangeSelectorState extends State<GraphRangeSelector> {
  static const List<GraphDataDuration> _rangeOptions = [
    GraphDataDuration.today,
    GraphDataDuration.yesterday,
    GraphDataDuration.last7Days,
  ];

  GraphDataDuration _selectedRange = GraphDataDuration.today;

  void _onRangeSelected(GraphDataDuration range) {
    widget.onRangeSelected(range);
    setState(() {
      _selectedRange = range;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _rangeOptions.map((range) {
        final bool isSelected = _selectedRange == range;

        return GestureDetector(
          onTap: () => _onRangeSelected(range),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: isSelected
                  ? AppColors.primaryColorDark
                  : AppColors.backgroundSecondary,
            ),
            child: Text.rich(
              TextSpan(
                text: range.name.capitalize(),
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primaryColorDark,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
