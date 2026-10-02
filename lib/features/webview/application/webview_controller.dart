part of 'webview_provider.dart';

extension _WebviewController on Webview {
  WebViewController _createController({String? baseUrl}) {
    final activeBaseUrl = baseUrl ?? AppConstants.freediumMirrorUrl;
    final initialUrl = buildFreediumArticleUri(
      mirrorUrl: activeBaseUrl,
      articleUrl: url,
    );
    _hasSwitchedMirror = false;
    _articleRequestUrls.clear();
    _rememberArticleRequestUrl(activeBaseUrl);
    _setCurrentMirrorIndex(activeBaseUrl);

    _startPageLoadDeadline();
    final controller = WebViewController();
    _controller = controller;
    controller
      ..setJavaScriptMode(.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'themeApplied',
        onMessageReceived: (JavaScriptMessage message) {
          if (!_readerRef.mounted) return;
          _themeAckTimer?.cancel();
          _readerState = _readerState.copyWith(isThemeApplied: true);
          _updateInitialLoadState();
        },
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          _readerState = _readerState.copyWith(userMessage: message.message);
        },
      )
      ..addJavaScriptChannel(
        'ArticleMeta',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message) as Map<String, dynamic>;
            _readerState = _readerState.copyWith(
              articleMeta: ArticleMeta(
                title: (data['title'] as String? ?? '').trim(),
                author: (data['author'] as String? ?? '').trim(),
                readTime: (data['readTime'] as String? ?? '').trim(),
                heroImageUrl: (data['heroImageUrl'] as String? ?? '').trim(),
              ),
            );
            final currentUrl = _readerState.currentUrl;
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
            _readerState = _readerState.copyWith(progress: progress / 100.0);
          },
          onPageStarted: (String url) {
            if (!_readerRef.mounted) return;
            _startPageLoadDeadline();
            _themeFailed = false;
            _themeAckTimer?.cancel();
            _failedPageUrls.remove(_normalizeUrl(url));
            _historyRecordToken++;
            _hasRecordedHistoryForCurrentPage = false;
            _latestReadingProgress = 0;
            _readerState = _readerState.copyWith(
              isThemeApplied: false,
              useOriginalStyling: false,
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
                    (Object e) => debugPrint('Pre-theme injection failed: $e'),
                  );
            }
          },
          onPageFinished: (String url) async {
            if (!_readerRef.mounted ||
                _failedPageUrls.contains(_normalizeUrl(url))) {
              return;
            }
            _pageLoadTimer?.cancel();
            final token = _historyRecordToken;
            _readerState = _readerState.copyWith(
              isPageLoaded: true,
              currentUrl: url,
            );
            if (_freediumUrlService.isFreediumUrl(url)) {
              _retryCount = 0;
              await _injectTheme();
              if (!_readerRef.mounted || token != _historyRecordToken) return;
              await _restoreReadingProgress(url);
              await _recordHistoryWhenReady(url);
            } else {
              _readerState = _readerState.copyWith(isThemeApplied: false);
            }
            if (_readerRef.mounted && token == _historyRecordToken) {
              _updateInitialLoadState();
            }
          },
          onHttpError: (HttpResponseError error) {
            final failedUrl = error.request?.uri ?? error.response?.uri;
            final currentUrl = _readerState.currentUrl;
            final status = error.response?.statusCode;
            // Android reports subresource errors too. Match the document URL;
            // unidentified responses cannot safely be treated as page failures.
            if (failedUrl == null ||
                currentUrl == null ||
                _normalizeUrl(failedUrl.toString()) !=
                    _normalizeUrl(currentUrl) ||
                status == null ||
                status < 400) {
              return;
            }
            _handleLoadError(
              'The article server returned HTTP $status.',
              retryable: status == 408 || status == 429 || status >= 500,
            );
          },
          onWebResourceError: (WebResourceError error) {
            final isMainFrame = error.isForMainFrame ?? true;
            if (isMainFrame) {
              debugPrint('Error loading page: ${error.description}');
              _handleLoadError(_getUserFriendlyErrorMessage(error));
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
                if (!launched && _readerRef.mounted) {
                  _readerState = _readerState.copyWith(
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

    _readerState = _readerState.copyWith(activeBaseUrl: activeBaseUrl);
    return controller;
  }
}
