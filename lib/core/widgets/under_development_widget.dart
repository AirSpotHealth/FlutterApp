import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class UnderDevelopmentWidget extends StatelessWidget {
  const UnderDevelopmentWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.construction, size: 64, color: AppColors.primaryColor),
        SizedBox(height: 16),
        Text(
          'This page is under development, please check back later.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
