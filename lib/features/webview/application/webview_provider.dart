import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart' show ColorScheme, Colors;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';
import 'package:freedium_mobile/core/utils/url.dart' show trimTrailingSlash;
import 'package:freedium_mobile/features/history/application/history_provider.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';
import 'package:freedium_mobile/features/webview/application/freedium_article_url_builder.dart';
import 'package:freedium_mobile/features/webview/application/theme_injector_service.dart';
import 'package:freedium_mobile/features/webview/application/webview_error_mapper.dart'
    show getUserFriendlyWebviewErrorMessage;
import 'package:freedium_mobile/features/webview/application/webview_navigation_policy.dart'
    show
        WebviewNavigationAction,
        buildReadingProgressRestoreScript,
        resolveWebviewNavigationAction;
import 'package:freedium_mobile/features/webview/domain/webview_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

export 'webview_error_mapper.dart' show getUserFriendlyWebviewErrorMessage;
export 'webview_navigation_policy.dart'
    show
        WebviewNavigationAction,
        buildReadingProgressRestoreScript,
        resolveWebviewNavigationAction;

part 'webview_provider.g.dart';

typedef ShareLauncher = Future<ShareResult> Function(ShareParams params);

@riverpod
class Webview extends _$Webview {
  late ThemeInjectorService _themeInjector;
  late FreediumUrlService _freediumUrlService;
  WebViewController? _controller;
  ColorScheme? _colorScheme;
  int _currentMirrorIndex = 0;
  int _retryCount = 0;
  bool _hasSwitchedMirror = false;
  final Set<String> _articleRequestUrls = <String>{};
  int _historyRecordToken = 0;
  bool _hasRecordedHistoryForCurrentPage = false;
  double _latestReadingProgress = 0;
  static const Duration _articleMetaWaitDuration = Duration(milliseconds: 900);
  static const int _maxRetries = 3;

  @override
  WebviewState build(String url) {
    _freediumUrlService = ref.read(freediumUrlServiceProvider);

    ref.listen<double>(
      settingsProvider.select(
        (settings) =>
            settings.value?.defaultFontSize ??
            SettingsState.defaultDefaultFontSize,
      ),
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
        controller.removeJavaScriptChannel('ReadingProgress');
        controller.clearCache();
      }
    });

    return WebviewState(
      fontSize: FontSizeService.normalizeFontSize(
        ref.read(settingsProvider).value?.defaultFontSize ??
            SettingsState.defaultDefaultFontSize,
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
        _controller == null ||
        currentUrl == null ||
        !_freediumUrlService.isFreediumUrl(currentUrl)) {
      return;
    }

    await _injectTheme();
  }

  /// Clears the one-shot [WebviewState.userMessage] after the screen has
  /// displayed it as a SnackBar.
  void clearUserMessage() {
    state = state.copyWith(userMessage: null);
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
      ..addJavaScriptChannel(
        'ReadingProgress',
        onMessageReceived: (JavaScriptMessage message) {
          _saveReadingProgress(message.message);
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
            _latestReadingProgress = 0;
            state = state.copyWith(
              isThemeApplied: false,
              isPageLoaded: false,
              progress: 0,
              currentUrl: url,
              hasError: false,
              errorMessage: null,
              articleMeta: null,
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
              await _restoreReadingProgress(url);
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

    state = state.copyWith(activeBaseUrl: activeBaseUrl);
    return controller;
  }

  void _setCurrentMirrorIndex(String baseUrl) {
    final mirrors =
        ref.read(settingsProvider).value?.mirrors ?? const <FreediumMirror>[];
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
      final normalizedPath = trimTrailingSlash(uri.path);
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
    final settings = ref.read(settingsProvider).value ?? const SettingsState();

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
      _controller?.loadRequest(newUrl);
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
    final controller = _controller;
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
      if (_latestReadingProgress > 0) {
        await ref
            .read(historyProvider.notifier)
            .updateReadingProgress(originalUrl, _latestReadingProgress);
      }
    } catch (e) {
      debugPrint('Failed to save history entry: $e');
      _hasRecordedHistoryForCurrentPage = false;
    }
  }

  void _saveReadingProgress(String message) {
    final currentUrl = state.currentUrl;
    final progress = double.tryParse(message);
    if (!ref.mounted ||
        currentUrl == null ||
        progress == null ||
        !_freediumUrlService.isFreediumUrl(currentUrl)) {
      return;
    }

    final normalizedProgress = normalizeReadingProgress(progress);
    if (normalizedProgress == 0) return;

    _latestReadingProgress = normalizedProgress;
    unawaited(
      ref
          .read(historyProvider.notifier)
          .updateReadingProgress(
            _extractOriginalUrl(currentUrl),
            normalizedProgress,
          ),
    );
  }

  Future<void> _restoreReadingProgress(String currentUrl) async {
    final progress = await ref
        .read(historyProvider.notifier)
        .readingProgressFor(_extractOriginalUrl(currentUrl));
    if (!ref.mounted ||
        state.currentUrl != currentUrl ||
        progress <= readingProgressRestoreThreshold ||
        progress >= readingCompletionThreshold) {
      return;
    }

    _latestReadingProgress = progress;
    try {
      await _controller?.runJavaScript(
        buildReadingProgressRestoreScript(progress),
      );
    } catch (e) {
      debugPrint('Failed to restore reading progress: $e');
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
    return getUserFriendlyWebviewErrorMessage(
      description: error.description,
      errorTypeLabel: error.errorType?.toString().split('.').last,
    );
  }

  Future<void> retryWithNextMirror() async {
    final settings = ref.read(settingsProvider).value ?? const SettingsState();
    if (settings.mirrors.isEmpty) {
      debugPrint('No mirrors available to retry');
      return;
    }
    _currentMirrorIndex = (_currentMirrorIndex + 1) % settings.mirrors.length;
    final nextMirror = settings.mirrors[_currentMirrorIndex];
    _hasSwitchedMirror = true;
    _rememberArticleRequestUrl(nextMirror.url);

    state = WebviewState(
      fontSize: state.fontSize,
      activeBaseUrl: nextMirror.url,
    );

    final newUrl = buildFreediumArticleUri(
      mirrorUrl: nextMirror.url,
      articleUrl: url,
    );
    _controller?.loadRequest(newUrl);
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
    if (_colorScheme == null || _controller == null) return;
    try {
      final script = await _themeInjector.getThemeInjectionScript(
        _colorScheme!,
        fontSize: state.fontSize,
        showSitePopups:
            ref.read(settingsProvider).value?.showSitePopups ?? true,
      );

      if (!ref.mounted) return;

      await _controller!.runJavaScript(script);
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
    return await _controller?.canGoBack() ?? false;
  }

  void goBack() {
    _controller?.goBack();
  }

  void reload() {
    _controller?.reload();
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
    final controller = _controller;
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

@Riverpod(keepAlive: true)
ThemeInjectorService themeInjectorService(Ref ref) => ThemeInjectorService();

@Riverpod(keepAlive: true)
ShareLauncher shareLauncher(Ref ref) => SharePlus.instance.share;
