import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freedium_mobile/core/utils/url.dart' show normalizeMirrorUrl;
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

class SettingsService(this._prefs) {
  static const String _snapshotKey = 'settings_snapshot';
  static const String _fontSizeKey = 'webview_font_size';
  static const String _themeModeKey = 'theme_mode';
  static const String _mirrorsKey = 'freedium_mirrors';
  static const String _selectedMirrorUrlKey = 'selected_mirror_url';
  static const String _autoSwitchMirrorKey = 'auto_switch_mirror';
  static const String _mirrorTimeoutKey = 'mirror_timeout';
  static const String _showSitePopupsKey = 'show_site_popups';

  final SharedPreferences _prefs;

  Future<void> saveThemeMode(ThemeMode themeMode) =>
      saveAllSettings(loadAllSettings().copyWith(themeMode: themeMode));

  ThemeMode loadThemeMode() {
    final themeModeString = _get<String>(_themeModeKey);
    if (themeModeString == null) {
      return .system;
    }
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == themeModeString,
      orElse: () => .system,
    );
  }

  Future<void> saveDefaultFontSize(double fontSize) => saveAllSettings(
    loadAllSettings().copyWith(
      defaultFontSize: SettingsState.normalizeDefaultFontSize(fontSize),
    ),
  );

  double loadDefaultFontSize() {
    final saved = _get<num>(_fontSizeKey);
    return SettingsState.normalizeDefaultFontSize(
      saved?.toDouble() ?? FontSizeService(_prefs).loadFontSize(),
    );
  }

  Future<void> saveMirrors(List<FreediumMirror> mirrors) =>
      saveAllSettings(loadAllSettings().copyWith(mirrors: mirrors));

  List<FreediumMirror> loadMirrors() {
    final mirrorsJson = _get<List<dynamic>>(_mirrorsKey)?.cast<String>();
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

  Future<void> saveSelectedMirrorUrl(String url) =>
      saveAllSettings(loadAllSettings().copyWith(selectedMirrorUrl: url));

  String loadSelectedMirrorUrl() {
    final selectedMirrorUrl = _get<String>(_selectedMirrorUrlKey);
    return selectedMirrorUrl == null
        ? SettingsState.defaultMirrors.first.url
        : normalizeMirrorUrl(selectedMirrorUrl) ??
              SettingsState.defaultMirrors.first.url;
  }

  Future<void> saveAutoSwitchMirror(bool autoSwitch) =>
      saveAllSettings(loadAllSettings().copyWith(autoSwitchMirror: autoSwitch));

  bool loadAutoSwitchMirror() {
    return _get<bool>(_autoSwitchMirrorKey) ?? true;
  }

  Future<void> saveMirrorTimeout(int timeout) => saveAllSettings(
    loadAllSettings().copyWith(
      mirrorTimeout: SettingsState.normalizeMirrorTimeout(timeout),
    ),
  );

  int loadMirrorTimeout() {
    return SettingsState.normalizeMirrorTimeout(
      _get<int>(_mirrorTimeoutKey) ?? SettingsState.defaultMirrorTimeout,
    );
  }

  Future<void> saveShowSitePopups(bool show) =>
      saveAllSettings(loadAllSettings().copyWith(showSitePopups: show));

  bool loadShowSitePopups() {
    return _get<bool>(_showSitePopupsKey) ?? true;
  }

  T? _get<T>(String key) {
    final raw = _prefs.getString(_snapshotKey);
    if (raw == null) return _prefs.get(key) as T?;
    final snapshot = jsonDecode(raw) as Map<String, dynamic>;
    if (snapshot['version'] != 1) {
      throw const FormatException('Unsupported settings snapshot');
    }
    return (snapshot['values'] as Map<String, dynamic>)[key] as T?;
  }

  /// Commits the complete settings state in one platform write.
  Future<void> saveAllSettings(SettingsState settings) async {
    final values = {
      _themeModeKey: settings.themeMode.name,
      _fontSizeKey: settings.defaultFontSize,
      _mirrorsKey: settings.mirrors.map((m) => jsonEncode(m.toJson())).toList(),
      _selectedMirrorUrlKey: settings.selectedMirrorUrl,
      _autoSwitchMirrorKey: settings.autoSwitchMirror,
      _mirrorTimeoutKey: settings.mirrorTimeout,
      _showSitePopupsKey: settings.showSitePopups,
    };
    try {
      await _savePreference(
        () => _prefs.setString(
          _snapshotKey,
          jsonEncode({'version': 1, 'values': values}),
        ),
        methodName: 'setString',
        key: _snapshotKey,
      );
    } catch (_) {
      // A failed legacy SharedPreferences write still changes its cache.
      await _prefs.reload();
      rethrow;
    }
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
      showSitePopups: loadShowSitePopups(),
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
