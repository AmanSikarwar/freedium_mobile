part of '../bookmarks_provider.dart';

class _BookmarkMutations(this._bookmarks) {
  final Bookmarks _bookmarks;

  Future<bool> _addBookmark(String url, String title, {String? folder}) async {
    final service = await _bookmarks._service();
    if (service == null) return false;
    final normalizedUrl = normalizeHttpUrl(url);
    if (normalizedUrl == null) return false;
    if (_bookmarks.isBookmarked(normalizedUrl)) return true;
    final normalizedTitle = title.trim().isNotEmpty
        ? title.trim()
        : normalizedUrl;
    final normalizedFolder = normalizeBookmarkFolderName(folder);

    final current = _bookmarks._currentBookmarks;
    if (current.length >= Bookmarks.maxBookmarks) return false;
    final newList = List<BookmarkedArticle>.from(current);
    newList.insert(
      0,
      BookmarkedArticle(
        url: normalizedUrl,
        title: normalizedTitle,
        savedAt: DateTime.now(),
        folder: normalizedFolder,
      ),
    );

    try {
      await service.saveBookmarks(newList);
      _bookmarks._applySavedBookmarks(newList);
      return true;
    } catch (e) {
      debugPrint('Failed to save bookmark: $e');
      return false;
    }
  }

  Future<bool> _removeBookmark(BookmarkedArticle item) async {
    final service = await _bookmarks._service();
    if (service == null) return false;

    final current = _bookmarks._currentBookmarks;
    final newList = current
        .where((bookmark) => bookmark.url != item.url)
        .toList();

    try {
      await service.saveBookmarks(newList);
      _bookmarks._applySavedBookmarks(newList);
      return true;
    } catch (e) {
      debugPrint('Failed to remove bookmark: $e');
      return false;
    }
  }

  Future<bool> _toggleBookmark(String url, String title) async {
    if (await _bookmarks._service() == null) return false;
    final normalizedUrl = normalizeHttpUrl(url);
    if (normalizedUrl == null) return false;

    if (_bookmarks.isBookmarked(normalizedUrl)) {
      final item = _bookmarks._currentBookmarks.firstWhere(
        (bookmark) => bookmark.url == normalizedUrl,
      );
      return _removeBookmark(item);
    }
    return _addBookmark(normalizedUrl, title);
  }

  Future<bool> _clearBookmarks() async {
    final service = await _bookmarks._service();
    if (service == null) return false;

    try {
      await service.clearBookmarks();
      _bookmarks._applySavedBookmarks(const []);
      return true;
    } catch (e) {
      debugPrint('Failed to clear bookmarks: $e');
      return false;
    }
  }
}
