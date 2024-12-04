import 'package:airspothealth/core/services/prefs_service.dart';
import 'package:airspothealth/core/utils/storage_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final devModeProvider =
    NotifierProvider<_DevModeNotifier, bool>(_DevModeNotifier.new);

class _DevModeNotifier extends Notifier<bool> {
  final PrefsService _prefsService = PrefsService();

  @override
  bool build() {
    return _prefsService.getBool(StorageKeys.devMode);
  }

  void enableDevMode() {
    _prefsService.setBool(StorageKeys.devMode, true);
    state = true;
  }

  void disableDevMode() {
    _prefsService.setBool(StorageKeys.devMode, false);
    state = false;
  }

  void toggleDevMode() {
    state = !state;

    if (state) {
      _prefsService.setBool(StorageKeys.devMode, true);
    } else {
      _prefsService.setBool(StorageKeys.devMode, false);
    }
  }
}
