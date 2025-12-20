import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';

class FreediumUrlService {
  String? _cachedWorkingUrl;
  DateTime? _lastCheckTime;

  static const Duration _cacheDuration = Duration(minutes: 5);

  static const Duration _checkTimeout = Duration(seconds: 5);

  Future<String> getActiveUrl() async {
    if (_cachedWorkingUrl != null &&
        _lastCheckTime != null &&
        DateTime.now().difference(_lastCheckTime!) < _cacheDuration) {
      return _cachedWorkingUrl!;
    }

    if (await _isUrlReachable(AppConstants.freediumUrl)) {
      _cachedWorkingUrl = AppConstants.freediumUrl;
      _lastCheckTime = DateTime.now();
      debugPrint('Using primary Freedium URL: ${AppConstants.freediumUrl}');
      return _cachedWorkingUrl!;
    }

    if (await _isUrlReachable(AppConstants.freediumMirrorUrl)) {
      _cachedWorkingUrl = AppConstants.freediumMirrorUrl;
      _lastCheckTime = DateTime.now();
      debugPrint(
        'Using mirror Freedium URL: ${AppConstants.freediumMirrorUrl}',
      );
      return _cachedWorkingUrl!;
    }

    debugPrint('Both Freedium URLs unreachable, defaulting to primary');
    _cachedWorkingUrl = AppConstants.freediumUrl;
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

  static bool isFreediumUrl(String url) {
    return url.startsWith(AppConstants.freediumUrl) ||
        url.startsWith(AppConstants.freediumMirrorUrl);
  }

  static bool isFreediumHost(String host) {
    final primaryHost = Uri.parse(AppConstants.freediumUrl).host;
    final mirrorHost = Uri.parse(AppConstants.freediumMirrorUrl).host;
    return host == primaryHost || host == mirrorHost;
  }
}

final freediumUrlServiceProvider = Provider((ref) => FreediumUrlService());

final activeFreediumUrlProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(freediumUrlServiceProvider);
  return service.getActiveUrl();
});
