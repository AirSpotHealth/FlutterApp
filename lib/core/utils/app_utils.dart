import 'dart:math';

import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:airspothealth/core/widgets/button.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoTimerPicker, CupertinoTimerPickerMode;
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
  static bool isVersionGreater(String? currentVersion, String newVersion) {
    if (newVersion.contains('beta')) {
      return true;
    }

    if (currentVersion == null) {
      return true;
    }

    final List<String> currentVersionList = currentVersion.split('.');
    final List<String> newVersionList = newVersion.split('.');

    for (int i = 0; i < currentVersionList.length; i++) {
      final int currentVersionInt = int.tryParse(currentVersionList[i]) ?? 0;
      final int newVersionInt = int.tryParse(newVersionList[i]) ?? 0;

      if (newVersionInt > currentVersionInt) {
        return true;
      }
    }

    return false;
  }

  static bool isNewFirmwareVersion(String? firmwareVersion) {
    if (firmwareVersion == null) {
      return false;
    }

    // it version is less than 3.0.0 then return false
    final List<String> versionList = firmwareVersion.split('.');
    if (versionList.length < 3) {
      return false;
    }

    debugPrint('versionList: $versionList');

    final int minorVersion = int.tryParse(versionList[1]) ?? 0;

    if (minorVersion < 3) {
      return false;
    }

    return true;
  }
}

// Show cupertino time picker
Future<TimeOfDay?> showCupertinoTimePicker(
  BuildContext context, {
  TimeOfDay? initialTime,
}) async {
  TimeOfDay? selectedTime;

  return await showAdaptiveDialog<TimeOfDay?>(
    context: context,
    builder: (context) {
      return AlertDialog.adaptive(
        content: SizedBox(
          height: 200,
          child: CupertinoTimerPicker(
            onTimerDurationChanged: (value) {
              selectedTime = TimeOfDay(
                  hour: value.inHours, minute: value.inMinutes.remainder(60));
            },
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: Duration(
              hours: initialTime?.hour ?? 0,
              minutes: initialTime?.minute ?? 0,
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.all(16),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          Button(
            type: ButtonType.text,
            textColor: Colors.grey,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          Button(
            type: ButtonType.text,
            textColor: Colors.black,
            onPressed: () {
              Navigator.of(context).pop(selectedTime);
            },
            child: const Text('Ok'),
          ),
        ],
      );
    },
  );
}

/// Converts the scaling factor to pressure in hPa
double convertScalingToPressure(double scaling) {
  const double m = -0.0028169;
  const double c = 3.852;
  final result = (scaling - c) / m;
  return result.isNaN ? 0.0 : result;
}

/// Converts the scaling factor directly to altitude in meters
double convertScalingToAltitude(double scaling) {
  final pressure = convertScalingToPressure(scaling);
  final result = 44330 * (1 - pow(pressure / 1013.0, 1 / 5.255)) as double;
  return result.isNaN ? 0.0 : result;
}

/// Calculate scaling from pressure (in hPa)
double calculateScalingFromPressure(double pressure) {
  const double m = -0.0028169;
  const double c = 3.852;
  final result = m * pressure + c;
  return result.isNaN ? 0.0 : result;
}

/// Calculate scaling from altitude (in meters)
double calculateScalingFromAltitude(double altitude) {
  const double standardPressure = 1013.0;
  double pressure = standardPressure * pow(1 - (altitude / 44330.0), 5.255);
  final result = calculateScalingFromPressure(pressure);
  return result.isNaN ? 0.0 : result;
}
