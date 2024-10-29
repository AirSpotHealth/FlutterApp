import 'package:airspothealth/features/device_graph/models/graph_data_duration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final graphDurationProvider =
    NotifierProvider.autoDispose<_GraphRangeNotifier, GraphDataDuration>(
        _GraphRangeNotifier.new);

class _GraphRangeNotifier extends AutoDisposeNotifier<GraphDataDuration> {
  @override
  GraphDataDuration build() {
    return GraphDataDuration.today;
  }

  void setDuration(GraphDataDuration duration) {
    state = duration;
  }
}
