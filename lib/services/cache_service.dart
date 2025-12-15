import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  final SharedPreferences _prefs;

  CacheService(this._prefs);

  static const _darkModeKey = 'dark_mode';
  static const _lastSyncKey = 'last_sync';

  bool get isDarkMode {
    return _prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_darkModeKey, value);
  }

  DateTime? get lastSync {
    final value = _prefs.getInt(_lastSyncKey);
    if (value == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<void> setLastSync(DateTime time) async {
    await _prefs.setInt(_lastSyncKey, time.millisecondsSinceEpoch);
  }
}


