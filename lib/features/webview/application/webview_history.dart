part of 'webview_provider.dart';

const _readingProgressSnapshotScript = r'''(() => {
  const root = document.documentElement;
  const body = document.body;
  const height = Math.max(
    root ? root.scrollHeight : 0,
    body ? body.scrollHeight : 0
  );
  const scrollable = Math.max(1, height - window.innerHeight);
  return Math.min(1, Math.max(0, window.scrollY / scrollable));
})()''';

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
    if (_isDisposed || !_readerRef.mounted || !_readingProgressAvailable) {
      return;
    }

    final currentUrl = _progressDocumentUrl;
    if (currentUrl == null || !_freediumUrlService.isFreediumUrl(currentUrl)) {
      return;
    }

    final Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(message);
      if (decoded is! Map<String, dynamic>) return;
      payload = decoded;
    } on FormatException {
      return;
    }

    final reportedUrl = payload['url'];
    final pageToken = payload['pageToken'];
    final rawProgress = payload['progress'];
    if (reportedUrl is! String ||
        _normalizeUrl(reportedUrl) != _normalizeUrl(currentUrl) ||
        pageToken is! num ||
        pageToken != _historyRecordToken) {
      return;
    }

    final progress = rawProgress is num
        ? rawProgress.toDouble()
        : double.tryParse(rawProgress?.toString() ?? '');
    if (progress == null) return;

    final historyNotifier = _readerRef.read(historyProvider.notifier);
    final articleUrl = _extractOriginalUrl(currentUrl);
    unawaited(
      _persistReadingProgress(
        historyNotifier: historyNotifier,
        articleUrl: articleUrl,
        currentUrl: currentUrl,
        pageToken: _historyRecordToken,
        progress: progress,
      ),
    );
  }

  Future<void> _flushReadingProgressDebounced() {
    return _readingProgressFlush ??= _flushReadingProgress().whenComplete(() {
      _readingProgressFlush = null;
    });
  }

  Future<void> _flushReadingProgress() async {
    if (_isDisposed || !_readerRef.mounted || !_readingProgressAvailable) {
      return;
    }

    final controller = _controller;
    final currentUrl = _progressDocumentUrl;
    if (controller == null ||
        currentUrl == null ||
        !_freediumUrlService.isFreediumUrl(currentUrl)) {
      return;
    }

    final pageToken = _historyRecordToken;
    final historyNotifier = _readerRef.read(historyProvider.notifier);
    final articleUrl = _extractOriginalUrl(currentUrl);
    try {
      final result = await controller
          .runJavaScriptReturningResult(_readingProgressSnapshotScript)
          .timeout(const Duration(seconds: 1));
      final progress = result is num
          ? result.toDouble()
          : double.tryParse(result.toString());
      if (progress == null) return;

      await _persistReadingProgress(
        historyNotifier: historyNotifier,
        articleUrl: articleUrl,
        currentUrl: currentUrl,
        pageToken: pageToken,
        progress: progress,
      );
    } catch (e) {
      debugPrint('Failed to flush reading progress: $e');
    }
  }

  bool _isCurrentReadingPage(String currentUrl, int pageToken) {
    return !_isDisposed &&
        _readingProgressAvailable &&
        pageToken == _historyRecordToken &&
        currentUrl == _progressDocumentUrl;
  }

  Future<void> _persistReadingProgress({
    required History historyNotifier,
    required String articleUrl,
    required String currentUrl,
    required int pageToken,
    required double progress,
  }) async {
    if (!_isCurrentReadingPage(currentUrl, pageToken)) return;

    final normalizedProgress = normalizeReadingProgress(progress);
    if (normalizedProgress == 0) return;

    _latestReadingProgress = normalizedProgress;
    await historyNotifier.updateReadingProgress(articleUrl, normalizedProgress);
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
