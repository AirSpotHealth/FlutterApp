import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:flutter/material.dart';

class AppUtils {
  /// get color from value
  static Color getDataColorFromValue(dynamic value) {
    if (value is! num) {
      return Colors.black;
    }

    if (value > 0 && value < Constants.greenThreshold) {
      return AppColors.brandColorGreen;
    } else if (value >= Constants.greenThreshold &&
        value < Constants.yellowThreshold) {
      return AppColors.brandColorAmber;
    } else if (value >= Constants.yellowThreshold) {
      return AppColors.brandColorRed;
    } else {
      return Colors.black;
    }
  }
}
