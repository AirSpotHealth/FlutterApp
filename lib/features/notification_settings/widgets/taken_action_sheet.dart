import 'package:airspothealth/core/models/ventilation_level.dart';
import 'package:airspothealth/core/services/ventilation_notification_coordinator.dart';
import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/widgets/app_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "What did you do?" single-choice sheet shown after "I've taken action".
Future<void> showTakenActionSheet(BuildContext context,
    {required String deviceId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => AppBottomSheet(child: TakenActionSheet(deviceId: deviceId)),
  );
}

class TakenActionSheet extends ConsumerStatefulWidget {
  const TakenActionSheet({required this.deviceId, super.key});

  final String deviceId;

  @override
  ConsumerState<TakenActionSheet> createState() => _TakenActionSheetState();
}

class _TakenActionSheetState extends ConsumerState<TakenActionSheet> {
  VentilationUserAction? _selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            VentilationCopy.takenActionTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            VentilationCopy.takenActionIntro,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          RadioGroup<VentilationUserAction>(
            groupValue: _selected,
            onChanged: (v) => setState(() => _selected = v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final action in VentilationUserActionX.choices)
                  RadioListTile<VentilationUserAction>(
                    value: action,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.trailing,
                    secondary:
                        Icon(action.icon, color: AppColors.textSecondary),
                    title: Text(action.label),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
              onPressed: _selected == null
                  ? null
                  : () async {
                      await ref
                          .read(ventilationCoordinatorProvider)
                          .recordUserAction(widget.deviceId, _selected!);
                      if (context.mounted) Navigator.of(context).pop();
                    },
              child: const Text(VentilationActionIds.doneLabel,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
