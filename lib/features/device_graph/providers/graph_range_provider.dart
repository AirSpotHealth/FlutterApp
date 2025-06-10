import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final graphDurationProvider =
    NotifierProvider<_GraphRangeNotifier, GraphDataDuration>(
        _GraphRangeNotifier.new);

class _GraphRangeNotifier extends Notifier<GraphDataDuration> {
  // Variable to track when was the last time the duration was set
  DateTime _lastDateTimeSet = DateTime.now();

  @override
  GraphDataDuration build() {
    return GraphDataDuration.today;
  }

  void setDuration(GraphDataDuration duration) {
    state = duration;
    _lastDateTimeSet = DateTime.now();
  }

  void validateDateTimeRange() {
    debugPrint('validating date time range ${state.name}');

    if (_lastDateTimeSet.isSameDay(DateTime.now())) {
      return;
    }

    /// check if the duration is today and the last time the duration was set is not today
    if (state.name == 'today') {
      debugPrint('setting duration to today');
      setDuration(GraphDataDuration.today);
      return;
    }

    // or if the duration is custom then we can have yesterday, last 7 days and custom range
    if (state.name == 'yesterday') {
      debugPrint('setting duration to yesterday');
      setDuration(GraphDataDuration.yesterday);
      return;
    }

    // if the duration is last 7 days and the last time the duration was set is not last 7 days
    if (state.name == 'last 7 days') {
      debugPrint('setting duration to last 7 days');
      setDuration(GraphDataDuration.custom(DateTimeRange(
          start: DateTime.now().subtract(Duration(days: 7)),
          end: DateTime.now())));
      return;
    }

    // if the duration is custom and the last time the duration was set is not custom
    if (state.name == 'custom') {
      debugPrint('setting duration to custom');
      // adjust the duration to the new range
      setDuration(GraphDataDuration.custom(DateTimeRange(
          start: DateTime.now().subtract(Duration(days: 7)),
          end: DateTime.now())));
      return;
    }

    debugPrint('duration is valid');
  }
}
