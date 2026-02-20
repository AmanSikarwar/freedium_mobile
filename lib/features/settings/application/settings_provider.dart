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

  final getResult = await _sendProbeRequest(
    client,
    uri,
    timeout,
    useGet: true,
  );

  if (getResult.isReachable) {
    return getResult;
  }

  if (getResult.statusCode != null || getResult.error != null) {
    return getResult;
  }

  return headResult;
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

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final service = await _ensureSettingsService();
    if (service == null) return;
    state = state.copyWith(themeMode: themeMode);
    await service.saveThemeMode(themeMode);
  }

  Future<void> setDefaultFontSize(double fontSize) async {
    final service = await _ensureSettingsService();
    if (service == null) return;
    state = state.copyWith(defaultFontSize: fontSize);
    await service.saveDefaultFontSize(fontSize);
  }

  Future<void> addMirror(FreediumMirror mirror) async {
    final service = await _ensureSettingsService();
    if (service == null) return;
    final updatedMirrors = [...state.mirrors, mirror];
    state = state.copyWith(mirrors: updatedMirrors);
    await service.saveMirrors(updatedMirrors);
  }

  Future<void> removeMirror(FreediumMirror mirror) async {
    if (mirror.isDefault) return;
    final service = await _ensureSettingsService();
    if (service == null) return;
    final updatedMirrors = state.mirrors.where((m) => m != mirror).toList();
    state = state.copyWith(mirrors: updatedMirrors);
    await service.saveMirrors(updatedMirrors);

    if (state.selectedMirrorUrl == mirror.url && updatedMirrors.isNotEmpty) {
      await setSelectedMirror(updatedMirrors.first.url);
    }
  }

  Future<void> updateMirror(
    FreediumMirror oldMirror,
    FreediumMirror newMirror,
  ) async {
    final service = await _ensureSettingsService();
    if (service == null) return;
    final updatedMirrors = state.mirrors.map((m) {
      if (m == oldMirror) return newMirror;
      return m;
    }).toList();
    state = state.copyWith(mirrors: updatedMirrors);
    await service.saveMirrors(updatedMirrors);

    if (state.selectedMirrorUrl == oldMirror.url) {
      await setSelectedMirror(newMirror.url);
    }
  }

  Future<void> setSelectedMirror(String url) async {
    final service = await _ensureSettingsService();
    if (service == null) return;
    state = state.copyWith(selectedMirrorUrl: url);
    await service.saveSelectedMirrorUrl(url);
    ref.read(freediumUrlServiceProvider).invalidateCache();
  }

  Future<void> setAutoSwitchMirror(bool autoSwitch) async {
    final service = await _ensureSettingsService();
    if (service == null) return;
    state = state.copyWith(autoSwitchMirror: autoSwitch);
    await service.saveAutoSwitchMirror(autoSwitch);
  }

  Future<void> setMirrorTimeout(int timeout) async {
    final service = await _ensureSettingsService();
    if (service == null) return;
    state = state.copyWith(mirrorTimeout: timeout);
    await service.saveMirrorTimeout(timeout);
  }

  Future<void> resetToDefaults() async {
    final service = await _ensureSettingsService();
    if (service == null) return;
    final defaultState = SettingsState(
      mirrors: SettingsState.defaultMirrors,
      selectedMirrorUrl: SettingsState.defaultMirrors.first.url,
    );
    state = defaultState;
    await service.saveThemeMode(defaultState.themeMode);
    await service.saveDefaultFontSize(defaultState.defaultFontSize);
    await service.saveMirrors(defaultState.mirrors);
    await service.saveSelectedMirrorUrl(defaultState.selectedMirrorUrl);
    await service.saveAutoSwitchMirror(defaultState.autoSwitchMirror);
    await service.saveMirrorTimeout(defaultState.mirrorTimeout);
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
    for (final mirror in settings.mirrors) {
      if (url.startsWith(mirror.url)) {
        return true;
      }
    }
    return false;
  }

  bool isFreediumHost(String host) {
    final settings = _ref.read(settingsProvider);
    for (final mirror in settings.mirrors) {
      final mirrorHost = Uri.parse(mirror.url).host;
      if (host == mirrorHost) {
        return true;
      }
    }
    return false;
  }
}

final freediumUrlServiceProvider = Provider(FreediumUrlService.new);

final activeFreediumUrlProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(freediumUrlServiceProvider);
  return service.getActiveUrl();
});
