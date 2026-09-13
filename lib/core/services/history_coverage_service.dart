import 'dart:math' as math;

import 'package:airspothealth/core/models/history_coverage.dart';
import 'package:airspothealth/core/providers/isar_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';

final historyCoverageServiceProvider = Provider<HistoryCoverageService>(
    (ref) => ref.read(isarServiceProvider).read(HistoryCoverageService.new));

class HistoryCoverageService {
  HistoryCoverageService(this._isar);

  final Isar _isar;

  /// The UI uses inclusive dates; storage uses half-open whole-second ranges.
  /// Exclude the current (unfinished) second as well as any future dates.
  static HistoryCoverage? requested(
      String deviceId, DateTimeRange range, DateTime now) {
    final start = (range.start.microsecondsSinceEpoch / 1000000).ceil();
    final end = math.min(
      range.end.microsecondsSinceEpoch ~/ 1000000 + 1,
      now.microsecondsSinceEpoch ~/ 1000000,
    );
    if (start >= end) return null;
    return HistoryCoverage(
        deviceId: deviceId, startSecond: start, endSecond: end);
  }

  static DateTimeRange dateRange(HistoryCoverage interval) => DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(interval.startSecond * 1000,
            isUtc: true),
        end: DateTime.fromMillisecondsSinceEpoch(
            (interval.endSecond - 1) * 1000,
            isUtc: true),
      );

  List<HistoryCoverage> missing(HistoryCoverage requested) {
    final completed = _isar.historyCoverages
        .where()
        .deviceIdEqualTo(requested.deviceId)
        .findAll()
      ..sort((a, b) => a.startSecond.compareTo(b.startSecond));
    final result = <HistoryCoverage>[];
    var cursor = requested.startSecond;
    for (final interval in completed) {
      if (interval.endSecond <= cursor) continue;
      if (interval.startSecond >= requested.endSecond) break;
      if (interval.startSecond > cursor) {
        result.add(HistoryCoverage(
            deviceId: requested.deviceId,
            startSecond: cursor,
            endSecond: interval.startSecond));
      }
      cursor = math.max(cursor, interval.endSecond);
      if (cursor >= requested.endSecond) break;
    }
    if (cursor < requested.endSecond) {
      result.add(HistoryCoverage(
          deviceId: requested.deviceId,
          startSecond: cursor,
          endSecond: requested.endSecond));
    }
    return result;
  }

  /// Call only after all readings for the scan have been durably saved.
  void complete(HistoryCoverage interval) {
    if (interval.startSecond >= interval.endSecond) {
      throw ArgumentError('History coverage must have a positive duration');
    }
    _isar.write((isar) {
      final completed = isar.historyCoverages
          .where()
          .deviceIdEqualTo(interval.deviceId)
          .findAll()
        ..sort((a, b) => a.startSecond.compareTo(b.startSecond));
      var start = interval.startSecond;
      var end = interval.endSecond;
      final replaced = <String>[];
      for (final previous in completed) {
        if (previous.endSecond < start) continue;
        if (previous.startSecond > end) break;
        start = math.min(start, previous.startSecond);
        end = math.max(end, previous.endSecond);
        replaced.add(previous.id);
      }
      isar.historyCoverages.deleteAll(replaced);
      isar.historyCoverages.put(HistoryCoverage(
          deviceId: interval.deviceId, startSecond: start, endSecond: end));
    });
  }

  /// Use within the same transaction that deletes a device's readings.
  static void clearDevice(Isar isar, String deviceId) {
    isar.historyCoverages.where().deviceIdEqualTo(deviceId).deleteAll();
  }
}
