import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ColorScheme, Colors;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/webview/application/freedium_article_url_builder.dart';
import 'package:freedium_mobile/features/webview/application/theme_injector_service.dart';
import 'package:freedium_mobile/features/webview/domain/webview_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

typedef ShareLauncher = Future<ShareResult> Function(ShareParams params);

@visibleForTesting
enum WebviewNavigationAction { navigate, launchExternal, block }

@visibleForTesting
WebviewNavigationAction resolveWebviewNavigationAction({
  required String requestUrl,
  required bool Function(String url) isFreediumUrl,
}) {
  final uri = parseExternalHttpUrl(requestUrl);
  if (uri == null) {
    return WebviewNavigationAction.block;
  }

  if (isFreediumUrl(uri.toString())) {
    return WebviewNavigationAction.navigate;
  }

  return WebviewNavigationAction.launchExternal;
}

class WebviewNotifier extends Notifier<WebviewState> {
  late ThemeInjectorService _themeInjector;
  late FreediumUrlService _freediumUrlService;
  WebViewController? _controller;
  ColorScheme? _colorScheme;
  final String url;
  int _currentMirrorIndex = 0;
  int _retryCount = 0;
  bool _hasSwitchedMirror = false;
  final Set<String> _articleRequestUrls = <String>{};
  int _historyRecordToken = 0;
  bool _hasRecordedHistoryForCurrentPage = false;
  static const Duration _articleMetaWaitDuration = Duration(milliseconds: 900);
  static const int _maxRetries = 3;

  WebviewNotifier(this.url);

  @override
  WebviewState build() {
    _freediumUrlService = ref.read(freediumUrlServiceProvider);

    ref.listen<double>(
      settingsProvider.select((settings) => settings.defaultFontSize),
      (previous, next) {
        final normalizedFontSize = FontSizeService.normalizeFontSize(next);
        if (!ref.mounted || state.fontSize == normalizedFontSize) {
          return;
        }
        unawaited(_applyFontSize(normalizedFontSize));
      },
    );

    ref.onDispose(() {
      final controller = _controller;
      if (controller != null) {
        controller.removeJavaScriptChannel('themeApplied');
        controller.removeJavaScriptChannel('Toaster');
        controller.removeJavaScriptChannel('ArticleMeta');
        controller.clearCache();
      }
    });

    return WebviewState(
      fontSize: FontSizeService.normalizeFontSize(
        ref.read(settingsProvider).defaultFontSize,
      ),
    );
  }

  void setThemeInjector(ThemeInjectorService themeInjector) {
    _themeInjector = themeInjector;
  }

  /// Called from the screen's build method to keep the color scheme in sync
  /// without storing a BuildContext in the notifier.
  Future<void> updateColorScheme(ColorScheme colorScheme) async {
    _colorScheme = colorScheme;

    final currentUrl = state.currentUrl;
    if (!ref.mounted ||
        state.controller == null ||
        currentUrl == null ||
        !_freediumUrlService.isFreediumUrl(currentUrl)) {
      return;
    }

    await _injectTheme();
  }

  /// Clears the one-shot [WebviewState.userMessage] after the screen has
  /// displayed it as a SnackBar.
  void clearUserMessage() {
    state = state.copyWith(clearUserMessage: true);
  }

