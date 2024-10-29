typedef DateTimeRange = (DateTime start, DateTime end);

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

  factory GraphDataDuration.fromIndex(int index) => values[index];

  // get start and end date time for the selected range
  // the range should start from 00:00:00 to 23:59:59
  DateTimeRange getDateTimeRange() {
    final DateTime now = DateTime.now();

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

    return (start, now);
  }
}
