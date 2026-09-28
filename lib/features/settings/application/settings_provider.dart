import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/utils/url.dart'
    show hasSameOrigin, isHttpUri, normalizeMirrorUrl, trimTrailingSlash;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freedium_mobile/features/settings/application/mirror_probe.dart'
    show probeMirrorUrl;
import 'package:freedium_mobile/features/settings/application/settings_service.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

export 'mirror_probe.dart'
    show MirrorProbeResult, probeMirrorUrl, sendMirrorProbeRequest;

part 'settings_provider.freezed.dart';
part 'settings_provider.g.dart';

/// Creates [HttpClient] instances for mirror reachability probes.
/// Overridable in tests to avoid real network access.
@Riverpod(keepAlive: true)
HttpClient Function() httpClientFactory(Ref ref) => HttpClient.new;

bool isFreediumMirrorUrl(String url, Iterable<FreediumMirror> mirrors) {
  final uri = Uri.tryParse(url);
  if (!isHttpUri(uri)) {
    return false;
  }

  for (final mirror in mirrors) {
    final mirrorUri = Uri.tryParse(mirror.url);
    if (!isHttpUri(mirrorUri)) {
      continue;
    }

    if (hasSameOrigin(uri!, mirrorUri!) &&
        _hasMirrorPathPrefix(uri.path, mirrorUri.path)) {
      return true;
    }
  }

  return false;
}

bool _hasMirrorPathPrefix(String path, String mirrorPath) {
  final normalizedMirrorPath = trimTrailingSlash(mirrorPath);

  if (normalizedMirrorPath.isEmpty) {
    return true;
  }

  return path == normalizedMirrorPath ||
      path.startsWith('$normalizedMirrorPath/');
}

