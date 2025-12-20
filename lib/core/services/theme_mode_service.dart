import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

class ThemeModeService {
  static const String _themeModeKey = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeModeService(this._prefs);

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _prefs.setString(_themeModeKey, themeMode.name);
  }

  ThemeMode loadThemeMode() {
    final themeModeString = _prefs.getString(_themeModeKey);

    if (themeModeString == null) {
      return ThemeMode.system;
    }

    return ThemeMode.values.firstWhere(
      (mode) => mode.name == themeModeString,
      orElse: () => ThemeMode.system,
    );
  }
}
