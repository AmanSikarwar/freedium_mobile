part of 'webview_provider.dart';

extension _WebviewStyling on Webview {
  Future<void> _injectTheme() async {
    final token = _historyRecordToken;
    _themeAckTimer?.cancel();
    if (_readerState.isPageLoaded && !_readerState.isThemeApplied) {
      _themeAckTimer = Timer(
        const Duration(seconds: 3),
        () => _handleThemeFailure(token),
      );
    }
    if (_colorScheme == null || _controller == null) return;
    try {
      final script = await _themeInjector.getThemeInjectionScript(
        _colorScheme!,
        fontSize: _readerState.fontSize,
        showSitePopups:
            _readerRef.read(settingsProvider).value?.showSitePopups ?? true,
      );

      if (!_readerRef.mounted || token != _historyRecordToken) return;

      await _controller!.runJavaScript(script);
    } catch (e) {
      debugPrint('Failed to inject theme script: $e');
      _handleThemeFailure(token);
    }
  }

  void _handleThemeFailure(int token) {
    if (!_readerRef.mounted ||
        token != _historyRecordToken ||
        _readerState.isThemeApplied ||
        _readerState.useOriginalStyling) {
      return;
    }
    _themeAckTimer?.cancel();
    _themeFailed = true;
    _readerState = _readerState.copyWith(
      hasError: true,
      errorMessage: 'Reader styling failed. Please retry the article.',
    );
    _updateInitialLoadState();
  }

  void _updateInitialLoadState() {
    final bool isThemedPage = _freediumUrlService.isFreediumUrl(
      _readerState.currentUrl ?? '',
    );
    if (_readerState.isInitialLoad &&
        _readerState.isPageLoaded &&
        (_readerState.hasError ||
            !isThemedPage ||
            _readerState.isThemeApplied)) {
      _readerState = _readerState.copyWith(isInitialLoad: false);
    }
  }

  Future<void> _applyFontSize(double fontSize) async {
    final normalizedFontSize = FontSizeService.normalizeFontSize(fontSize);
    _readerState = _readerState.copyWith(fontSize: normalizedFontSize);
    final controller = _controller;
    if (controller != null && _readerState.isPageLoaded) {
      final script = _themeInjector.getFontSizeUpdateScript(normalizedFontSize);
      try {
        await controller.runJavaScript(script);
      } catch (e) {
        debugPrint('Failed to update font size script: $e');
      }
    }
  }
}