  WebViewController createController({String? baseUrl}) {
    final activeBaseUrl = baseUrl ?? AppConstants.freediumUrl;
    final initialUrl = buildFreediumArticleUri(
      mirrorUrl: activeBaseUrl,
      articleUrl: url,
    );
    _hasSwitchedMirror = false;
    _articleRequestUrls.clear();
    _rememberArticleRequestUrl(activeBaseUrl);
    _setCurrentMirrorIndex(activeBaseUrl);

    final controller = WebViewController();
    _controller = controller;
    controller
      ..setJavaScriptMode(.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'themeApplied',
        onMessageReceived: (JavaScriptMessage message) {
          state = state.copyWith(isThemeApplied: true);
          _updateInitialLoadState();
        },
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          state = state.copyWith(userMessage: message.message);
        },
      )
      ..addJavaScriptChannel(
        'ArticleMeta',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message) as Map<String, dynamic>;
            state = state.copyWith(
              articleMeta: ArticleMeta(
                title: (data['title'] as String? ?? '').trim(),
                author: (data['author'] as String? ?? '').trim(),
                readTime: (data['readTime'] as String? ?? '').trim(),
                heroImageUrl: (data['heroImageUrl'] as String? ?? '').trim(),
              ),
            );
            final currentUrl = state.currentUrl;
            if (currentUrl != null && currentUrl.isNotEmpty) {
              unawaited(_recordHistoryWhenReady(currentUrl));
            }
          } catch (e) {
            debugPrint('Failed to parse ArticleMeta: $e');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            state = state.copyWith(progress: progress / 100.0);
          },
          onPageStarted: (String url) {
            _historyRecordToken++;
            _hasRecordedHistoryForCurrentPage = false;
            state = state.copyWith(
              isThemeApplied: false,
              isPageLoaded: false,
              progress: 0,
              currentUrl: url,
              hasError: false,
              clearErrorMessage: true,
              clearArticleMeta: true,
            );
            // Inject the pre-theme script as early as possible so the page's
            // own inline scripts read the correct localStorage.theme value and
            // the 'dark' class is already present on <html> on first render.
            if (_colorScheme != null &&
                _freediumUrlService.isFreediumUrl(url)) {
              final preScript = _themeInjector.getPreThemeScript(_colorScheme!);
              controller
                  .runJavaScript(preScript)
                  .catchError(
                    (e) => debugPrint('Pre-theme injection failed: $e'),
                  );
            }
          },
          onPageFinished: (String url) async {
            state = state.copyWith(isPageLoaded: true, currentUrl: url);
            if (_freediumUrlService.isFreediumUrl(url)) {
              _retryCount = 0;
              await _injectTheme();
              await _recordHistoryWhenReady(url);
            } else {
              state = state.copyWith(isThemeApplied: false);
            }
            _updateInitialLoadState();
          },
          onWebResourceError: (WebResourceError error) {
            final isMainFrame = error.isForMainFrame ?? true;
            if (isMainFrame) {
              debugPrint('Error loading page: ${error.description}');
              _handleLoadError(error);
            } else {
              debugPrint('Resource error ignored: ${error.description}');
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final action = resolveWebviewNavigationAction(
              requestUrl: request.url,
              isFreediumUrl: _freediumUrlService.isFreediumUrl,
            );

            switch (action) {
              case WebviewNavigationAction.navigate:
                return .navigate;
              case WebviewNavigationAction.launchExternal:
                final launched = await launchExternalHttpUrl(request.url);
                if (!launched && ref.mounted) {
                  state = state.copyWith(
                    userMessage: 'Could not open link: ${request.url.trim()}',
                  );
                }
                return .prevent;
              case WebviewNavigationAction.block:
                debugPrint(
                  'Blocked unsupported WebView navigation: ${request.url}',
                );
                return .prevent;
            }
          },
        ),
      )
      ..loadRequest(initialUrl);

    if (kDebugMode && Platform.isAndroid) {
      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);
      }
    }

    state = state.copyWith(
      controller: controller,
      activeBaseUrl: activeBaseUrl,
    );
    return controller;
  }

  void _setCurrentMirrorIndex(String baseUrl) {
    final mirrors = ref.read(settingsProvider).mirrors;
    final mirrorIndex = mirrors.indexWhere((mirror) => mirror.url == baseUrl);
    _currentMirrorIndex = mirrorIndex >= 0 ? mirrorIndex : 0;
  }

  void _rememberArticleRequestUrl(String baseUrl) {
    final articleUrl = buildFreediumArticleUri(
      mirrorUrl: baseUrl,
      articleUrl: url,
    ).toString();
    _articleRequestUrls.add(_normalizeUrl(articleUrl));
  }

  String _normalizeUrl(String value) {
    try {
      final uri = Uri.parse(value);
      var normalizedPath = uri.path;
      while (normalizedPath.length > 1 && normalizedPath.endsWith('/')) {
        normalizedPath = normalizedPath.substring(0, normalizedPath.length - 1);
      }
      return uri.replace(path: normalizedPath, fragment: '').toString();
    } catch (_) {
      return value;
    }
  }

  bool shouldUseAppLevelBackNavigation() {
    if (!_hasSwitchedMirror) return false;
    final currentUrl = state.currentUrl;
    if (currentUrl == null || currentUrl.isEmpty) return false;
    return _articleRequestUrls.contains(_normalizeUrl(currentUrl));
  }

  Future<void> _handleLoadError(WebResourceError error) async {
    final settings = ref.read(settingsProvider);

    if (settings.autoSwitchMirror &&
        _retryCount < _maxRetries &&
        settings.mirrors.isNotEmpty) {
      _retryCount++;
      _currentMirrorIndex = (_currentMirrorIndex + 1) % settings.mirrors.length;

      final nextMirror = settings.mirrors[_currentMirrorIndex];
      debugPrint(
        'Trying fallback mirror: ${nextMirror.url} (attempt $_retryCount)',
      );
      _hasSwitchedMirror = true;
      _rememberArticleRequestUrl(nextMirror.url);

      state = state.copyWith(
        userMessage: 'Trying mirror: ${nextMirror.name}...',
      );

      final newUrl = buildFreediumArticleUri(
        mirrorUrl: nextMirror.url,
        articleUrl: url,
      );
      state = state.copyWith(activeBaseUrl: nextMirror.url);
      state.controller?.loadRequest(newUrl);
    } else {
      state = state.copyWith(
        isPageLoaded: true,
        isThemeApplied: false,
        progress: 1.0,
        hasError: true,
        errorMessage: _getUserFriendlyErrorMessage(error),
      );
      _updateInitialLoadState();
    }
  }

  Future<void> _recordHistoryWhenReady(String currentUrl) async {
    final controller = state.controller;
    if (controller == null || !_freediumUrlService.isFreediumUrl(currentUrl)) {
      return;
    }

    final originalUrl = _extractOriginalUrl(currentUrl);
    final token = _historyRecordToken;
    if (_hasRecordedHistoryForCurrentPage) return;

    final initialMetaTitle = state.articleMeta?.title.trim() ?? '';
    if (initialMetaTitle.isEmpty) {
      await Future<void>.delayed(_articleMetaWaitDuration);
      if (!ref.mounted ||
          token != _historyRecordToken ||
          _hasRecordedHistoryForCurrentPage) {
        return;
      }
    }

    final metaTitle = state.articleMeta?.title.trim() ?? '';
    final title = metaTitle.isNotEmpty
        ? metaTitle
        : ((await controller.getTitle()) ?? '').trim();

    if (!ref.mounted ||
        token != _historyRecordToken ||
        _hasRecordedHistoryForCurrentPage ||
        title.isEmpty) {
      return;
    }

    _hasRecordedHistoryForCurrentPage = true;
    try {
      await ref.read(historyProvider.notifier).addHistory(originalUrl, title);
    } catch (e) {
      debugPrint('Failed to save history entry: $e');
      _hasRecordedHistoryForCurrentPage = false;
    }
  }

  String _extractOriginalUrl(String fullUrl) {
    try {
      if (!_freediumUrlService.isFreediumUrl(fullUrl)) {
        return fullUrl;
      }

      return extractOriginalArticleUrlFromFreediumUri(
            mirrorUrl: state.activeBaseUrl,
            freediumUrl: fullUrl,
          ) ??
          url;
    } catch (e) {
      return url;
    }
  }

  String _getUserFriendlyErrorMessage(WebResourceError error) {
    final rawDescription = error.description.toLowerCase();

    // Android (Chromium) errors
    if (rawDescription.contains('err_internet_disconnected')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (rawDescription.contains('err_name_not_resolved') ||
        rawDescription.contains('err_connection_refused') ||
        rawDescription.contains('err_connection_timed_out') ||
        rawDescription.contains('err_connection_reset')) {
      return 'Could not connect to the server. The current mirror might be down or blocked.';
    } else if (rawDescription.contains('err_cert_') ||
        rawDescription.contains('ssl')) {
      return 'Security certificate issue with the server. Connection might not be secure.';
    }

    // iOS (WebKit) errors
    if (rawDescription.contains('nsurlerrordomain') ||
        rawDescription.contains('webkit')) {
      if (rawDescription.contains('-1009')) {
        return 'No internet connection. Please check your network and try again.';
      } else if (rawDescription.contains('-1001') ||
          rawDescription.contains('-1003') ||
          rawDescription.contains('-1004')) {
        return 'Could not connect to the server. The current mirror might be down or timed out.';
      } else if (rawDescription.contains('-1200') ||
          rawDescription.contains('-1202')) {
        return 'A secure connection could not be established with the server.';
      }
    }

    // Default formatting if it doesn't match known patterns
    if (error.errorType != null) {
      final typeString = error.errorType.toString().split('.').last;
      return 'Connection failed: $typeString\n\nPlease try another mirror.';
    }

    return 'Failed to load page.\n\nPlease try another mirror or check your connection.';
  }

  Future<void> retryWithNextMirror() async {
    final settings = ref.read(settingsProvider);
    if (settings.mirrors.isEmpty) {
      debugPrint('No mirrors available to retry');
      return;
    }
    _currentMirrorIndex = (_currentMirrorIndex + 1) % settings.mirrors.length;
    final nextMirror = settings.mirrors[_currentMirrorIndex];
    _hasSwitchedMirror = true;
    _rememberArticleRequestUrl(nextMirror.url);

    state = WebviewState(
      controller: state.controller,
      fontSize: state.fontSize,
      activeBaseUrl: nextMirror.url,
    );

    final newUrl = buildFreediumArticleUri(
      mirrorUrl: nextMirror.url,
      articleUrl: url,
    );
    state.controller?.loadRequest(newUrl);
  }

  Future<void> shareArticle() async {
    final shareUri = buildFreediumArticleUri(
      mirrorUrl: state.activeBaseUrl,
      articleUrl: url,
    );

    try {
      final result = await ref.read(shareLauncherProvider)(
        ShareParams(
          subject: 'Read this article without Paywall',
          title: 'Share Freedium link',
          uri: shareUri,
        ),
      );
      if (!ref.mounted || result.status != ShareResultStatus.unavailable) {
        return;
      }

      state = state.copyWith(userMessage: 'Could not share article');
    } catch (e) {
      debugPrint('Failed to share article: $e');
      if (ref.mounted) {
        state = state.copyWith(userMessage: 'Could not share article');
      }
    }
  }

  Future<void> _injectTheme() async {
    if (_colorScheme == null || state.controller == null) return;
    try {
      final script = await _themeInjector.getThemeInjectionScript(
        _colorScheme!,
        fontSize: state.fontSize,
      );

      if (!ref.mounted) return;

      await state.controller!.runJavaScript(script);
    } catch (e) {
      debugPrint('Failed to inject theme script: $e');
      if (ref.mounted) {
        state = state.copyWith(isThemeApplied: false);
      }
    }
  }

  void _updateInitialLoadState() {
    final bool isThemedPage = _freediumUrlService.isFreediumUrl(
      state.currentUrl ?? '',
    );
    if (state.isInitialLoad &&
        state.isPageLoaded &&
        (isThemedPage ? state.isThemeApplied : true)) {
      state = state.copyWith(isInitialLoad: false);
    }
  }

  Future<bool> canGoBack() async {
    return await state.controller?.canGoBack() ?? false;
  }

  void goBack() {
    state.controller?.goBack();
  }

  void reload() {
    state.controller?.reload();
  }

  Future<bool> updateFontSize(double fontSize) async {
    final normalizedFontSize = FontSizeService.normalizeFontSize(fontSize);
    final didSave = await ref
        .read(settingsProvider.notifier)
        .setDefaultFontSize(normalizedFontSize);
    if (!didSave) {
      state = state.copyWith(userMessage: 'Failed to save font size');
      return false;
    }

    if (state.fontSize != normalizedFontSize) {
      await _applyFontSize(normalizedFontSize);
    }

    return true;
  }

  Future<void> _applyFontSize(double fontSize) async {
    final normalizedFontSize = FontSizeService.normalizeFontSize(fontSize);
    state = state.copyWith(fontSize: normalizedFontSize);
    final controller = state.controller;
    if (controller != null && state.isPageLoaded) {
      final script = _themeInjector.getFontSizeUpdateScript(normalizedFontSize);
      try {
        await controller.runJavaScript(script);
      } catch (e) {
        debugPrint('Failed to update font size script: $e');
      }
    }
  }
}

final webviewProvider =
    NotifierProvider.family<WebviewNotifier, WebviewState, String>(
      WebviewNotifier.new,
    );

final themeInjectorServiceProvider = Provider((ref) => ThemeInjectorService());

final shareLauncherProvider = Provider<ShareLauncher>(
  (ref) => SharePlus.instance.share,
);
