part of 'webview_provider.dart';

extension WebviewActions on Webview {
  bool shouldUseAppLevelBackNavigation() {
    if (!_hasSwitchedMirror) return false;
    final currentUrl = _readerState.currentUrl;
    if (currentUrl == null || currentUrl.isEmpty) return false;
    return _articleRequestUrls.contains(_normalizeUrl(currentUrl));
  }

  Future<void> retryWithNextMirror() async {
    final settings =
        _readerRef.read(settingsProvider).value ?? const SettingsState();
    if (settings.mirrors.isEmpty) {
      debugPrint('No mirrors available to retry');
      return;
    }

    final previousUrl = _progressDocumentUrl;
    final previousToken = _historyRecordToken;
    final currentArticle = articleUrl();
    final nextMirrorIndex = (_currentMirrorIndex + 1) % settings.mirrors.length;
    final nextMirror = settings.mirrors[nextMirrorIndex];
    final newUrl = buildFreediumArticleUri(
      mirrorUrl: nextMirror.url,
      articleUrl: currentArticle,
    );

    if (_readingProgressAvailable) {
      await flushReadingProgress();
    }
    if (_isDisposed ||
        previousToken != _historyRecordToken ||
        previousUrl != _progressDocumentUrl) {
      return;
    }

    _currentMirrorIndex = nextMirrorIndex;
    _hasSwitchedMirror = true;
    _readerState = WebviewState(
      fontSize: _readerState.fontSize,
      activeBaseUrl: nextMirror.url,
    );
    _articleRequestUrls.add(_normalizeUrl(newUrl.toString()));
    _preparePageLoad(newUrl.toString(), baseUrl: nextMirror.url);
    _controller?.loadRequest(newUrl);
  }

  Future<void> shareArticle() async {
    final shareUri = buildFreediumArticleUri(
      mirrorUrl: _readerState.activeBaseUrl,
      articleUrl: articleUrl(),
    );

    try {
      final result = await _readerRef.read(shareLauncherProvider)(
        ShareParams(
          subject: 'Read this article without Paywall',
          title: 'Share Freedium link',
          uri: shareUri,
        ),
      );
      if (!_readerRef.mounted ||
          result.status != ShareResultStatus.unavailable) {
        return;
      }

      _readerState = _readerState.copyWith(
        userMessage: 'Could not share article',
      );
    } catch (e) {
      debugPrint('Failed to share article: $e');
      if (_readerRef.mounted) {
        _readerState = _readerState.copyWith(
          userMessage: 'Could not share article',
        );
      }
    }
  }

  Future<bool> canGoBack() async {
    return await _controller?.canGoBack() ?? false;
  }

  Future<void> goBack() async {
    final currentUrl = _progressDocumentUrl;
    final pageToken = _historyRecordToken;
    await flushReadingProgress();
    if (_isDisposed ||
        currentUrl != _progressDocumentUrl ||
        pageToken != _historyRecordToken) {
      return;
    }
    await _controller?.goBack();
  }

  Future<void> reload() async {
    final currentUrl = _progressDocumentUrl;
    final pageToken = _historyRecordToken;
    if (currentUrl == null) return;

    await flushReadingProgress();
    if (_isDisposed ||
        currentUrl != _progressDocumentUrl ||
        pageToken != _historyRecordToken) {
      return;
    }

    _retryCount = 0;
    _preparePageLoad(currentUrl);
    await _controller?.reload();
  }

  Future<bool> updateFontSize(double fontSize) async {
    final normalizedFontSize = FontSizeService.normalizeFontSize(fontSize);
    final didSave = await _readerRef
        .read(settingsProvider.notifier)
        .setDefaultFontSize(normalizedFontSize);
    if (!_readerRef.mounted) return didSave;
    if (!didSave) {
      _readerState = _readerState.copyWith(
        userMessage: 'Failed to save font size',
      );
      return false;
    }

    if (_readerState.fontSize != normalizedFontSize) {
      await _applyFontSize(normalizedFontSize);
    }

    return true;
  }
}
