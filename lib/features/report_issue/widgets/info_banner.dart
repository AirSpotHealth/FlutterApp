import 'package:flutter/material.dart';

/// An informational banner with an icon and message.
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.textColor,
  });

  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.blue.shade50;
    final bdColor = borderColor ?? Colors.blue.shade200;
    final icColor = iconColor ?? Colors.blue.shade700;
    final txColor = textColor ?? Colors.blue.shade700;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bdColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: icColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: txColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
