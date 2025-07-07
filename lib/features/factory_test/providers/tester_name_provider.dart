import 'package:airspothealth/core/services/prefs_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _testerNameKey = 'factory_test_tester_name';

final testerNameProvider = NotifierProvider<TesterNameNotifier, String>(
  TesterNameNotifier.new,
);

class TesterNameNotifier extends Notifier<String> {
  late final PrefsService _prefs;

  @override
  String build() {
    _prefs = PrefsService();
    // Load saved tester name or return empty string
    return _prefs.getString(_testerNameKey);
  }

  Future<void> updateTesterName(String name) async {
    state = name;
    await _prefs.setString(_testerNameKey, name);
  }

  Future<void> clearTesterName() async {
    state = '';
    await _prefs.setString(_testerNameKey, '');
  }
}
