// Extension file for managing the extensions of the app

import 'package:flutter/material.dart';

/// extension on [BuildContext]
extension ContextExtension on BuildContext {
  double get height => MediaQuery.sizeOf(this).height;
  double get width => MediaQuery.sizeOf(this).width;

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;
}

/// extension on [TextStyle]
extension TextStyleExtension on TextStyle? {
  /// bold 500 weight
  TextStyle? get weight500 => this?.copyWith(fontWeight: FontWeight.w500);

  /// bold 600 weight
  TextStyle? get weight600 => this?.copyWith(fontWeight: FontWeight.w600);

  /// bold 700 weight
  TextStyle? get weight700 => this?.copyWith(fontWeight: FontWeight.w700);
}

/// extension on [Enum]
extension EnumExtension on Enum {
  /// when extension for enums
  T when<T>({
    required Map<Enum, T Function()> cases,
    required T Function() orElse,
  }) {
    if (cases.containsKey(this)) {
      return cases[this]!();
    } else {
      return orElse();
    }
  }
}

/// extension on [Iterable]
extension IterableExtension<T> on Iterable<T>? {
  /// check if the list is empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// first where or null
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this!) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
