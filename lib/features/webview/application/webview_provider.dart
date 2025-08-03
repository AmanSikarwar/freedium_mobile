import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/features/webview/application/theme_injector_service.dart';
import 'package:freedium_mobile/features/webview/domain/webview_state.dart';
import 'package:url_launcher/url_launcher.dart';

class WebviewNotifier extends StateNotifier<WebviewState> {
  late ThemeInjectorService _themeInjector;
  BuildContext? _context;

  WebviewNotifier() : super(WebviewState());

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
          final message = args[0] as String;
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
      final script = await _themeInjector.getThemeInjectionScript(_context!);
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
    return NavigationActionPolicy.ALLOW;
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
}

final webviewProvider = StateNotifierProvider.autoDispose
    .family<WebviewNotifier, WebviewState, String>((ref, url) {
      return WebviewNotifier();
    });
