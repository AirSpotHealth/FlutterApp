import 'package:airspothealth/core/theme/app_colors.dart';
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
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: AppColors.dividerLight)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: assetPath != null
                      ? Image.asset(
                          assetPath!,
                          width: 22,
                          height: 22,
                          color: iconColor,
                        )
                      : Icon(icon, color: iconColor, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleSmall),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: textTheme.labelMedium),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              action,
            ],
          ),
        ),
      ),
    );
  }
}
