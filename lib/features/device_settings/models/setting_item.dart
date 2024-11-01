import 'package:flutter/material.dart';

class SettingItem {
  final String title;
  final String assetIcon;
  final String? route;
  final Widget? suffixWidget;
  final bool enabled;

  SettingItem({
    required this.title,
    required this.assetIcon,
    this.route,
    this.suffixWidget,
    this.enabled = true,
  }) : assert(route != null || suffixWidget != null,
            "route or suffixWidget must be provided");

  @override
  int get hashCode {
    return title.hashCode ^
        assetIcon.hashCode ^
        route.hashCode ^
        suffixWidget.hashCode ^
        enabled.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingItem &&
        other.title == title &&
        other.assetIcon == assetIcon &&
        other.route == route &&
        other.suffixWidget == suffixWidget &&
        other.enabled == enabled;
  }
}
