import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/webview/application/theme_injector_service.dart';
import 'package:freedium_mobile/features/webview/domain/webview_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebviewNotifier extends Notifier<WebviewState> {
  late ThemeInjectorService _themeInjector;
  late FontSizeService _fontSizeService;
  late FreediumUrlService _freediumUrlService;
  BuildContext? _context;
  final String url;
  int _currentMirrorIndex = 0;
  int _retryCount = 0;
  bool _hasSwitchedMirror = false;
  final Set<String> _articleRequestUrls = <String>{};
  static const int _maxRetries = 3;

  WebviewNotifier(this.url);

  @override
  WebviewState build() {
    final prefsAsync = ref.watch(sharedPreferencesProvider);
    _freediumUrlService = ref.read(freediumUrlServiceProvider);

    prefsAsync.whenData((prefs) {
      _fontSizeService = FontSizeService(prefs);
      final savedFontSize = _fontSizeService.loadFontSize();
      if (ref.mounted) {
        state = state.copyWith(fontSize: savedFontSize);
      }
    });

    ref.onDispose(() {
      final controller = state.controller;
      if (controller != null) {
        controller.removeJavaScriptChannel('themeApplied');
        controller.removeJavaScriptChannel('Toaster');
        controller.clearCache();
      }
    });

    return WebviewState();
  }

  void setThemeInjector(
    ThemeInjectorService themeInjector,
    BuildContext context,
  ) {
    _themeInjector = themeInjector;
    _context = context;
  }

  WebViewController createController({String? baseUrl}) {
    final activeBaseUrl = baseUrl ?? AppConstants.freediumUrl;
    final initialUrl = Uri.parse(activeBaseUrl).replace(path: url);
    _hasSwitchedMirror = false;
    _articleRequestUrls.clear();
    _rememberArticleRequestUrl(activeBaseUrl);
    _setCurrentMirrorIndex(activeBaseUrl);

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
          if (_context != null && _context!.mounted) {
            ScaffoldMessenger.of(
              _context!,
            ).showSnackBar(SnackBar(content: Text(message.message)));
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            state = state.copyWith(progress: progress / 100.0);
          },
          onPageStarted: (String url) {
            state = state.copyWith(
              isThemeApplied: false,
              isPageLoaded: false,
              progress: 0,
              currentUrl: url,
            );
          },
          onPageFinished: (String url) {
            state = state.copyWith(isPageLoaded: true, currentUrl: url);
            _retryCount = 0;
            if (_freediumUrlService.isFreediumUrl(url)) {
              _injectTheme();
            } else {
              state = state.copyWith(isThemeApplied: false);
            }
            _updateInitialLoadState();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error loading page: ${error.description}');
            _handleLoadError(error);
          },
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);

            if (!["http", "https"].contains(uri.scheme)) {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
                return NavigationDecision.prevent;
              }
            }

            if (_freediumUrlService.isFreediumHost(uri.host)) {
              return NavigationDecision.navigate;
            }

            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            } catch (e) {
              debugPrint('Failed to launch URL: $e');
              if (_context != null && _context!.mounted) {
                ScaffoldMessenger.of(_context!).showSnackBar(
                  SnackBar(
                    content: Text('Could not open link: ${uri.toString()}'),
                  ),
                );
              }
            }

            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(initialUrl);

    if (kDebugMode) {
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
    final articleUrl = Uri.parse(baseUrl).replace(path: url).toString();
    _articleRequestUrls.add(_normalizeUrl(articleUrl));
  }

  String _normalizeUrl(String value) {
    try {
      final uri = Uri.parse(value);
      final normalizedPath =
          uri.path.endsWith('/') && uri.path.length > 1
          ? uri.path.substring(0, uri.path.length - 1)
          : uri.path;
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

      if (_context != null && _context!.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text('Trying mirror: ${nextMirror.name}...'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      final newUrl = Uri.parse(nextMirror.url).replace(path: url);
      state = state.copyWith(activeBaseUrl: nextMirror.url);
      state.controller?.loadRequest(newUrl);
    } else {
      state = state.copyWith(
        isPageLoaded: true,
        isThemeApplied: false,
        progress: 1.0,
        hasError: true,
        errorMessage: error.description,
      );
      _updateInitialLoadState();
    }
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

    final newUrl = Uri.parse(nextMirror.url).replace(path: url);
    state.controller?.loadRequest(newUrl);
  }

  Future<void> _injectTheme() async {
    if (_context == null || state.controller == null) return;
    try {
      final colorScheme = Theme.of(_context!).colorScheme;
      final script = await _themeInjector.getThemeInjectionScript(
        colorScheme,
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

  Future<void> updateFontSize(double fontSize) async {
    state = state.copyWith(fontSize: fontSize);
    await _fontSizeService.saveFontSize(fontSize);

    if (state.controller != null && state.isPageLoaded) {
      final script = _themeInjector.getFontSizeUpdateScript(fontSize);
      state.controller!.runJavaScript(script);
    }
  }
}

final webviewProvider =
    NotifierProvider.family<WebviewNotifier, WebviewState, String>(
      WebviewNotifier.new,
    );
