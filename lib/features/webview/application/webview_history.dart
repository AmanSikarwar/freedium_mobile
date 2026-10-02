part of 'webview_provider.dart';

extension _WebviewHistory on Webview {
  Future<void> _recordHistoryWhenReady(String currentUrl) async {
    final controller = _controller;
    if (controller == null ||
        _readerState.hasError ||
        !_readerState.isPageLoaded ||
        !_freediumUrlService.isFreediumUrl(currentUrl)) {
      return;
    }

    final originalUrl = _extractOriginalUrl(currentUrl);
    final token = _historyRecordToken;
    if (_hasRecordedHistoryForCurrentPage) return;

    final initialMetaTitle = _readerState.articleMeta?.title.trim() ?? '';
    if (initialMetaTitle.isEmpty) {
      await Future<void>.delayed(Webview._articleMetaWaitDuration);
      if (!_readerRef.mounted ||
          _readerState.hasError ||
          token != _historyRecordToken ||
          _hasRecordedHistoryForCurrentPage) {
        return;
      }
    }

    final metaTitle = _readerState.articleMeta?.title.trim() ?? '';
    final title = metaTitle.isNotEmpty
        ? metaTitle
        : ((await controller.getTitle()) ?? '').trim();

    if (!_readerRef.mounted ||
        _readerState.hasError ||
        token != _historyRecordToken ||
        _hasRecordedHistoryForCurrentPage ||
        title.isEmpty) {
      return;
    }

    _hasRecordedHistoryForCurrentPage = true;
    try {
      await _readerRef
          .read(historyProvider.notifier)
          .addHistory(originalUrl, title);
      if (_readerRef.mounted &&
          token == _historyRecordToken &&
          _latestReadingProgress > 0) {
        await _readerRef
            .read(historyProvider.notifier)
            .updateReadingProgress(originalUrl, _latestReadingProgress);
      }
    } catch (e) {
      debugPrint('Failed to save history entry: $e');
      _hasRecordedHistoryForCurrentPage = false;
    }
  }

  void _saveReadingProgress(String message) {
    final currentUrl = _readerState.currentUrl;
    final progress = double.tryParse(message);
    if (!_readerRef.mounted ||
        currentUrl == null ||
        progress == null ||
        !_freediumUrlService.isFreediumUrl(currentUrl)) {
      return;
    }

    final normalizedProgress = normalizeReadingProgress(progress);
    if (normalizedProgress == 0) return;

    _latestReadingProgress = normalizedProgress;
    unawaited(
      _readerRef
          .read(historyProvider.notifier)
          .updateReadingProgress(
            _extractOriginalUrl(currentUrl),
            normalizedProgress,
          ),
    );
  }

  Future<void> _restoreReadingProgress(String currentUrl) async {
    final progress = await _readerRef
        .read(historyProvider.notifier)
        .readingProgressFor(_extractOriginalUrl(currentUrl));
    if (!_readerRef.mounted ||
        _readerState.currentUrl != currentUrl ||
        progress <= readingProgressRestoreThreshold ||
        progress >= readingCompletionThreshold) {
      return;
    }

    _latestReadingProgress = progress;
    try {
      await _controller?.runJavaScript(
        buildReadingProgressRestoreScript(progress),
      );
    } catch (e) {
      debugPrint('Failed to restore reading progress: $e');
    }
  }
}
