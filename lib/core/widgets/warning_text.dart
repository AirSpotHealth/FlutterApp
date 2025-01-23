import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';

class WarningText extends StatelessWidget {
  const WarningText({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: context.textTheme.bodyMedium
            ?.copyWith(color: AppColors.brandColorAmber));
  }
}
