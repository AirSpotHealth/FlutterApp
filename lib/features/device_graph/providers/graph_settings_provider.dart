import 'dart:convert';

import 'package:airspothealth/core/services/prefs_service.dart';
import 'package:airspothealth/core/utils/storage_keys.dart';
import 'package:airspothealth/features/device_graph/models/graph_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final graphSettingsProvider =
    NotifierProvider<_GraphSettingsNotifier, GraphSettings>(
        _GraphSettingsNotifier.new);

class _GraphSettingsNotifier extends Notifier<GraphSettings> {
  @override
  GraphSettings build() {
    final settings = PrefsService().getString(StorageKeys.graphSettings);

    if (settings.isNotEmpty) {
      return GraphSettings.fromJson(jsonDecode(settings));
    }

    return GraphSettings.defaults();
  }

  void setSettings(GraphSettings settings) {
    state = settings;

    PrefsService()
        .setString(StorageKeys.graphSettings, jsonEncode(settings.toJson()));
  }
}
