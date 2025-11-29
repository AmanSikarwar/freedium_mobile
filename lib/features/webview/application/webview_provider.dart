import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/webview/application/theme_injector_service.dart';
import 'package:freedium_mobile/features/webview/domain/webview_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebviewNotifier extends Notifier<WebviewState> {
  late ThemeInjectorService _themeInjector;
  final FontSizeService _fontSizeService = FontSizeService();
  BuildContext? _context;
  final String url;

  WebviewNotifier(this.url);

  @override
  WebviewState build() {
    _loadFontSize();
    return WebviewState();
  }

  Future<void> _loadFontSize() async {
    final savedFontSize = await _fontSizeService.loadFontSize();
    state = state.copyWith(fontSize: savedFontSize);
  }

  void setThemeInjector(
    ThemeInjectorService themeInjector,
    BuildContext context,
  ) {
    _themeInjector = themeInjector;
    _context = context;
  }

  WebViewController createController() {
    final initialUrl = Uri.parse(AppConstants.freediumUrl).replace(path: url);

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
            if (url.startsWith(AppConstants.freediumUrl)) {
              _injectTheme();
            } else {
              state = state.copyWith(isThemeApplied: false);
            }
            _updateInitialLoadState();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Error loading page: ${error.description}');
            state = state.copyWith(
              isPageLoaded: true,
              isThemeApplied: false,
              progress: 1.0,
            );
            _updateInitialLoadState();
          },
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);

            if (!["http", "https"].contains(uri.scheme)) {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
                return NavigationDecision.prevent;
              }
            }

            final freediumUri = Uri.parse(AppConstants.freediumUrl);
            if (uri.host == freediumUri.host) {
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

    // Enable debugging in debug mode for Android
    if (kDebugMode) {
      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);
      }
    }

    state = state.copyWith(controller: controller);
    return controller;
  }

  Future<void> _injectTheme() async {
    if (_context == null || state.controller == null) return;
    try {
      final script = await _themeInjector.getThemeInjectionScript(
        _context!,
        fontSize: state.fontSize,
      );
      state.controller!.runJavaScript(script);
    } catch (e) {
      debugPrint('Failed to inject theme script: $e');
      state = state.copyWith(isThemeApplied: true);
    }
  }

  void _updateInitialLoadState() {
    final bool isThemedPage =
        state.currentUrl?.startsWith(AppConstants.freediumUrl) ?? false;
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
