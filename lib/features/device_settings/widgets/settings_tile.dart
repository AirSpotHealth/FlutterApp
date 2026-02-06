import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final Color? iconColor;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final Widget action;
  final VoidCallback? onTap;
  final bool isLast;

  const SettingsTile({
    super.key,
    this.icon,
    this.assetPath,
    this.iconColor,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    this.action = const SizedBox.shrink(),
    this.onTap,
    this.isLast = false,
  }) : assert(icon != null || assetPath != null,
            'Either icon or assetPath must be provided');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        // If it's the last item, round the bottom corners.
        // If it's the first item (approximation checked via icon type or external param if needed, but here simplified),
        // we might could round top, but usually the Card does clipping.
        // Relying on Card clipBehavior is safer.
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(
            children: [
              if (iconBgColor != Colors.transparent)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: assetPath != null
                      ? Image.asset(
                          assetPath!,
                          width: 24,
                          height: 24,
                          color: iconColor,
                        )
                      : Icon(icon, color: iconColor, size: 24),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: assetPath != null
                      ? Image.asset(
                          assetPath!,
                          width: 28,
                          height: 28,
                          color: iconColor,
                        )
                      : Icon(icon, color: iconColor, size: 28),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Ensure action doesn't block tap if it's not interactive?
              // Actually, switches/buttons absorb taps.
              action,
            ],
          ),
        ),
      ),
    );
  }
}
