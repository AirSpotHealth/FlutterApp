import 'package:airspothealth/features/app_setup/providers/dev_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key for the auto-sync toggle.
const _kAutoSyncEnabled = 'auto_sync_enabled';

/// Provider that reads and writes the auto-sync preference.
/// Available only in dev mode; the saved developer preference defaults to on.
final autoSyncPreferenceProvider =
    NotifierProvider<AutoSyncPreferenceNotifier, bool>(
  AutoSyncPreferenceNotifier.new,
);

class AutoSyncPreferenceNotifier extends Notifier<bool> {
  @override
  bool build() {
    if (!ref.watch(devModeProvider)) return false;
    // Load the developer preference.
    _loadFromPrefs();
    return true;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.read(devModeProvider)) return;
    final value = prefs.getBool(_kAutoSyncEnabled) ?? true;
    if (state != value) state = value;
  }

  Future<void> toggle() async {
    if (!ref.read(devModeProvider)) return;
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoSyncEnabled, state);
  }

  Future<void> setEnabled(bool enabled) async {
    if (!ref.read(devModeProvider)) return;
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoSyncEnabled, enabled);
  }
}
