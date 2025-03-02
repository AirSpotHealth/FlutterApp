// Extension file for managing the extensions of the app

import 'package:airspothealth/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// extension on [BuildContext]
extension ContextExtension on BuildContext {
  double get height => MediaQuery.sizeOf(this).height;
  double get width => MediaQuery.sizeOf(this).width;

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  /// launch url
  void tryLaunchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await canLaunchUrl(uri)
        ? launchUrl(uri)
        : debugPrint('Could not launch $url');
  }

  /// show snack bar
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
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

/// extension on [String]
extension StringExtension on String {
  /// check if the string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// check if the string is not null or empty
  bool get isNotNullOrEmpty => isNotEmpty;

  /// check if the string is null or empty
  bool get isNullOrBlank => trim().isEmpty;

  /// check if the string is not null or empty
  bool get isNotNullOrBlank => trim().isNotEmpty;

  /// capitalize the first letter of the string
  String capitalize() {
    return isNullOrEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }

  /// hex to bytes
  List<int> get hexToBytes {
    final List<int> bytes = [];
    for (int i = 0; i < length; i += 2) {
      bytes.add(int.parse(substring(i, i + 2), radix: 16));
    }
    return bytes;
  }
}

extension DateTimeExtension on DateTime {
  /// Format time in 10/20 01:20 format
  String formatTime() {
    final pattern =
        systemDateFormat.pattern!.replaceAll(RegExp(r'^/?y+|/y+$'), '');

    debugPrint("SYSTEM DATE FORMAT: ${systemDateFormat.pattern}");
    debugPrint("SYSTEM TIME FORMAT: ${systemTimeFormat.pattern}");
    return '${DateFormat(pattern).format(this)} ${systemTimeFormat.format(this)}';
  }

  /// format date in local format without milliseconds
  String formatLocalDate() {
    return toLocal().toString().split('.').first;
  }

  /// start of the day
  DateTime get startOfDay => DateTime(year, month, day);

  /// end of the day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999, 999);

  /// time of day
  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  // is before or equal
  bool isBeforeOrEqual(DateTime other) {
    return isBefore(other) || isAtSameMomentAs(other);
  }

  /// is after or equal
  bool isAfterOrEqual(DateTime other) {
    return isAfter(other) || isAtSameMomentAs(other);
  }

  /// is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// is same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension IntExtension on int {
  // get the name of the day
  String get dayName {
    switch (this) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  /// limit to bit size
  int limitToBitSize(int bitSize) {
    return this & ((1 << bitSize) - 1);
  }
}

/// extension on GoRouter
extension GoRouterExtension on GoRouter {
  // Navigate back to a specific route
  void popUntilPath(String ancestorPath) {
    while (routerDelegate.currentConfiguration.matches.last.matchedLocation !=
        ancestorPath) {
      if (!canPop()) {
        return;
      }
      pop();
    }
  }
}

extension ColorX on Color {
  String toHexTriplet() =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

extension DateTimeFormat on DateTime {
  String format12Hour() {
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final amPm = hour < 12 ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';
  }
}
