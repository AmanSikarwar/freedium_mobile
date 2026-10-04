part of 'webview_provider.dart';

extension _WebviewLoading on Webview {
  Future<void> _navigateAfterProgressFlush(
    Uri targetUrl, {
    String? baseUrl,
  }) async {
    final previousUrl = _progressDocumentUrl;
    final previousToken = _historyRecordToken;
    if (_readingProgressAvailable) {
      await flushReadingProgress();
    }
    if (_isDisposed ||
        previousUrl != _progressDocumentUrl ||
        previousToken != _historyRecordToken) {
      return;
    }

    _preparePageLoad(targetUrl.toString(), baseUrl: baseUrl);
    await _controller?.loadRequest(targetUrl);
  }

  void _preparePageLoad(String url, {String? baseUrl}) {
    _themeFailed = false;
    _themeAckTimer?.cancel();
    _failedPageUrls.remove(_normalizeUrl(url));
    _historyRecordToken++;
    _hasRecordedHistoryForCurrentPage = false;
    _latestReadingProgress = 0;
    _progressDocumentUrl = url;
    _readingProgressAvailable = false;
    _readerState = _readerState.copyWith(
      activeBaseUrl: baseUrl ?? _readerState.activeBaseUrl,
      currentUrl: url,
      isThemeApplied: false,
      useOriginalStyling: false,
      isPageLoaded: false,
      progress: 0,
      hasError: false,
      errorMessage: null,
      articleMeta: null,
    );
    _startPageLoadDeadline();
  }

  void _startPageLoadDeadline() {
    _pageLoadTimer?.cancel();
    final settings =
        _readerRef.read(settingsProvider).value ?? const SettingsState();
    _pageLoadTimer = Timer(Duration(seconds: settings.mirrorTimeout * 3), () {
      if (_readerRef.mounted) {
        _handleLoadError('The article took too long to load.');
      }
    });
  }

  void _handleLoadError(String message, {bool retryable = true}) {
    if (!_readerRef.mounted) return;
    _pageLoadTimer?.cancel();
    _themeAckTimer?.cancel();
    _themeFailed = false;
    if (_readerState.currentUrl case final currentUrl?) {
      _failedPageUrls.add(_normalizeUrl(currentUrl));
    }
    _historyRecordToken++;
    _readerState = _readerState.copyWith(
      isPageLoaded: true,
      isThemeApplied: false,
      progress: 1,
      hasError: true,
      errorMessage: message,
    );
    final settings =
        _readerRef.read(settingsProvider).value ?? const SettingsState();

    if (retryable &&
        settings.autoSwitchMirror &&
        _retryCount < Webview._maxRetries &&
        _retryCount < settings.mirrors.length - 1 &&
        settings.mirrors.isNotEmpty) {
      _retryCount++;
      _currentMirrorIndex = (_currentMirrorIndex + 1) % settings.mirrors.length;

      final nextMirror = settings.mirrors[_currentMirrorIndex];
      debugPrint(
        'Trying fallback mirror: ${nextMirror.url} (attempt $_retryCount)',
      );
      _hasSwitchedMirror = true;
      _rememberArticleRequestUrl(nextMirror.url);

      _readerState = _readerState.copyWith(
        userMessage: 'Trying mirror: ${nextMirror.name}...',
      );

      final newUrl = buildFreediumArticleUri(
        mirrorUrl: nextMirror.url,
        articleUrl: articleUrl(),
      );
      unawaited(_navigateAfterProgressFlush(newUrl, baseUrl: nextMirror.url));
    } else {
      _updateInitialLoadState();
    }
  }
}
