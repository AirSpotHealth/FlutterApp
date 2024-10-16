import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppUtils {
  /// get color from value
  static Color getDataColorFromValue(dynamic value) {
    if (value is! num) {
      return Colors.black;
    }

    if (value > 0 && value < 800) {
      return AppColors.brandColorGreen;
    } else if (value >= 800 && value < 1000) {
      return AppColors.brandColorAmber;
    } else if (value >= 1000) {
      return AppColors.brandColorRed;
    } else {
      return Colors.black;
    }
  }
}
