import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppUtils {
  /// get color from value
  static Color getDataColorFromValue(dynamic value) {
    if (value is! num) {
      return AppColors.brandColorGreen;
    }

    if (value > 0 && value < 800) {
      return AppColors.brandColorGreen;
    } else if (value >= 800 && value < 1000) {
      return AppColors.brandColorAmber;
    } else if (value >= 1000) {
      return AppColors.brandColorRed;
    } else {
      return AppColors.brandColorGreen;
    }
  }

  /// check the version is greater than the current version
  static bool isVersionGreater(String currentVersion, String newVersion) {
    if (newVersion.contains('beta')) {
      return true;
    }

    final List<String> currentVersionList = currentVersion.split('.');
    final List<String> newVersionList = newVersion.split('.');

    for (int i = 0; i < currentVersionList.length; i++) {
      final int currentVersionInt = int.parse(currentVersionList[i]);
      final int newVersionInt = int.parse(newVersionList[i]);

      if (newVersionInt > currentVersionInt) {
        return true;
      }
    }

    return false;
  }
}
