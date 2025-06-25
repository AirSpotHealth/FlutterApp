import 'package:intl/intl.dart';
import 'package:system_date_time_format/system_date_time_format.dart';

class LocalDateFormat {
  // singleton
  static final LocalDateFormat _instance = LocalDateFormat._internal();
  factory LocalDateFormat() => _instance;
  LocalDateFormat._internal();

  static LocalDateFormat get instance => _instance;

  // system date format
  late final DateFormat systemDateFormat;

  // system time format
  late final DateFormat systemTimeFormat;

  Future<void> initialize() async {
    systemDateFormat = DateFormat(
        await SystemDateTimeFormat().getDatePattern() ?? 'yyyy-MM-dd');
    systemTimeFormat =
        DateFormat(await SystemDateTimeFormat().getTimePattern() ?? 'HH:mm:ss');
  }
}
