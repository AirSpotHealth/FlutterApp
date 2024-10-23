typedef DateTimeRange = (DateTime start, DateTime end);

enum HistoryDataDuration {
  today,
  yesterday,
  last7Days;

  // get the name of the duration
  String get name {
    switch (this) {
      case HistoryDataDuration.today:
        return 'Today';
      case HistoryDataDuration.yesterday:
        return 'Yesterday';
      case HistoryDataDuration.last7Days:
        return '7 Days';
    }
  }

  factory HistoryDataDuration.fromIndex(int index) => values[index];

  // get start and end date time for the selected range
  // the range should start from 00:00:00 to 23:59:59
  DateTimeRange getDateTimeRange() {
    final DateTime now = DateTime.now();
    final DateTime end = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    );
    DateTime start;
    switch (this) {
      case HistoryDataDuration.today:
        start = DateTime(
          now.year,
          now.month,
          now.day,
          0,
          0,
          0,
        );
        break;
      case HistoryDataDuration.yesterday:
        start = DateTime(
          now.year,
          now.month,
          now.day - 1,
          0,
          0,
          0,
        );
        break;
      case HistoryDataDuration.last7Days:
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

    return (start, end);
  }
}
