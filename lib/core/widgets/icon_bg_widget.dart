import 'package:flutter/material.dart';

class IconBgWidget extends StatelessWidget {
  const IconBgWidget({
    required this.backgroundColor,
    required this.child,
    super.key,
  });

  final Color backgroundColor;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
