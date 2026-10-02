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
part 'webview_controller.dart';
part 'webview_loading.dart';
part 'webview_history.dart';
part 'webview_styling.dart';
part 'webview_actions.dart';

typedef ShareLauncher = Future<ShareResult> Function(ShareParams params);

@riverpod
class Webview() extends _$Webview {
  late ThemeInjectorService _themeInjector;
  late FreediumUrlService _freediumUrlService;
  WebViewController? _controller;
  ColorScheme? _colorScheme;
  int _currentMirrorIndex = 0;
  int _retryCount = 0;
  bool _hasSwitchedMirror = false;
  final Set<String> _articleRequestUrls = <String>{};
  final Set<String> _failedPageUrls = <String>{};
  int _historyRecordToken = 0;
  bool _hasRecordedHistoryForCurrentPage = false;
  double _latestReadingProgress = 0;
  bool _themeFailed = false;
  Timer? _themeAckTimer;
  Timer? _pageLoadTimer;
  static const Duration _articleMetaWaitDuration = Duration(milliseconds: 900);
  static const int _maxRetries = 3;

  WebviewState get _readerState => state;
  set _readerState(WebviewState value) => state = value;
  Ref get _readerRef => ref;

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
      _themeAckTimer?.cancel();
      _pageLoadTimer?.cancel();
      final controller = _controller;
      if (controller != null) {
        controller.removeJavaScriptChannel('themeApplied');
        controller.removeJavaScriptChannel('Toaster');
        controller.removeJavaScriptChannel('ArticleMeta');
        controller.removeJavaScriptChannel('ReadingProgress');
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

  WebViewController createController({String? baseUrl}) =>
      _createController(baseUrl: baseUrl);

  void _setCurrentMirrorIndex(String baseUrl) {
    final mirrors =
        ref.read(settingsProvider).value?.mirrors ?? const <FreediumMirror>[];
    final mirrorIndex = mirrors.indexWhere((mirror) => mirror.url == baseUrl);
    _currentMirrorIndex = mirrorIndex >= 0 ? mirrorIndex : 0;
  }

  void _rememberArticleRequestUrl(String baseUrl) {
    final requestUrl = buildFreediumArticleUri(
      mirrorUrl: baseUrl,
      articleUrl: articleUrl(),
    ).toString();
    _articleRequestUrls.add(_normalizeUrl(requestUrl));
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

  String articleUrl() => _extractOriginalUrl(state.currentUrl ?? url);

  String _extractOriginalUrl(String fullUrl) {
    final original = canonicalArticleUrl(
      fullUrl,
      mirrorUrls: [
        state.activeBaseUrl,
        ...?ref
            .read(settingsProvider)
            .value
            ?.mirrors
            .map((mirror) => mirror.url),
      ],
    );
    return _freediumUrlService.isFreediumUrl(original)
        ? canonicalArticleUrl(url, mirrorUrls: [state.activeBaseUrl])
        : original;
  }

  String _getUserFriendlyErrorMessage(WebResourceError error) {
    return getUserFriendlyWebviewErrorMessage(
      description: error.description,
      errorTypeLabel: error.errorType?.toString().split('.').last,
    );
  }

  bool canContinueWithoutStyling() => _themeFailed && state.isPageLoaded;

  void continueWithoutStyling() {
    if (!canContinueWithoutStyling()) return;
    _themeAckTimer?.cancel();
    _themeFailed = false;
    state = state.copyWith(
      hasError: false,
      errorMessage: null,
      useOriginalStyling: true,
      isInitialLoad: false,
    );
  }
}

@Riverpod(keepAlive: true)
ThemeInjectorService themeInjectorService(Ref ref) => ThemeInjectorService();

@Riverpod(keepAlive: true)
ShareLauncher shareLauncher(Ref ref) => SharePlus.instance.share;
