import 'package:airspothealth/features/device_graph/models/graph_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final graphSettingsProvider =
    NotifierProvider<_GraphSettingsNotifier, GraphSettings>(
        _GraphSettingsNotifier.new);

class _GraphSettingsNotifier extends Notifier<GraphSettings> {
  @override
  GraphSettings build() {
    return GraphSettings.defaults();
  }

  void setSettings(GraphSettings settings) {
    state = settings;
  }
}
