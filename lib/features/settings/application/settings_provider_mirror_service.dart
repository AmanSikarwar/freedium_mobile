part of 'settings_provider.dart';

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

extension SettingsMirrorReachability on Settings {
  Future<MirrorTestResult> _testMirror(String url) async {
    await _service();
    final stopwatch = Stopwatch()..start();
    HttpClient? client;

    try {
      final uri = Uri.parse(url);
      final timeout = Duration(seconds: _current.mirrorTimeout);
      client = _settingsRef.read(httpClientFactoryProvider)();
      client.connectionTimeout = timeout;

      final probeResult = await probeMirrorUrl(
        client,
        uri,
        timeout,
      ).timeout(timeout);

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
      client?.close(force: true);
    }
  }

  Future<String?> _findWorkingMirror() async {
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

    final budget = _checkTimeout;
    final elapsed = Stopwatch()..start();
    for (final mirror in mirrorsToCheck) {
      final remaining = budget - elapsed.elapsed;
      if (remaining <= Duration.zero) break;
      if (await _isUrlReachable(mirror.url, remaining)) {
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

  Future<bool> _isUrlReachable(String url, Duration timeout) async {
    HttpClient? client;
    try {
      final uri = Uri.parse(url);
      client = _ref.read(httpClientFactoryProvider)();
      client.connectionTimeout = timeout;
      final probeResult = await probeMirrorUrl(
        client,
        uri,
        timeout,
      ).timeout(timeout);
      return probeResult.isReachable;
    } catch (e) {
      debugPrint('URL reachability check failed for $url: $e');
      return false;
    } finally {
      client?.close(force: true);
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
