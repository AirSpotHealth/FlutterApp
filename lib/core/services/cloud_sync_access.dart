import 'package:airspothealth/core/services/prefs_service.dart';
import 'package:airspothealth/core/utils/storage_keys.dart';

/// Shared gate for background jobs and direct cloud-sync service calls.
class CloudSyncAccess {
  static bool get enabled => PrefsService().getBool(StorageKeys.devMode);

  static void requireEnabled() {
    if (!enabled) throw StateError('Cloud sync is available in dev mode only');
  }
}