@Riverpod(keepAlive: true)
class Settings() extends _$Settings {
  Future<SettingsService?> _service() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      return SettingsService(prefs);
    } catch (e) {
      debugPrint('SettingsService unavailable: $e');
      return null;
    }
  }

  /// Current settings, falling back to defaults while loading or on error.
  SettingsState get _current => state.value ?? const SettingsState();

  @override
  FutureOr<SettingsState> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return SettingsService(prefs).loadAllSettings();
  }

  Future<bool> setThemeMode(ThemeMode themeMode) async {
    final service = await _service();
    if (service == null) return false;
    return _saveAndApply(
      save: () => service.saveThemeMode(themeMode),
      nextState: _current.copyWith(themeMode: themeMode),
      failureMessage: 'Failed to save theme mode',
    );
  }

  Future<bool> setDefaultFontSize(double fontSize) async {
    final service = await _service();
    if (service == null) return false;
    final normalizedFontSize = SettingsState.normalizeDefaultFontSize(fontSize);
    return _saveAndApply(
      save: () => service.saveDefaultFontSize(normalizedFontSize),
      nextState: _current.copyWith(defaultFontSize: normalizedFontSize),
      failureMessage: 'Failed to save default font size',
    );
  }

  Future<bool> setShowSitePopups(bool show) async {
    final service = await _service();
    if (service == null) return false;
    return _saveAndApply(
      save: () => service.saveShowSitePopups(show),
      nextState: _current.copyWith(showSitePopups: show),
      failureMessage: 'Failed to save site popup setting',
    );
  }

  Future<bool> addMirror(FreediumMirror mirror) async {
    final service = await _service();
    if (service == null) return false;
    final normalizedMirror = _normalizeMirror(mirror);
    if (normalizedMirror == null ||
        _current.mirrors.any((m) => m.url == normalizedMirror.url)) {
      return false;
    }
    final updatedMirrors = [..._current.mirrors, normalizedMirror];
    return _saveAndApply(
      save: () => service.saveMirrors(updatedMirrors),
      nextState: _current.copyWith(mirrors: updatedMirrors),
      failureMessage: 'Failed to add mirror',
      invalidateCache: true,
    );
  }

  Future<bool> removeMirror(FreediumMirror mirror) async {
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
      save: () async {
        await service.saveMirrors(updatedMirrors);
        if (updatedSelectedMirrorUrl != selectedMirrorUrl) {
          await service.saveSelectedMirrorUrl(updatedSelectedMirrorUrl);
        }
      },
      nextState: _current.copyWith(
        mirrors: updatedMirrors,
        selectedMirrorUrl: updatedSelectedMirrorUrl,
      ),
      failureMessage: 'Failed to remove mirror',
      invalidateCache: true,
    );
  }

  Future<bool> updateMirror(
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
      save: () async {
        await service.saveMirrors(updatedMirrors);
        if (updatedSelectedMirrorUrl != selectedMirrorUrl) {
          await service.saveSelectedMirrorUrl(updatedSelectedMirrorUrl);
        }
      },
      nextState: _current.copyWith(
        mirrors: updatedMirrors,
        selectedMirrorUrl: updatedSelectedMirrorUrl,
      ),
      failureMessage: 'Failed to update mirror',
      invalidateCache: true,
    );
  }

  Future<bool> setSelectedMirror(String url) async {
    final service = await _service();
    if (service == null) return false;
    final normalizedUrl = normalizeMirrorUrl(url);
    if (normalizedUrl == null ||
        !_current.mirrors.any((mirror) => mirror.url == normalizedUrl)) {
      return false;
    }
    return _saveAndApply(
      save: () => service.saveSelectedMirrorUrl(normalizedUrl),
      nextState: _current.copyWith(selectedMirrorUrl: normalizedUrl),
      failureMessage: 'Failed to save selected mirror',
      invalidateCache: true,
    );
  }

  Future<bool> setAutoSwitchMirror(bool autoSwitch) async {
    final service = await _service();
    if (service == null) return false;
    return _saveAndApply(
      save: () => service.saveAutoSwitchMirror(autoSwitch),
      nextState: _current.copyWith(autoSwitchMirror: autoSwitch),
      failureMessage: 'Failed to save auto-switch mirror',
      invalidateCache: true,
    );
  }

  Future<bool> setMirrorTimeout(int timeout) async {
    final service = await _service();
    if (service == null) return false;
    final normalizedTimeout = SettingsState.normalizeMirrorTimeout(timeout);
    return _saveAndApply(
      save: () => service.saveMirrorTimeout(normalizedTimeout),
      nextState: _current.copyWith(mirrorTimeout: normalizedTimeout),
      failureMessage: 'Failed to save mirror timeout',
      invalidateCache: true,
    );
  }

  Future<bool> resetToDefaults() async {
    final service = await _service();
    if (service == null) return false;
    final defaultState = SettingsState(
      mirrors: SettingsState.defaultMirrors,
      selectedMirrorUrl: SettingsState.defaultMirrors.first.url,
    );
    return _saveAndApply(
      save: () async {
        await service.saveThemeMode(defaultState.themeMode);
        await service.saveDefaultFontSize(defaultState.defaultFontSize);
        await service.saveMirrors(defaultState.mirrors);
        await service.saveSelectedMirrorUrl(defaultState.selectedMirrorUrl);
        await service.saveAutoSwitchMirror(defaultState.autoSwitchMirror);
        await service.saveMirrorTimeout(defaultState.mirrorTimeout);
        await service.saveShowSitePopups(defaultState.showSitePopups);
      },
      nextState: defaultState,
      failureMessage: 'Failed to reset settings',
      invalidateCache: true,
    );
  }

  Future<bool> _saveAndApply({
    required Future<void> Function() save,
    required SettingsState nextState,
    required String failureMessage,
    bool invalidateCache = false,
  }) async {
    try {
      await save();
      state = AsyncData(nextState);
      if (invalidateCache) {
        ref.read(freediumUrlServiceProvider).invalidateCache();
      }
      return true;
    } catch (e) {
      debugPrint('$failureMessage: $e');
      return false;
    }
  }

  Future<MirrorTestResult> testMirror(String url) async {
    await _service();
    final stopwatch = Stopwatch()..start();
    HttpClient? client;

    try {
      final uri = Uri.parse(url);
      final timeout = Duration(seconds: _current.mirrorTimeout);
      client = ref.read(httpClientFactoryProvider)();
      client.connectionTimeout = timeout;

      final probeResult = await probeMirrorUrl(client, uri, timeout);

      stopwatch.stop();

      return MirrorTestResult(
        isReachable: probeResult.isReachable,
        responseTimeMs: stopwatch.elapsedMilliseconds,
        statusCode: probeResult.statusCode,
        error: probeResult.error,
      );
    } catch (e) {
      stopwatch.stop();
      return MirrorTestResult(
        isReachable: false,
        responseTimeMs: stopwatch.elapsedMilliseconds,
        error: e.toString(),
      );
    } finally {
      client?.close();
    }
  }

  Future<String?> findWorkingMirror() async {
    await _service();
    for (final mirror in _current.mirrors) {
      final result = await testMirror(mirror.url);
      if (result.isReachable) {
        return mirror.url;
      }
    }
    return null;
  }
}

