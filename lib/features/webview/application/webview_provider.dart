import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/webview/application/theme_injector_service.dart';
import 'package:freedium_mobile/features/webview/domain/webview_state.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void onWebViewCreated(InAppWebViewController controller) {
    state = state.copyWith(controller: controller);
    _addJavaScriptHandlers();
  }

  void _addJavaScriptHandlers() {
    state.controller?.addJavaScriptHandler(
      handlerName: 'themeApplied',
      callback: (args) {
        state = state.copyWith(isThemeApplied: true);
        _updateInitialLoadState();
      },
    );

    state.controller?.addJavaScriptHandler(
      handlerName: 'Toaster',
      callback: (args) {
        if (args.isNotEmpty) {
          final message = switch (args) {
            [String text] => text,
            _ => args.toString(),
          };
          if (_context != null) {
            ScaffoldMessenger.of(
              _context!,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        }
      },
    );
  }

  void onLoadStop(InAppWebViewController controller, Uri? url) {
    state = state.copyWith(isPageLoaded: true);
    if (url != null && url.toString().startsWith(AppConstants.freediumUrl)) {
      _injectTheme(controller);
    } else {
      state = state.copyWith(isThemeApplied: false);
    }
    _updateInitialLoadState();
  }

  Future<void> _injectTheme(InAppWebViewController controller) async {
    if (_context == null) return;
    try {
      final script = await _themeInjector.getThemeInjectionScript(
        _context!,
        fontSize: state.fontSize,
      );
      controller.evaluateJavascript(source: script);
    } catch (e) {
      debugPrint('Failed to inject theme script: $e');
      state = state.copyWith(isThemeApplied: true);
    }
  }

  void onProgressChanged(InAppWebViewController controller, int progress) {
    state = state.copyWith(progress: progress / 100.0);
  }

  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction navigationAction,
  ) async {
    state = state.copyWith(
      isThemeApplied: false,
      isPageLoaded: false,
      progress: 0,
    );
    var uri = navigationAction.request.url!;
    if (!["http", "https"].contains(uri.scheme)) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return NavigationActionPolicy.CANCEL;
      }
    }

    final freediumUri = Uri.parse(AppConstants.freediumUrl);
    if (uri.host == freediumUri.host) {
      return NavigationActionPolicy.ALLOW;
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Failed to launch URL: $e');
      if (_context != null && _context!.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(content: Text('Could not open link: ${uri.toString()}')),
        );
      }
    }

    return NavigationActionPolicy.CANCEL;
  }

  void onReceivedError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  ) {
    debugPrint('Error loading page: ${error.description}');
    state = state.copyWith(
      isPageLoaded: true,
      isThemeApplied: false,
      progress: 1.0,
    );
    _updateInitialLoadState();
  }

  void onRenderProcessGone(
    InAppWebViewController controller,
    RenderProcessGoneDetail detail,
  ) {
    debugPrint('WebView renderer process crashed');

    state = state.copyWith(
      isPageLoaded: true,
      isThemeApplied: false,
      progress: 1.0,
    );
    _updateInitialLoadState();
    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: const Text('WebView renderer process crashed.'),
        action: SnackBarAction(
          label: 'Reload',
          onPressed: () {
            controller.reload();
          },
        ),
      ),
    );
  }

  void _updateInitialLoadState() {
    final bool isThemedPage =
        state.controller?.getUrl().toString().startsWith(
          AppConstants.freediumUrl,
        ) ??
        false;
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
      state.controller!.evaluateJavascript(source: script);
    }
  }
}

final webviewProvider =
    NotifierProvider.family<WebviewNotifier, WebviewState, String>(
      WebviewNotifier.new,
    );
