part of 'settings_provider.dart';

extension SettingsMirrorMutations on Settings {
  Future<bool> _addMirror(FreediumMirror mirror) async {
    final service = await _service();
    if (service == null) return false;
    final normalizedMirror = _normalizeMirror(mirror);
    if (normalizedMirror == null ||
        _current.mirrors.any((m) => m.url == normalizedMirror.url)) {
      return false;
    }
    final updatedMirrors = [..._current.mirrors, normalizedMirror];
    return _saveAndApply(
      service: service,
      nextState: _current.copyWith(mirrors: updatedMirrors),
      failureMessage: 'Failed to add mirror',
      invalidateCache: true,
    );
  }

  Future<bool> _removeMirror(FreediumMirror mirror) async {
    if (mirror.isDefault) return false;
    final service = await _service();
    if (service == null) return false;
    if (!_current.mirrors.any((m) => m.url == mirror.url)) return false;
    final selectedMirrorUrl = _current.selectedMirrorUrl;
    final remainingMirrors = _current.mirrors
        .where((m) => m.url != mirror.url)
        .toList();
    final updatedMirrors = remainingMirrors.isEmpty
        ? SettingsState.defaultMirrors
        : remainingMirrors;
    final updatedSelectedMirrorUrl = selectedMirrorUrl == mirror.url
        ? updatedMirrors.first.url
        : selectedMirrorUrl;

    return _saveAndApply(
      service: service,
      nextState: _current.copyWith(
        mirrors: updatedMirrors,
        selectedMirrorUrl: updatedSelectedMirrorUrl,
      ),
      failureMessage: 'Failed to remove mirror',
      invalidateCache: true,
    );
  }

  Future<bool> _updateMirror(
    FreediumMirror oldMirror,
    FreediumMirror newMirror,
  ) async {
    final service = await _service();
    if (service == null) return false;
    if (!_current.mirrors.any((m) => m.url == oldMirror.url)) return false;
    final normalizedMirror = _normalizeMirror(newMirror);
    if (normalizedMirror == null ||
        _current.mirrors.any(
          (m) => m.url != oldMirror.url && m.url == normalizedMirror.url,
        )) {
      return false;
    }
    final updatedMirrors = _current.mirrors.map((m) {
      if (m.url == oldMirror.url) return normalizedMirror;
      return m;
    }).toList();
    final selectedMirrorUrl = _current.selectedMirrorUrl;
    final updatedSelectedMirrorUrl = selectedMirrorUrl == oldMirror.url
        ? normalizedMirror.url
        : selectedMirrorUrl;

    return _saveAndApply(
      service: service,
      nextState: _current.copyWith(
        mirrors: updatedMirrors,
        selectedMirrorUrl: updatedSelectedMirrorUrl,
      ),
      failureMessage: 'Failed to update mirror',
      invalidateCache: true,
    );
  }

  Future<bool> _setSelectedMirror(String url) async {
    final service = await _service();
    if (service == null) return false;
    final normalizedUrl = normalizeMirrorUrl(url);
    if (normalizedUrl == null ||
        !_current.mirrors.any((mirror) => mirror.url == normalizedUrl)) {
      return false;
    }
    return _saveAndApply(
      service: service,
      nextState: _current.copyWith(selectedMirrorUrl: normalizedUrl),
      failureMessage: 'Failed to save selected mirror',
      invalidateCache: true,
    );
  }

  Future<bool> _setAutoSwitchMirror(bool autoSwitch) async {
    final service = await _service();
    if (service == null) return false;
    return _saveAndApply(
      service: service,
      nextState: _current.copyWith(autoSwitchMirror: autoSwitch),
      failureMessage: 'Failed to save auto-switch mirror',
      invalidateCache: true,
    );
  }

  Future<bool> _setMirrorTimeout(int timeout) async {
    final service = await _service();
    if (service == null) return false;
    final normalizedTimeout = SettingsState.normalizeMirrorTimeout(timeout);
    return _saveAndApply(
      service: service,
      nextState: _current.copyWith(mirrorTimeout: normalizedTimeout),
      failureMessage: 'Failed to save mirror timeout',
      invalidateCache: true,
    );
  }
}

FreediumMirror? _normalizeMirror(FreediumMirror mirror) {
  final name = mirror.name.trim();
  final url = normalizeMirrorUrl(mirror.url);
  if (name.isEmpty || url == null) return null;
  return mirror.copyWith(name: name, url: url);
}
