import 'package:airspothealth/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GraphDataDuration {
  final DateTimeRange dateTimeRange;
  final String name;

  const GraphDataDuration._(this.dateTimeRange, this.name);

  factory GraphDataDuration.custom(DateTimeRange range) {
    return GraphDataDuration._(range, 'custom');
  }

  static GraphDataDuration get today {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return GraphDataDuration._(DateTimeRange(start: start, end: now), 'today');
  }

  // copy with new date time range
  GraphDataDuration copyWith({DateTimeRange? dateTimeRange, String? name}) {
    return GraphDataDuration._(
        dateTimeRange ?? this.dateTimeRange, name ?? this.name);
  }

  @override
  String toString() {
    return 'GraphDataDuration(dateTimeRange: $dateTimeRange, name: $name)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphDataDuration &&
          runtimeType == other.runtimeType &&
          dateTimeRange == other.dateTimeRange;

  @override
  int get hashCode => dateTimeRange.hashCode;

  String get durationString {
    switch (name) {
      case 'today':
        return 'Today';
      case 'custom':
        {
          if (dateTimeRange.start.isSameDay(dateTimeRange.end)) {
            return DateFormat.yMMMd().format(dateTimeRange.start);
          }

          // check if yesterday
          if (dateTimeRange.start
              .isSameDay(dateTimeRange.start.subtract(Duration(days: 1)))) {
            return 'Yesterday';
          }

          return '${DateFormat.yMMMd().format(dateTimeRange.start)} - ${DateFormat.yMMMd().format(dateTimeRange.end)}';
        }
      default:
        return name;
    }
  }
}
