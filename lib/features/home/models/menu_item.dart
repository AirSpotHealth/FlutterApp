import 'package:flutter/material.dart';

/// MenuItem model
class MenuItem {
  final String title;
  final String? description;
  final String iconAsset;
  final String? route;
  final String? externalUrl;
  final bool enabled;
  final dynamic Function(BuildContext)? onTap;

  MenuItem({
    required this.title,
    this.description,
    required this.iconAsset,
    this.route,
    this.externalUrl,
    this.enabled = true,
    this.onTap,
  });

  @override
  int get hashCode {
    return title.hashCode ^
        description.hashCode ^
        iconAsset.hashCode ^
        route.hashCode ^
        externalUrl.hashCode ^
        enabled.hashCode ^
        onTap.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MenuItem &&
        other.title == title &&
        other.description == description &&
        other.iconAsset == iconAsset &&
        other.route == route &&
        other.externalUrl == externalUrl &&
        other.enabled == enabled &&
        other.onTap == onTap;
  }
}
