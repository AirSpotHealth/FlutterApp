import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/widgets/app_bottomsheet.dart';
import 'package:airspothealth/features/notification_settings/widgets/taken_action_sheet.dart';
import 'package:flutter/material.dart';

/// "Improve the air" guidance shown for "What can I do?".
Future<void> showGuidanceSheet(BuildContext context,
    {required String deviceId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => AppBottomSheet(child: GuidanceSheet(deviceId: deviceId)),
  );
}

class GuidanceSheet extends StatelessWidget {
  const GuidanceSheet({required this.deviceId, super.key});

  final String deviceId;

  static const _icons = [
    Icons.north_east_rounded,
    Icons.waves_rounded,
    Icons.east_rounded,
    Icons.remove_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            VentilationCopy.guidanceTitle,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            VentilationCopy.guidanceIntro,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < VentilationCopy.guidanceItems.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_icons[i], color: AppColors.textSecondary),
              title: Text(VentilationCopy.guidanceItems[i]),
            ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              VentilationCopy.guidanceNote,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                showTakenActionSheet(context, deviceId: deviceId);
              },
              child: const Text(VentilationActionIds.takenActionLabel,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
