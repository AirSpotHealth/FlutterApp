import 'package:airspothealth/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final _theme = ThemeData(
    primarySwatch: MaterialColor(
      AppColors.primaryColor.value,
      const {
        50: AppColors.primaryColorLight,
        100: AppColors.primaryColorLight,
        200: AppColors.primaryColorLight,
        300: AppColors.primaryColorLight,
        400: AppColors.primaryColor,
        500: AppColors.primaryColor,
        600: AppColors.primaryColorDark,
        700: AppColors.primaryColorDark,
        800: AppColors.primaryColorDark,
        900: AppColors.primaryColorDark,
      },
    ),
    scaffoldBackgroundColor: AppColors.backgroundSecondary,
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      titleTextStyle: TextStyle(fontSize: 16),
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      trackOutlineWidth: const WidgetStatePropertyAll(0),
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.green;
          }
          return Colors.grey.shade300;
        },
      ),
    ),
  );

  static ThemeData get theme => _theme;

  static ThemeData get darkTheme =>
      _theme.copyWith(brightness: Brightness.dark);
}