FreediumMirror? _normalizeMirror(FreediumMirror mirror) {
  final name = mirror.name.trim();
  final url = normalizeMirrorUrl(mirror.url);
  if (name.isEmpty || url == null) return null;
  return mirror.copyWith(name: name, url: url);
}

@freezed
abstract class MirrorTestResult with _$MirrorTestResult {
  const factory MirrorTestResult({
    required bool isReachable,
    required int responseTimeMs,
    int? statusCode,
    String? error,
  }) = _MirrorTestResult;
}

class FreediumUrlService(this._ref) {
  String? _cachedWorkingUrl;
  DateTime? _lastCheckTime;
  final Ref _ref;

  static const Duration _cacheDuration = Duration(minutes: 5);

  Duration get _checkTimeout {
    final settings = _ref.read(settingsProvider).value ?? const SettingsState();
    return Duration(seconds: settings.mirrorTimeout);
  }

  Future<String> getActiveUrl() async {
    final settings = _ref.read(settingsProvider).value ?? const SettingsState();

    if (!settings.autoSwitchMirror) {
      return settings.selectedMirrorUrl;
    }

    if (_cachedWorkingUrl != null &&
        _lastCheckTime != null &&
        DateTime.now().difference(_lastCheckTime!) < _cacheDuration) {
      return _cachedWorkingUrl!;
    }

    final mirrors = settings.mirrors;
    final selectedMirrorIndex = mirrors.indexWhere(
      (mirror) => mirror.url == settings.selectedMirrorUrl,
    );
    final mirrorsToCheck = [
      if (selectedMirrorIndex >= 0) mirrors[selectedMirrorIndex],
      ...mirrors.where((mirror) => mirror.url != settings.selectedMirrorUrl),
    ];

    for (final mirror in mirrorsToCheck) {
      if (await _isUrlReachable(mirror.url)) {
        _cachedWorkingUrl = mirror.url;
        _lastCheckTime = DateTime.now();
        debugPrint('Using Freedium URL: ${mirror.url}');
        return _cachedWorkingUrl!;
      }
    }

    debugPrint(
      'All mirrors unreachable, using selected: ${settings.selectedMirrorUrl}',
    );
    _cachedWorkingUrl = settings.selectedMirrorUrl;
    _lastCheckTime = DateTime.now();
    return _cachedWorkingUrl!;
  }

  Future<bool> _isUrlReachable(String url) async {
    HttpClient? client;
    try {
      final uri = Uri.parse(url);
      client = _ref.read(httpClientFactoryProvider)();
      client.connectionTimeout = _checkTimeout;
      final probeResult = await probeMirrorUrl(client, uri, _checkTimeout);
      return probeResult.isReachable;
    } catch (e) {
      debugPrint('URL reachability check failed for $url: $e');
      return false;
    } finally {
      client?.close();
    }
  }

  void invalidateCache() {
    _cachedWorkingUrl = null;
    _lastCheckTime = null;
  }

  bool isFreediumUrl(String url) {
    final settings = _ref.read(settingsProvider).value ?? const SettingsState();
    return isFreediumMirrorUrl(url, settings.mirrors);
  }
}

final freediumUrlServiceProvider = Provider(FreediumUrlService.new);
