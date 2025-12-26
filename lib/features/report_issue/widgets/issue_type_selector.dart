import 'package:airspothealth/features/report_issue/models/issue_report.dart';
import 'package:flutter/material.dart';

/// Dropdown selector for choosing an issue type.
class IssueTypeSelector extends StatelessWidget {
  const IssueTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final IssueType? value;
  final ValueChanged<IssueType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<IssueType>(
        initialValue: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Select issue type',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
        ),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        // Show simpler text-only display when selected to avoid icon clipping
        selectedItemBuilder: (context) {
          return IssueType.values.map((type) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type == IssueType.device
                        ? Icons.bluetooth
                        : Icons.phone_android,
                    size: 18,
                    color: type == IssueType.device
                        ? Colors.blue.shade600
                        : Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(type.displayName),
                ],
              ),
            );
          }).toList();
        },
        items: IssueType.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: type == IssueType.device
                        ? Colors.blue.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    type == IssueType.device
                        ? Icons.bluetooth
                        : Icons.phone_android,
                    size: 18,
                    color: type == IssueType.device
                        ? Colors.blue.shade600
                        : Colors.green.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(type.displayName),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
