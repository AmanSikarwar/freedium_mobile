part of 'settings_provider.dart';

extension SettingsPersistence on Settings {
  Future<bool> _resetToDefaults() async {
    final service = await _service();
    if (service == null) return false;
    return _saveAndApply(
      service: service,
      nextState: _defaultSettings(),
      failureMessage: 'Failed to reset settings',
      invalidateCache: true,
    );
  }

  /// Resets settings when the provider cannot load its snapshot, preserving
  /// the unreadable raw snapshot before writing defaults.
  Future<bool> _restoreDefaultsPreservingUnreadableSnapshot() async {
    try {
      final prefs = await _settingsRef.read(sharedPreferencesProvider.future);
      final service = SettingsService(prefs);
      await service.preserveSnapshotForRecovery();
      final defaultState = _defaultSettings();
      await service.saveAllSettings(defaultState);
      if (!_settingsRef.mounted) return false;
      _settingsValue = AsyncData(defaultState);
      _settingsRef.read(freediumUrlServiceProvider).invalidateCache();
      return true;
    } catch (e) {
      debugPrint('Failed to recover settings snapshot: $e');
      return false;
    }
  }
}
