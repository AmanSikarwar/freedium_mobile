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
    _currentMirrorIndex = (_currentMirrorIndex + 1) % settings.mirrors.length;
    final nextMirror = settings.mirrors[_currentMirrorIndex];
    _hasSwitchedMirror = true;
    _rememberArticleRequestUrl(nextMirror.url);

    final currentArticle = articleUrl();
    _readerState = WebviewState(
      fontSize: _readerState.fontSize,
      activeBaseUrl: nextMirror.url,
    );

    final newUrl = buildFreediumArticleUri(
      mirrorUrl: nextMirror.url,
      articleUrl: currentArticle,
    );
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

  void goBack() {
    _controller?.goBack();
  }

  void reload() {
    _retryCount = 0;
    if (_readerState.currentUrl case final currentUrl?) {
      _preparePageLoad(currentUrl);
    }
    _controller?.reload();
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
