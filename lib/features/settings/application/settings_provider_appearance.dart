part of 'settings_provider.dart';

extension SettingsAppearance on Settings {
  Future<bool> _setThemeMode(ThemeMode themeMode) async {
    final service = await _service();
    if (service == null) return false;
    return _saveAndApply(
      service: service,
      nextState: _current.copyWith(themeMode: themeMode),
      failureMessage: 'Failed to save theme mode',
    );
  }

  Future<bool> _setDefaultFontSize(double fontSize) async {
    final service = await _service();
    if (service == null) return false;
    final normalizedFontSize = SettingsState.normalizeDefaultFontSize(fontSize);
    return _saveAndApply(
      service: service,
      nextState: _current.copyWith(defaultFontSize: normalizedFontSize),
      failureMessage: 'Failed to save default font size',
    );
  }

  Future<bool> _setShowSitePopups(bool show) async {
    final service = await _service();
    if (service == null) return false;
    return _saveAndApply(
      service: service,
      nextState: _current.copyWith(showSitePopups: show),
      failureMessage: 'Failed to save site popup setting',
    );
  }
}
