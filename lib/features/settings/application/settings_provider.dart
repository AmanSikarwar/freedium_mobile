import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/settings/application/settings_service.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

class _MirrorProbeResult {
  final bool isReachable;
  final int? statusCode;
  final String? error;

  const _MirrorProbeResult({
    required this.isReachable,
    this.statusCode,
    this.error,
  });
}

bool _isSuccessStatus(int statusCode) => statusCode >= 200 && statusCode < 400;

Future<_MirrorProbeResult> _sendProbeRequest(
  HttpClient client,
  Uri uri,
  Duration timeout, {
  required bool useGet,
}) async {
  try {
    final request = useGet
        ? await client.getUrl(uri).timeout(timeout)
        : await client.headUrl(uri).timeout(timeout);

    if (useGet) {
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-0');
    }

    final response = await request.close().timeout(timeout);
    final statusCode = response.statusCode;
    final isReachable = _isSuccessStatus(statusCode);

    return _MirrorProbeResult(
      isReachable: isReachable,
      statusCode: statusCode,
      error: isReachable ? null : 'HTTP $statusCode',
    );
  } catch (e) {
    return _MirrorProbeResult(isReachable: false, error: e.toString());
  }
}

Future<_MirrorProbeResult> _probeMirrorUrl(
  HttpClient client,
  Uri uri,
  Duration timeout,
) async {
  final headResult = await _sendProbeRequest(
    client,
    uri,
    timeout,
    useGet: false,
  );

  if (headResult.isReachable) {
    return headResult;
  }

  final shouldFallbackToGet =
      headResult.statusCode == null || headResult.statusCode! >= 400;

  if (!shouldFallbackToGet) {
    return headResult;
  }

  final getResult = await _sendProbeRequest(client, uri, timeout, useGet: true);

  if (getResult.isReachable) {
    return getResult;
  }

  if (getResult.statusCode != null || getResult.error != null) {
    return getResult;
  }

  return headResult;
}

bool isFreediumMirrorUrl(String url, Iterable<FreediumMirror> mirrors) {
  final uri = Uri.tryParse(url);
  if (uri == null || !_isHttpUri(uri)) {
    return false;
  }

  for (final mirror in mirrors) {
    final mirrorUri = Uri.tryParse(mirror.url);
    if (mirrorUri == null || !_isHttpUri(mirrorUri)) {
      continue;
    }

    if (_hasSameOrigin(uri, mirrorUri) &&
        _hasMirrorPathPrefix(uri.path, mirrorUri.path)) {
      return true;
    }
  }

  return false;
}

bool _isHttpUri(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  return (scheme == 'http' || scheme == 'https') && uri.host.isNotEmpty;
}

bool _hasSameOrigin(Uri url, Uri mirror) {
  return url.scheme.toLowerCase() == mirror.scheme.toLowerCase() &&
      url.host.toLowerCase() == mirror.host.toLowerCase() &&
      url.port == mirror.port;
}

bool _hasMirrorPathPrefix(String path, String mirrorPath) {
  final normalizedMirrorPath = _trimTrailingSlash(mirrorPath);

  if (normalizedMirrorPath.isEmpty) {
    return true;
  }

  return path == normalizedMirrorPath ||
      path.startsWith('$normalizedMirrorPath/');
}

class SettingsNotifier extends Notifier<SettingsState> {
  SettingsService? _settingsService;

