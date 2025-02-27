import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:super_clipboard/super_clipboard.dart';
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

    return '''
    (function() {
      const isDarkMode = $isDark;
      
      // if (isDarkMode) {
      //   document.documentElement.classList.add('dark');
      //   document.documentElement.style.cssText = "--lightense-backdrop: black;";
      //   localStorage.setItem("theme", "dark");
      // } else {
      //   document.documentElement.classList.remove('dark');
      //   document.documentElement.style.cssText = "--lightense-backdrop: white;";
      //   localStorage.setItem("theme", "light");
      // }

      const darkModeToggle = document.getElementById('darkModeToggle');
      if (darkModeToggle !== null) {
        darkModeToggle.style.display = 'none';
      }
      
      const customCSS = document.createElement('style');
      customCSS.textContent = `
        :root {
          --app-primary: ${colorToHex(colorScheme.primary)};
          --app-secondary: ${colorToHex(colorScheme.secondary)};
          --app-background: ${colorToHex(colorScheme.surface)};
          --app-surface: ${colorToHex(colorScheme.surface)};
          --app-error: ${colorToHex(colorScheme.error)};
          --app-text: ${colorToHex(colorScheme.onSurface)};
        }
        
        body.dark {
          background-color: ${colorToHex(colorScheme.surface)} !important;
          color: ${colorToHex(colorScheme.onSurface)} !important;
        }
        
        #header {
          background-color: ${colorToHex(colorScheme.surface)} !important;
        }
        
        #progress {
          background: linear-gradient(to right, ${colorToHex(colorScheme.primary)} var(--scroll), transparent 0) !important;
        }
        
        a.text-green-500, button.bg-green-500, .bg-green-500 {
          color: ${colorToHex(colorScheme.primary)} !important;
        }
        
        button.bg-green-500, button.bg-blue-500, .bg-green-500 {
          background-color: ${colorToHex(colorScheme.primary)} !important;
        }
        
        .text-green-500.bg-green-100 {
          color: ${colorToHex(colorScheme.primary)} !important;
          background-color: ${colorToHex(colorScheme.primaryContainer)} !important;
        }
        
        .dark .bg-gray-800 {
          background-color: ${colorToHex(colorScheme.surface)} !important;
        }
        
        .dark .text-white {
          color: ${colorToHex(colorScheme.onSurface)} !important;
        }

        #darkModeToggle {
          display: none !important;
          pointer-events: none !important;
        }
      `;
      document.head.appendChild(customCSS);
      
      if (window.changeTheme) {
        const originalChangeTheme = window.changeTheme;
        window.changeTheme = function() {
          window.flutter_inappwebview.callHandler('onThemeToggleAttempt');
          return false;
        };
      }
      
      // Notify that theme has been applied
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

  @override
  void dispose() {
    _pullToRefreshController?.dispose();
    super.dispose();
  }

  void _updateInitialLoadState() {
    if (_isInitialLoad && _pageLoaded && _themeApplied) {
      setState(() => _isInitialLoad = false);
    }
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    _controller = controller;

    _controller?.addUserScript(
      userScript: UserScript(
        source: _getThemeInjectionScript(),
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
      ),
    );

    _addJavaScriptHandlers();
  }

  void _addJavaScriptHandlers() {
    // Add JavaScript handler for theme application
    _controller?.addJavaScriptHandler(
      handlerName: 'themeApplied',
      callback: (args) {
        setState(() => _themeApplied = true);
        _updateInitialLoadState();
        return null;
      },
    );

    // Add JavaScript channel for toasts
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

    // Add JavaScript channel for clipboard
    _controller?.addJavaScriptHandler(
      handlerName: 'Clipboard',
      callback: (args) {
        if (args.isNotEmpty) {
          final clipboard = SystemClipboard.instance!;
          final item = DataWriterItem();
          item.add(Formats.plainText(args[0].toString()));
          clipboard.write([item]);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.surface;
    final bool showWebView = _pageLoaded && _themeApplied;

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
                setState(() => _pageLoaded = true);
                _pullToRefreshController?.endRefreshing();
                _updateInitialLoadState();
              },
              onProgressChanged: (controller, progress) async {
                setState(() {
                  _progress = progress / 100.0;
                });
                if (progress == 100) {
                  _pullToRefreshController?.endRefreshing();
                }
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                setState(() {
                  _themeApplied = false;
                  _pageLoaded = false;
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
              },
            ),

            if (_progress < 1.0 || !showWebView)
              LinearProgressIndicator(value: _progress > 0 ? _progress : null),

            if (!showWebView && _isInitialLoad)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      floatingActionButton:
          showWebView
              ? FloatingActionButton.small(
                onPressed: () {
                  Share.shareUri(
                    Uri.parse(_urlPrefix).replace(path: widget.url),
                  );
                },
                child: const Icon(Icons.share),
              )
              : null,
    );
  }
}
