import 'package:airspothealth/core/utils/extensions.dart';
import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final graphDurationProvider =
    NotifierProvider<_GraphRangeNotifier, GraphDataDuration>(
        _GraphRangeNotifier.new);

class _GraphRangeNotifier extends Notifier<GraphDataDuration> {
  @override
  GraphDataDuration build() {
    return GraphDataDuration.today;
  }

  void setDuration(GraphDataDuration duration) {
    state = duration;
  }

  void validateDateTimeRange() {
    debugPrint('validating date time range ${state.name}');

    /// check if the duration is today and the timerange is not today
    if (state.name == 'today' &&
        !state.dateTimeRange.start.isSameDay(DateTime.now())) {
      debugPrint('setting duration to today');
      setDuration(GraphDataDuration.today);
      return;
    }

    // or if the duration is custom then we can have yesterday, last 7 days and custom range

    if (state.name == 'yesterday' &&
        !state.dateTimeRange.start
            .isSameDay(DateTime.now().subtract(Duration(days: 1)))) {
      debugPrint('setting duration to yesterday');
      setDuration(GraphDataDuration.yesterday);
      return;
    }

    debugPrint('duration is valid');
  }
}
