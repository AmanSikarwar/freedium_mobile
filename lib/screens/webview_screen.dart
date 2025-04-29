import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({required this.url, super.key});

  final String url;

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  InAppWebViewController? _controller;
  bool _pageLoaded = false;
  bool _themeApplied = false;
  bool _isInitialLoad = true;
  double _progress = 0;
  final GlobalKey webViewKey = GlobalKey();
  PullToRefreshController? _pullToRefreshController;

  static const String _urlPrefix = 'https://freedium.cfd';

  String _getThemeInjectionScript() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    String colorToHex(Color color) =>
        '#${(color.r * 255).round().toRadixString(16).padLeft(2, '0')}${(color.g * 255).round().toRadixString(16).padLeft(2, '0')}${(color.b * 255).round().toRadixString(16).padLeft(2, '0')}';

    final cssVars = '''
      :root {
        --app-primary: ${colorToHex(colorScheme.primary)};
        --app-on-primary: ${colorToHex(colorScheme.onPrimary)};
        --app-primary-container: ${colorToHex(colorScheme.primaryContainer)};
        --app-on-primary-container: ${colorToHex(colorScheme.onPrimaryContainer)};
        --app-secondary: ${colorToHex(colorScheme.secondary)};
        --app-on-secondary: ${colorToHex(colorScheme.onSecondary)};
        --app-secondary-container: ${colorToHex(colorScheme.secondaryContainer)};
        --app-on-secondary-container: ${colorToHex(colorScheme.onSecondaryContainer)};
        --app-tertiary: ${colorToHex(colorScheme.tertiary)};
        --app-on-tertiary: ${colorToHex(colorScheme.onTertiary)};
        --app-tertiary-container: ${colorToHex(colorScheme.tertiaryContainer)};
        --app-on-tertiary-container: ${colorToHex(colorScheme.onTertiaryContainer)};
        --app-error: ${colorToHex(colorScheme.error)};
        --app-on-error: ${colorToHex(colorScheme.onError)};
        --app-error-container: ${colorToHex(colorScheme.errorContainer)};
        --app-on-error-container: ${colorToHex(colorScheme.onErrorContainer)};
        --app-surface: ${colorToHex(colorScheme.surface)};
        --app-on-surface: ${colorToHex(colorScheme.onSurface)};
        --app-surface-variant: ${colorToHex(colorScheme.surfaceContainerHighest)};
        --app-on-surface-variant: ${colorToHex(colorScheme.onSurfaceVariant)};
        --app-outline: ${colorToHex(colorScheme.outline)};
        --app-outline-variant: ${colorToHex(colorScheme.outlineVariant)};
        --app-shadow: ${colorToHex(colorScheme.shadow)};
        --app-scrim: ${colorToHex(colorScheme.scrim)};
        --app-inverse-surface: ${colorToHex(colorScheme.inverseSurface)};
        --app-on-inverse-surface: ${colorToHex(colorScheme.onInverseSurface)};
        --app-inverse-primary: ${colorToHex(colorScheme.inversePrimary)};
        --app-surface-tint: ${colorToHex(colorScheme.surfaceTint)};
        --app-surface-container-lowest: ${colorToHex(colorScheme.surfaceContainerLowest)};
        --app-surface-container-low: ${colorToHex(colorScheme.surfaceContainerLow)};
        --app-surface-container: ${colorToHex(colorScheme.surfaceContainer)};
        --app-surface-container-high: ${colorToHex(colorScheme.surfaceContainerHigh)};
        --app-surface-container-highest: ${colorToHex(colorScheme.surfaceContainerHighest)};
      }
    ''';

    return '''
    (function() {
      const isDarkMode = $isDark;

      const styleSheet = document.createElement("style");
      styleSheet.textContent = `$cssVars`;
      document.head.appendChild(styleSheet);

      if (isDarkMode) {
        document.documentElement.classList.add('dark');
        document.documentElement.style.setProperty('--lightense-backdrop', 'black', 'important');
        localStorage.setItem("theme", "dark");
      } else {
        document.documentElement.classList.remove('dark');
        document.documentElement.style.setProperty('--lightense-backdrop', 'white', 'important');
        localStorage.setItem("theme", "light");
      }

      const customCSS = document.createElement('style');
      customCSS.textContent = `
        body {
          background-color: var(--app-surface) !important;
          color: var(--app-on-surface) !important;
        }
        #header {
          background-color: var(--app-surface) !important;
          color: var(--app-on-surface) !important;
          box-shadow: 0 1px 3px 0 var(--app-shadow), 0 1px 2px -1px var(--app-shadow) !important;
        }
        #progress {
          background: linear-gradient(to right, var(--app-primary) var(--scroll), transparent 0) !important;
        }
        a {
          color: var(--app-primary) !important;
        }
        a.text-green-500, .text-green-500 {
          color: var(--app-primary) !important;
        }
        #header a.text-green-500 {
          color: var(--app-primary) !important;
        }
        nav ul a {
          color: var(--app-on-surface-variant) !important;
        }
        nav ul a:hover {
            color: var(--app-on-surface) !important;
        }
        button.bg-green-500, button.bg-blue-500, button.bg-blue-800 {
          background-color: var(--app-primary) !important;
          color: var(--app-on-primary) !important;
        }
        button.bg-green-500:hover, button.bg-blue-500:hover, button.bg-blue-800:hover {
            filter: brightness(1.1);
        }
        button.bg-green-500 a,
        .dark button.bg-green-500 a {
            color: var(--app-on-primary) !important;
        }
        button#openProblemModal {
          background-color: var(--app-error) !important;
          color: var(--app-on-error) !important;
        }
        button#openProblemModal:hover {
            background-color: var(--app-error-container) !important;
            color: var(--app-on-error-container) !important;
        }
        button.bg-red-400 {
            background-color: var(--app-error) !important;
            color: var(--app-on-error) !important;
        }
        button.bg-blue-400 {
            background-color: var(--app-secondary) !important;
            color: var(--app-on-secondary) !important;
        }
        button.bg-yellow-400 {
            background-color: var(--app-tertiary) !important;
            color: var(--app-on-tertiary) !important;
        }
        button.bg-gray-300 {
            background-color: var(--app-surface-container-high) !important;
            color: var(--app-on-surface-variant) !important;
        }
        button.bg-gray-700 {
            background-color: var(--app-surface-variant) !important;
            color: var(--app-on-surface-variant) !important;
        }
        button.bg-gray-300:hover, button.bg-gray-700:hover {
            filter: brightness(0.9);
        }
        button.bg-red-400, button.bg-blue-400, button.bg-yellow-400, button.bg-green-500, button.bg-blue-500, button.bg-blue-800, button.bg-gray-700 {
             /* Re-apply specific on-colors if needed, overriding .text-white */
             /* Example: Patreon button */
              &.bg-red-400 { color: var(--app-on-error) !important; }
             /* Example: Ko-fi button */
              &.bg-blue-400 { color: var(--app-on-secondary) !important; }
             /* Example: Liberapay button */
              &.bg-yellow-400 { color: var(--app-on-tertiary) !important; }
             /* Example: Primary buttons */
              &.bg-green-500, &.bg-blue-500, &.bg-blue-800 { color: var(--app-on-primary) !important; }
             /* Example: GitHub button */
              &.bg-gray-700 { color: var(--app-on-surface-variant) !important; }
        }
        button.text-gray-800 {
            color: var(--app-on-surface-variant) !important;
        }
        #nav-toggle {
            color: var(--app-on-surface-variant) !important;
            border-color: var(--app-outline) !important;
        }
        #nav-toggle:hover {
            color: var(--app-on-surface) !important;
            border-color: var(--app-primary) !important;
        }
        .text-gray-900, .text-gray-800, .text-black { color: var(--app-on-surface) !important; }
        .dark .text-gray-100, .dark .text-gray-200, .dark .text-white { color: var(--app-on-surface) !important; }
        .text-gray-500, .text-gray-600 { color: var(--app-on-surface-variant) !important; }
        .dark .text-gray-500, .dark .text-gray-400 { color: var(--app-on-surface-variant) !important; }
        .bg-white { background-color: var(--app-surface) !important; }
        .dark .bg-gray-800 { background-color: var(--app-surface) !important; }
        .bg-gray-100 { background-color: var(--app-surface-container-low) !important; }
        .dark .bg-gray-600 { background-color: var(--app-surface-container) !important; }
        .text-yellow-500, .dark .text-yellow-400 {
            color: var(--app-tertiary) !important;
        }
        .border, .border-gray-300, .dark .border-gray-700, .border-gray-600 {
            border-color: var(--app-outline-variant) !important;
        }
        pre {
            background-color: var(--app-surface-container-low) !important;
            border-color: var(--app-outline-variant) !important;
            color: var(--app-on-surface-variant) !important;
        }
        pre code {
            background-color: transparent !important;
            color: inherit !important;
        }
        p code, ul code, li code, code:not(pre *) {
            background-color: var(--app-surface-container-high) !important;
            color: var(--app-on-surface-variant) !important;
            padding: 0.1em 0.3em;
            border-radius: 4px;
        }
        .hljs-copy {
            background-color: var(--app-surface-container-high) !important;
            color: var(--app-on-surface-variant) !important;
            border: 1px solid var(--app-outline-variant) !important;
            border-radius: 4px;
            padding: 2px 6px !important;
            margin: 4px !important;
        }
        .hljs-copy:hover {
            background-color: var(--app-surface-container-highest) !important;
        }
        .bg-green-100, .dark .bg-green-800 {
          color: var(--app-on-primary-container) !important;
          background-color: var(--app-primary-container) !important;
          padding: 0.25em 0.5em !important;
          border-radius: 9999px !important;
          font-size: 0.8rem !important;
        }
        .bg-green-100 span, .dark .bg-green-800 span {
          color: var(--app-on-primary-container) !important;
        }

        .modal-content {
            background-color: var(--app-surface-container) !important;
            color: var(--app-on-surface) !important;
        }
        #problem-description {
            background-color: var(--app-surface-container) !important;
            color: var(--app-on-surface) !important;
            border: 1px solid var(--app-outline) !important;
            border-radius: 4px;
        }
        #problem-description::placeholder {
            color: var(--app-on-surface-variant) !important;
        }
        figcaption {
            color: var(--app-on-surface-variant) !important;
        }
        svg {
            fill: currentColor !important;
        }
        #openProblemModal svg {
            fill: var(--app-on-error) !important;
        }
        #darkModeToggle svg {
            fill: var(--app-on-primary) !important;
        }
        .notification-container > div {
            background-color: var(--app-surface-container-low) !important;
            border-color: var(--app-outline-variant) !important;
            color: var(--app-on-surface) !important;
        }
        #darkModeToggle {
          display: none !important;
          visibility: hidden !important;
          pointer-events: none !important;
          width: 0 !important;
          height: 0 !important;
          opacity: 0 !important;
          margin: 0 !important;
          padding: 0 !important;
          border: none !important;
        }
      `;
      document.head.appendChild(customCSS);

      // Attempt to override highlight.js theme based on dark mode
      const desiredHljsTheme = isDarkMode ? 'github-dark' : 'github';
      try {
          const existingLink = document.querySelector('link[href*="highlight.js/styles"]');
          if (existingLink && !existingLink.href.includes(desiredHljsTheme)) {
              existingLink.href = `https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/\${desiredHljsTheme}.min.css`;
          } else if (!existingLink) {
              const link = document.createElement("link");
              link.rel = "stylesheet";
              link.href = `https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/\${desiredHljsTheme}.min.css`;
              document.head.appendChild(link);
          }
      } catch (e) { console.error("Failed to set HLJS theme:", e); }


      if (window.changeTheme) {
        window.changeTheme = function(themeName) {
          console.log('Freedium App: Preventing web page theme change:', themeName);
          // window.flutter_inappwebview.callHandler('onThemeToggleAttempt');
          return false; // Prevent original function execution
        };
      }

      window.flutter_inappwebview.callHandler('themeApplied');
    })();
    ''';
  }

  @override
  void initState() {
    super.initState();
    _pullToRefreshController = PullToRefreshController(
      onRefresh: () {
        setState(() {
          _themeApplied = false;
          _pageLoaded = false;
        });
        _controller?.reload();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pullToRefreshController != null) {
      _pullToRefreshController?.settings.color =
          Theme.of(context).colorScheme.primary;
      _pullToRefreshController?.settings.backgroundColor =
          Theme.of(context).colorScheme.surface;
    }
  }

  void _updateInitialLoadState() {
    final bool isThemedPage =
        _controller?.getUrl().toString().startsWith(_urlPrefix) ?? false;
    if (_isInitialLoad &&
        _pageLoaded &&
        (isThemedPage ? _themeApplied : true)) {
      setState(() => _isInitialLoad = false);
    }
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    _controller = controller;
    _addJavaScriptHandlers();
  }

  void _addJavaScriptHandlers() {
    _controller?.addJavaScriptHandler(
      handlerName: 'themeApplied',
      callback: (args) {
        setState(() {
          _themeApplied = true;
          _updateInitialLoadState();
        });
        return null;
      },
    );

    _controller?.addJavaScriptHandler(
      handlerName: 'Toaster',
      callback: (args) {
        if (args.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(args[0].toString())));
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.surface;
    final bool isThemedPage =
        _controller?.getUrl().toString().startsWith(_urlPrefix) ?? false;
    final bool showWebView =
        _pageLoaded && (isThemedPage ? _themeApplied : true);

    return Scaffold(
      backgroundColor: showWebView ? backgroundColor : null,
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(
                url: WebUri.uri(
                  Uri.parse(_urlPrefix).replace(path: widget.url),
                ),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                isInspectable: kDebugMode,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                useHybridComposition: true,
                cacheEnabled: true,
                transparentBackground: true,
              ),
              pullToRefreshController: _pullToRefreshController,
              onWebViewCreated: _onWebViewCreated,
              onLoadStop: (controller, url) async {
                _pullToRefreshController?.endRefreshing();

                setState(() {
                  _pageLoaded = true;
                });

                if (url != null && url.toString().startsWith(_urlPrefix)) {
                  await controller.evaluateJavascript(
                    source: _getThemeInjectionScript(),
                  );
                } else {
                  setState(() {
                    _themeApplied = false;
                    _updateInitialLoadState();
                  });
                }
              },
              onProgressChanged: (controller, progress) async {
                if (!_pageLoaded) {
                  setState(() {
                    _progress = progress / 100.0;
                  });
                }
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                setState(() {
                  _themeApplied = false;
                  _pageLoaded = false;
                  _progress = 0;
                });
                var uri = navigationAction.request.url!;

                if (!["http", "https"].contains(uri.scheme)) {
                  if (await canLaunchUrl(Uri.parse(uri.toString()))) {
                    await launchUrl(Uri.parse(uri.toString()));
                    return NavigationActionPolicy.CANCEL;
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
              onReceivedError: (controller, request, error) {
                debugPrint('Error loading page: ${error.description}');
                _pullToRefreshController?.endRefreshing();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading page: ${error.description}'),
                  ),
                );
                setState(() {
                  _pageLoaded = true;
                  _themeApplied = false;
                  _progress = 1.0;
                });
                _updateInitialLoadState();
              },
            ),

            if (!_pageLoaded && _progress < 1.0)
              LinearProgressIndicator(value: _progress > 0 ? _progress : null),

            if (!_pageLoaded && _isInitialLoad)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      floatingActionButton:
          showWebView
              ? FloatingActionButton.small(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      subject: 'Read this article without Paywall',
                      title: 'Share Freedium link',
                      uri: Uri.parse(_urlPrefix).replace(path: widget.url),
                    ),
                  );
                },
                child: const Icon(Icons.share),
              )
              : null,
    );
  }
}
