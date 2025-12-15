import 'package:flutter/material.dart';

import '../services/cache_service.dart';

class ThemeProvider extends ChangeNotifier {
  final CacheService _cache;
  bool _isDark;

  ThemeProvider(this._cache) : _isDark = _cache.isDarkMode;

  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    await _cache.setDarkMode(_isDark);
  }
}


