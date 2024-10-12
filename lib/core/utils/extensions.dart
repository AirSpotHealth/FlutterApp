// Extension file for managing the extensions of the app

import 'package:flutter/material.dart';

/// extension on [BuildContext]
extension ContextExtension on BuildContext {
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;

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
