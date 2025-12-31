import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

class SettingsService {
  static const String _themeModeKey = 'theme_mode';
  static const String _defaultFontSizeKey = 'default_font_size';
  static const String _mirrorsKey = 'freedium_mirrors';
  static const String _selectedMirrorUrlKey = 'selected_mirror_url';
  static const String _autoSwitchMirrorKey = 'auto_switch_mirror';
  static const String _mirrorTimeoutKey = 'mirror_timeout';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _prefs.setString(_themeModeKey, themeMode.name);
  }

  ThemeMode loadThemeMode() {
    final themeModeString = _prefs.getString(_themeModeKey);
    if (themeModeString == null) {
      return .system;
    }
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == themeModeString,
      orElse: () => .system,
    );
  }

  Future<void> saveDefaultFontSize(double fontSize) async {
    await _prefs.setDouble(_defaultFontSizeKey, fontSize);
  }

  double loadDefaultFontSize() {
    return _prefs.getDouble(_defaultFontSizeKey) ?? 18.0;
  }

  Future<void> saveMirrors(List<FreediumMirror> mirrors) async {
    final mirrorsJson = mirrors.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs.setStringList(_mirrorsKey, mirrorsJson);
  }

  List<FreediumMirror> loadMirrors() {
    final mirrorsJson = _prefs.getStringList(_mirrorsKey);
    if (mirrorsJson == null || mirrorsJson.isEmpty) {
      return SettingsState.defaultMirrors;
    }
    try {
      return mirrorsJson
          .map(
            (json) => FreediumMirror.fromJson(
              jsonDecode(json) as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (_) {
      return SettingsState.defaultMirrors;
    }
  }

  Future<void> saveSelectedMirrorUrl(String url) async {
    await _prefs.setString(_selectedMirrorUrlKey, url);
  }

  String loadSelectedMirrorUrl() {
    return _prefs.getString(_selectedMirrorUrlKey) ??
        SettingsState.defaultMirrors.first.url;
  }

  Future<void> saveAutoSwitchMirror(bool autoSwitch) async {
    await _prefs.setBool(_autoSwitchMirrorKey, autoSwitch);
  }

  bool loadAutoSwitchMirror() {
    return _prefs.getBool(_autoSwitchMirrorKey) ?? true;
  }

  Future<void> saveMirrorTimeout(int timeout) async {
    await _prefs.setInt(_mirrorTimeoutKey, timeout);
  }

  int loadMirrorTimeout() {
    return _prefs.getInt(_mirrorTimeoutKey) ?? 5;
  }

  SettingsState loadAllSettings() {
    return SettingsState(
      themeMode: loadThemeMode(),
      defaultFontSize: loadDefaultFontSize(),
      mirrors: loadMirrors(),
      selectedMirrorUrl: loadSelectedMirrorUrl(),
      autoSwitchMirror: loadAutoSwitchMirror(),
      mirrorTimeout: loadMirrorTimeout(),
    );
  }
}
