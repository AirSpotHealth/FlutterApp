import 'package:flutter/material.dart';

enum GraphDataDuration {
  today,
  yesterday,
  last7Days;

  // get the name of the duration
  String get name {
    switch (this) {
      case GraphDataDuration.today:
        return 'Today';
      case GraphDataDuration.yesterday:
        return 'Yesterday';
      case GraphDataDuration.last7Days:
        return '7 Days';
    }
  }

  // get the length of the duration
  int get length {
    switch (this) {
      case GraphDataDuration.today:
        return 0;
      case GraphDataDuration.yesterday:
        return 1;
      case GraphDataDuration.last7Days:
        return 7;
    }
  }

  factory GraphDataDuration.fromIndex(int index) => values[index];

  // get start and end date time for the selected range
  // the range should start from 00:00:00 to 23:59:59
  DateTimeRange getDateTimeRange({bool isTonightEnd = true}) {
    final DateTime now = DateTime.now();

    DateTime end = isTonightEnd
        ? DateTime(
            now.year,
            now.month,
            now.day,
            23,
            59,
            59,
          )
        : now;

    DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    );
    DateTime start;
    switch (this) {
      case GraphDataDuration.today:
        start = DateTime(
          now.year,
          now.month,
          now.day,
          0,
          0,
          0,
        );
        break;
      case GraphDataDuration.yesterday:
        start = DateTime(
          now.year,
          now.month,
          now.day - 1,
          0,
          0,
          0,
        );
        end = DateTime(
          now.year,
          now.month,
          now.day - 1,
          23,
          59,
          59,
        );
        break;
      case GraphDataDuration.last7Days:
        start = DateTime(
          now.year,
          now.month,
          now.day - 6,
          0,
          0,
          0,
        );
        break;
    }

    return DateTimeRange(start: start, end: end);
  }
}
