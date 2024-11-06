import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static final PrefsService _instance = PrefsService._();

  PrefsService._();

  factory PrefsService() => _instance;

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String getString(String key) => _prefs.getString(key) ?? '';

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }
}
