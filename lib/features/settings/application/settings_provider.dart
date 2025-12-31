import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/settings/application/settings_service.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

class SettingsNotifier extends Notifier<SettingsState> {
  SettingsService? _settingsService;

  SettingsService _requireSettingsService() {
    final service = _settingsService;
    if (service == null) {
      throw StateError(
        'SettingsService is not available. SharedPreferences may still be loading or failed to initialize.',
      );
    }
    return service;
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
    final service = _requireSettingsService();
    state = state.copyWith(themeMode: themeMode);
    await service.saveThemeMode(themeMode);
  }

  Future<void> setDefaultFontSize(double fontSize) async {
    final service = _requireSettingsService();
    state = state.copyWith(defaultFontSize: fontSize);
    await service.saveDefaultFontSize(fontSize);
  }

  Future<void> addMirror(FreediumMirror mirror) async {
    final service = _requireSettingsService();
    final updatedMirrors = [...state.mirrors, mirror];
    state = state.copyWith(mirrors: updatedMirrors);
    await service.saveMirrors(updatedMirrors);
  }

  Future<void> removeMirror(FreediumMirror mirror) async {
    if (mirror.isDefault) return;
    final service = _requireSettingsService();
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
    final service = _requireSettingsService();
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
    final service = _requireSettingsService();
    state = state.copyWith(selectedMirrorUrl: url);
    await service.saveSelectedMirrorUrl(url);
    ref.read(freediumUrlServiceProvider).invalidateCache();
  }

  Future<void> setAutoSwitchMirror(bool autoSwitch) async {
    final service = _requireSettingsService();
    state = state.copyWith(autoSwitchMirror: autoSwitch);
    await service.saveAutoSwitchMirror(autoSwitch);
  }

  Future<void> setMirrorTimeout(int timeout) async {
    final service = _requireSettingsService();
    state = state.copyWith(mirrorTimeout: timeout);
    await service.saveMirrorTimeout(timeout);
  }

  Future<void> resetToDefaults() async {
    final service = _requireSettingsService();
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
    final stopwatch = Stopwatch()..start();
    HttpClient? client;

    try {
      final uri = Uri.parse(url);
      client = HttpClient();
      client.connectionTimeout = Duration(seconds: state.mirrorTimeout);

      final request = await client
          .headUrl(uri)
          .timeout(Duration(seconds: state.mirrorTimeout));
      final response = await request.close().timeout(
        Duration(seconds: state.mirrorTimeout),
      );

      stopwatch.stop();

      if (response.statusCode >= 200 && response.statusCode < 400) {
        return MirrorTestResult(
          isReachable: true,
          responseTimeMs: stopwatch.elapsedMilliseconds,
          statusCode: response.statusCode,
        );
      } else {
        return MirrorTestResult(
          isReachable: false,
          responseTimeMs: stopwatch.elapsedMilliseconds,
          statusCode: response.statusCode,
          error: 'HTTP ${response.statusCode}',
        );
      }
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

    for (final mirror in settings.mirrors) {
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

      final request = await client.headUrl(uri).timeout(_checkTimeout);
      final response = await request.close().timeout(_checkTimeout);

      return response.statusCode >= 200 && response.statusCode < 400;
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
