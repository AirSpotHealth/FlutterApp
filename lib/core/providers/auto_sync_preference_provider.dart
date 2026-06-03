import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key for the auto-sync toggle.
const _kAutoSyncEnabled = 'auto_sync_enabled';

/// Provider that reads and writes the auto-sync preference.
/// Defaults to `true` (auto-sync is ON by default for new users).
final autoSyncPreferenceProvider =
    NotifierProvider<AutoSyncPreferenceNotifier, bool>(
  AutoSyncPreferenceNotifier.new,
);

class AutoSyncPreferenceNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Load persisted preference asynchronously, default to true
    _loadFromPrefs();
    return true;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_kAutoSyncEnabled) ?? true;
    if (state != value) state = value;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoSyncEnabled, state);
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoSyncEnabled, enabled);
  }
}