  Future<SettingsService?> _ensureSettingsService() async {
    final existingService = _settingsService;
    if (existingService != null) {
      return existingService;
    }

    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final service = SettingsService(prefs);
      _settingsService = service;
      state = service.loadAllSettings();
      return service;
    } catch (e) {
      debugPrint('SettingsService unavailable: $e');
      return null;
    }
  }

  @override
  SettingsState build() {
    final prefsAsync = ref.watch(sharedPreferencesProvider);

    return prefsAsync.when(
      data: (prefs) {
        _settingsService = SettingsService(prefs);
        return _settingsService!.loadAllSettings();
      },
      loading: () => const SettingsState(),
      error: (_, _) => const SettingsState(),
    );
  }

  Future<bool> setThemeMode(ThemeMode themeMode) async {
    final service = await _ensureSettingsService();
    if (service == null) return false;
    return _saveAndApply(
      save: () => service.saveThemeMode(themeMode),
      nextState: state.copyWith(themeMode: themeMode),
      failureMessage: 'Failed to save theme mode',
    );
  }

  Future<void> setDefaultFontSize(double fontSize) async {
    final service = await _ensureSettingsService();
    if (service == null) return;
    final normalizedFontSize = SettingsState.normalizeDefaultFontSize(fontSize);
    await _saveAndApply(
      save: () => service.saveDefaultFontSize(normalizedFontSize),
      nextState: state.copyWith(defaultFontSize: normalizedFontSize),
      failureMessage: 'Failed to save default font size',
    );
  }

  Future<bool> addMirror(FreediumMirror mirror) async {
    final service = await _ensureSettingsService();
    if (service == null) return false;
    final normalizedMirror = _normalizeMirror(mirror);
    if (normalizedMirror == null ||
        state.mirrors.any((m) => m.url == normalizedMirror.url)) {
      return false;
    }
    final updatedMirrors = [...state.mirrors, normalizedMirror];
    return _saveAndApply(
      save: () => service.saveMirrors(updatedMirrors),
      nextState: state.copyWith(mirrors: updatedMirrors),
      failureMessage: 'Failed to add mirror',
      invalidateCache: true,
    );
  }

  Future<void> removeMirror(FreediumMirror mirror) async {
    if (mirror.isDefault) return;
    final service = await _ensureSettingsService();
    if (service == null) return;
    if (!state.mirrors.contains(mirror)) return;
    final selectedMirrorUrl = state.selectedMirrorUrl;
    final remainingMirrors = state.mirrors.where((m) => m != mirror).toList();
    final updatedMirrors = remainingMirrors.isEmpty
        ? SettingsState.defaultMirrors
        : remainingMirrors;
    final updatedSelectedMirrorUrl = selectedMirrorUrl == mirror.url
        ? updatedMirrors.first.url
        : selectedMirrorUrl;

    await _saveAndApply(
      save: () async {
        await service.saveMirrors(updatedMirrors);
        if (updatedSelectedMirrorUrl != selectedMirrorUrl) {
          await service.saveSelectedMirrorUrl(updatedSelectedMirrorUrl);
        }
      },
      nextState: state.copyWith(
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
    final service = await _ensureSettingsService();
    if (service == null) return false;
    if (!state.mirrors.contains(oldMirror)) return false;
    final normalizedMirror = _normalizeMirror(newMirror);
    if (normalizedMirror == null ||
        state.mirrors.any(
          (m) => m != oldMirror && m.url == normalizedMirror.url,
        )) {
      return false;
    }
    final updatedMirrors = state.mirrors.map((m) {
      if (m == oldMirror) return normalizedMirror;
      return m;
    }).toList();
    final selectedMirrorUrl = state.selectedMirrorUrl;
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
      nextState: state.copyWith(
        mirrors: updatedMirrors,
        selectedMirrorUrl: updatedSelectedMirrorUrl,
      ),
      failureMessage: 'Failed to update mirror',
      invalidateCache: true,
    );
  }

  Future<bool> setSelectedMirror(String url) async {
    final service = await _ensureSettingsService();
    if (service == null) return false;
    final normalizedUrl = _normalizeMirrorUrl(url);
    if (normalizedUrl == null ||
        !state.mirrors.any((mirror) => mirror.url == normalizedUrl)) {
      return false;
    }
    return _saveAndApply(
      save: () => service.saveSelectedMirrorUrl(normalizedUrl),
      nextState: state.copyWith(selectedMirrorUrl: normalizedUrl),
      failureMessage: 'Failed to save selected mirror',
      invalidateCache: true,
    );
  }

  Future<bool> setAutoSwitchMirror(bool autoSwitch) async {
    final service = await _ensureSettingsService();
    if (service == null) return false;
    return _saveAndApply(
      save: () => service.saveAutoSwitchMirror(autoSwitch),
      nextState: state.copyWith(autoSwitchMirror: autoSwitch),
      failureMessage: 'Failed to save auto-switch mirror',
      invalidateCache: true,
    );
  }

  Future<bool> setMirrorTimeout(int timeout) async {
    final service = await _ensureSettingsService();
    if (service == null) return false;
    final normalizedTimeout = SettingsState.normalizeMirrorTimeout(timeout);
    return _saveAndApply(
      save: () => service.saveMirrorTimeout(normalizedTimeout),
      nextState: state.copyWith(mirrorTimeout: normalizedTimeout),
      failureMessage: 'Failed to save mirror timeout',
      invalidateCache: true,
    );
  }

  Future<bool> resetToDefaults() async {
    final service = await _ensureSettingsService();
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
      state = nextState;
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
    await _ensureSettingsService();
    final stopwatch = Stopwatch()..start();
    HttpClient? client;

    try {
      final uri = Uri.parse(url);
      final timeout = Duration(seconds: state.mirrorTimeout);
      client = HttpClient();
      client.connectionTimeout = timeout;

      final probeResult = await _probeMirrorUrl(client, uri, timeout);

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
    await _ensureSettingsService();
    for (final mirror in state.mirrors) {
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
  final url = _normalizeMirrorUrl(mirror.url);
  if (name.isEmpty || url == null) return null;
  return mirror.copyWith(name: name, url: url);
}

String? _normalizeMirrorUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  final scheme = uri?.scheme.toLowerCase();
  if (uri == null ||
      !uri.hasScheme ||
      uri.host.isEmpty ||
      (scheme != 'http' && scheme != 'https')) {
    return null;
  }

  return Uri(
    scheme: scheme,
    userInfo: uri.userInfo,
    host: uri.host.toLowerCase(),
    port: uri.hasPort ? uri.port : null,
    path: _trimTrailingSlash(uri.path),
  ).toString();
}

String _trimTrailingSlash(String value) {
  var trimmed = value;
  while (trimmed.length > 1 && trimmed.endsWith('/')) {
    trimmed = trimmed.substring(0, trimmed.length - 1);
  }

  return trimmed == '/' ? '' : trimmed;
}

class MirrorTestResult {
  final bool isReachable;
  final int responseTimeMs;
  final int? statusCode;
  final String? error;

  const MirrorTestResult({
    required this.isReachable,
    required this.responseTimeMs,
    this.statusCode,
    this.error,
  });
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class FreediumUrlService {
  String? _cachedWorkingUrl;
  DateTime? _lastCheckTime;
  final Ref _ref;

  static const Duration _cacheDuration = Duration(minutes: 5);

  FreediumUrlService(this._ref);

  Duration get _checkTimeout {
    final settings = _ref.read(settingsProvider);
    return Duration(seconds: settings.mirrorTimeout);
  }

  Future<String> getActiveUrl() async {
    final settings = _ref.read(settingsProvider);

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
      client = HttpClient();
      client.connectionTimeout = _checkTimeout;
      final probeResult = await _probeMirrorUrl(client, uri, _checkTimeout);
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
    final settings = _ref.read(settingsProvider);
    return isFreediumMirrorUrl(url, settings.mirrors);
  }
}

final freediumUrlServiceProvider = Provider(FreediumUrlService.new);

final activeFreediumUrlProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(freediumUrlServiceProvider);
  return service.getActiveUrl();
});
