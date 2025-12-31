import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/settings/application/settings_service.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

class SettingsNotifier extends Notifier<SettingsState> {
  late SettingsService _settingsService;

  @override
  SettingsState build() {
    final prefsAsync = ref.watch(sharedPreferencesProvider);

    return prefsAsync.when(
      data: (prefs) {
        _settingsService = SettingsService(prefs);
        return _settingsService.loadAllSettings();
      },
      loading: () => const SettingsState(),
      error: (_, _) => const SettingsState(),
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _settingsService.saveThemeMode(themeMode);
  }

  Future<void> setDefaultFontSize(double fontSize) async {
    state = state.copyWith(defaultFontSize: fontSize);
    await _settingsService.saveDefaultFontSize(fontSize);
  }

  Future<void> addMirror(FreediumMirror mirror) async {
    final updatedMirrors = [...state.mirrors, mirror];
    state = state.copyWith(mirrors: updatedMirrors);
    await _settingsService.saveMirrors(updatedMirrors);
  }

  Future<void> removeMirror(FreediumMirror mirror) async {
    if (mirror.isDefault) return;
    final updatedMirrors = state.mirrors.where((m) => m != mirror).toList();
    state = state.copyWith(mirrors: updatedMirrors);
    await _settingsService.saveMirrors(updatedMirrors);

    if (state.selectedMirrorUrl == mirror.url && updatedMirrors.isNotEmpty) {
      await setSelectedMirror(updatedMirrors.first.url);
    }
  }

  Future<void> updateMirror(
    FreediumMirror oldMirror,
    FreediumMirror newMirror,
  ) async {
    final updatedMirrors = state.mirrors.map((m) {
      if (m == oldMirror) return newMirror;
      return m;
    }).toList();
    state = state.copyWith(mirrors: updatedMirrors);
    await _settingsService.saveMirrors(updatedMirrors);

    if (state.selectedMirrorUrl == oldMirror.url) {
      await setSelectedMirror(newMirror.url);
    }
  }

  Future<void> setSelectedMirror(String url) async {
    state = state.copyWith(selectedMirrorUrl: url);
    await _settingsService.saveSelectedMirrorUrl(url);
    ref.read(freediumUrlServiceProvider).invalidateCache();
  }

  Future<void> setAutoSwitchMirror(bool autoSwitch) async {
    state = state.copyWith(autoSwitchMirror: autoSwitch);
    await _settingsService.saveAutoSwitchMirror(autoSwitch);
  }

  Future<void> setMirrorTimeout(int timeout) async {
    state = state.copyWith(mirrorTimeout: timeout);
    await _settingsService.saveMirrorTimeout(timeout);
  }

  Future<void> resetToDefaults() async {
    final defaultState = SettingsState(
      mirrors: SettingsState.defaultMirrors,
      selectedMirrorUrl: SettingsState.defaultMirrors.first.url,
    );
    state = defaultState;
    await _settingsService.saveThemeMode(defaultState.themeMode);
    await _settingsService.saveDefaultFontSize(defaultState.defaultFontSize);
    await _settingsService.saveMirrors(defaultState.mirrors);
    await _settingsService.saveSelectedMirrorUrl(
      defaultState.selectedMirrorUrl,
    );
    await _settingsService.saveAutoSwitchMirror(defaultState.autoSwitchMirror);
    await _settingsService.saveMirrorTimeout(defaultState.mirrorTimeout);
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
