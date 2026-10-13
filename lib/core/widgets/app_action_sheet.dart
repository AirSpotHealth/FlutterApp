import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/widgets/app_bottomsheet.dart';
import 'package:flutter/material.dart';

/// Uses the same sheet chrome, spacing and artwork as device settings.
class AppActionSheet extends StatelessWidget {
  const AppActionSheet(
      {required this.asset,
      required this.title,
      required this.description,
      required this.actions,
      this.details,
      this.canBeDismissed = true,
      super.key});
  final String asset, title, description;
  final List<Widget> actions;
  final Widget? details;
  final bool canBeDismissed;

  @override
  Widget build(BuildContext context) => AppBottomSheet(
        canBeDismissed: canBeDismissed,
        child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                          child: Image.asset(asset,
                              width: 48,
                              height: 48,
                              excludeFromSemantics: true)),
                      const SizedBox(height: 16),
                      Text(title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Text(description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.45)),
                      if (details != null) ...[
                        const SizedBox(height: 20),
                        details!
                      ],
                      const SizedBox(height: 24),
                      ...actions.expand(
                          (action) => [action, const SizedBox(height: 8)]),
                    ]))),
      );
}
