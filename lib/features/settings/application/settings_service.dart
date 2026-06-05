import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freedium_mobile/features/settings/application/mirror_url_normalizer.dart';
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
    await _savePreference(
      () => _prefs.setString(_themeModeKey, themeMode.name),
      methodName: 'setString',
      key: _themeModeKey,
    );
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
    await _savePreference(
      () => _prefs.setDouble(
        _defaultFontSizeKey,
        SettingsState.normalizeDefaultFontSize(fontSize),
      ),
      methodName: 'setDouble',
      key: _defaultFontSizeKey,
    );
  }

  double loadDefaultFontSize() {
    return SettingsState.normalizeDefaultFontSize(
      _prefs.getDouble(_defaultFontSizeKey) ??
          SettingsState.defaultDefaultFontSize,
    );
  }

  Future<void> saveMirrors(List<FreediumMirror> mirrors) async {
    final mirrorsJson = mirrors.map((m) => jsonEncode(m.toJson())).toList();
    await _savePreference(
      () => _prefs.setStringList(_mirrorsKey, mirrorsJson),
      methodName: 'setStringList',
      key: _mirrorsKey,
    );
  }

  List<FreediumMirror> loadMirrors() {
    final mirrorsJson = _prefs.getStringList(_mirrorsKey);
    if (mirrorsJson == null || mirrorsJson.isEmpty) {
      return SettingsState.defaultMirrors;
    }

    final mirrors = <FreediumMirror>[];
    final seenUrls = <String>{};
    for (final entry in mirrorsJson) {
      try {
        final mirror = FreediumMirror.fromJson(
          jsonDecode(entry) as Map<String, dynamic>,
        );
        final name = mirror.name.trim();
        final url = normalizeMirrorUrl(mirror.url);
        if (name.isEmpty || url == null || !seenUrls.add(url)) {
          continue;
        }
        mirrors.add(mirror.copyWith(name: name, url: url));
      } catch (_) {
        continue;
      }
    }

    return mirrors.isEmpty ? SettingsState.defaultMirrors : mirrors;
  }

  Future<void> saveSelectedMirrorUrl(String url) async {
    await _savePreference(
      () => _prefs.setString(_selectedMirrorUrlKey, url),
      methodName: 'setString',
      key: _selectedMirrorUrlKey,
    );
  }

  String loadSelectedMirrorUrl() {
    final selectedMirrorUrl = _prefs.getString(_selectedMirrorUrlKey);
    return selectedMirrorUrl == null
        ? SettingsState.defaultMirrors.first.url
        : normalizeMirrorUrl(selectedMirrorUrl) ??
              SettingsState.defaultMirrors.first.url;
  }

  Future<void> saveAutoSwitchMirror(bool autoSwitch) async {
    await _savePreference(
      () => _prefs.setBool(_autoSwitchMirrorKey, autoSwitch),
      methodName: 'setBool',
      key: _autoSwitchMirrorKey,
    );
  }

  bool loadAutoSwitchMirror() {
    return _prefs.getBool(_autoSwitchMirrorKey) ?? true;
  }

  Future<void> saveMirrorTimeout(int timeout) async {
    await _savePreference(
      () => _prefs.setInt(
        _mirrorTimeoutKey,
        SettingsState.normalizeMirrorTimeout(timeout),
      ),
      methodName: 'setInt',
      key: _mirrorTimeoutKey,
    );
  }

  int loadMirrorTimeout() {
    return SettingsState.normalizeMirrorTimeout(
      _prefs.getInt(_mirrorTimeoutKey) ?? SettingsState.defaultMirrorTimeout,
    );
  }

  SettingsState loadAllSettings() {
    final mirrors = loadMirrors();
    final selectedMirrorUrl = loadSelectedMirrorUrl();
    final resolvedSelectedMirrorUrl =
        mirrors.any((mirror) => mirror.url == selectedMirrorUrl)
        ? selectedMirrorUrl
        : mirrors.first.url;

    return SettingsState(
      themeMode: loadThemeMode(),
      defaultFontSize: loadDefaultFontSize(),
      mirrors: mirrors,
      selectedMirrorUrl: resolvedSelectedMirrorUrl,
      autoSwitchMirror: loadAutoSwitchMirror(),
      mirrorTimeout: loadMirrorTimeout(),
    );
  }
}

Future<void> _savePreference(
  Future<bool> Function() save, {
  required String methodName,
  required String key,
}) async {
  try {
    final success = await save();
    if (!success) {
      throw Exception('$methodName returned false for key "$key"');
    }
  } catch (e) {
    debugPrint('Failed to save setting "$key": $e');
    rethrow;
  }
}
