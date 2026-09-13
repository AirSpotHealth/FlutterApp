import 'package:isar_plus/isar_plus.dart';

part 'history_coverage.g.dart';

/// Verified Slim downloads, in UTC epoch seconds: [startSecond, endSecond).
/// Separate periods must never imply coverage of the gap between them.
@collection
class HistoryCoverage {
  HistoryCoverage({
    required this.deviceId,
    required this.startSecond,
    required this.endSecond,
  });

  String get id => '$deviceId:$startSecond';

  @Index()
  final String deviceId;
  final int startSecond;
  final int endSecond;
}
