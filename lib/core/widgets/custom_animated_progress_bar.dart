import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';

class CustomAnimatedProgressBar extends StatelessWidget {
  final double progress;

  const CustomAnimatedProgressBar({super.key, required this.progress})
      : assert(
            progress >= 0 && progress <= 1, 'Progress must be between 0 and 1');

  @override
  Widget build(BuildContext context) {
    final double screenWidth = context.width;
    return Stack(
      children: [
        Container(
          width: screenWidth,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        AnimatedContainer(
          width: screenWidth * progress,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
