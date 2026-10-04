part of '../bookmarks_provider.dart';

class _BookmarkFolderMutations(this._bookmarks) {
  final Bookmarks _bookmarks;

  /// Moves the bookmark for [url] into [folder] (null means Unsorted).
  Future<bool> _setArticleFolder(String url, String? folder) async {
    final service = await _bookmarks._service();
    if (service == null) return false;
    final normalizedUrl = normalizeHttpUrl(url);
    if (normalizedUrl == null) return false;
    final normalizedFolder = normalizeBookmarkFolderName(folder);

    final current = _bookmarks._currentBookmarks;
    if (!current.any((bookmark) => bookmark.url == normalizedUrl)) return false;
    final newList = [
      for (final bookmark in current)
        if (bookmark.url == normalizedUrl)
          bookmark.copyWith(folder: normalizedFolder)
        else
          bookmark,
    ];

    try {
      await service.saveBookmarks(newList);
      _bookmarks._applySavedBookmarks(newList);
      return true;
    } catch (e) {
      debugPrint('Failed to move bookmark to folder: $e');
      return false;
    }
  }

  /// Renames every article folder matching [oldName] (case-insensitive) to
  /// [newName]. The folder provider handles the stored folder list.
  Future<bool> _renameFolder(String oldName, String newName) async {
    final service = await _bookmarks._service();
    if (service == null) return false;
    final oldNormalized = normalizeBookmarkFolderName(oldName);
    final newNormalized = normalizeBookmarkFolderName(newName);
    if (oldNormalized == null || newNormalized == null) return false;

    final current = _bookmarks._currentBookmarks;
    if (!current.any(
      (bookmark) =>
          bookmark.folder?.toLowerCase() == oldNormalized.toLowerCase(),
    )) {
      return true;
    }
    final newList = [
      for (final bookmark in current)
        if (bookmark.folder?.toLowerCase() == oldNormalized.toLowerCase())
          bookmark.copyWith(folder: newNormalized)
        else
          bookmark,
    ];

    try {
      await service.saveBookmarks(newList);
      _bookmarks._applySavedBookmarks(newList);
      return true;
    } catch (e) {
      debugPrint('Failed to rename bookmark folder: $e');
      return false;
    }
  }

  /// Clears the folder (back to Unsorted) on every matching article.
  Future<bool> _clearFolder(String name) async {
    final service = await _bookmarks._service();
    if (service == null) return false;
    final normalized = normalizeBookmarkFolderName(name);
    if (normalized == null) return false;

    final current = _bookmarks._currentBookmarks;
    final newList = [
      for (final bookmark in current)
        if (bookmark.folder?.toLowerCase() == normalized.toLowerCase())
          bookmark.copyWith(folder: null)
        else
          bookmark,
    ];

    try {
      await service.saveBookmarks(newList);
      _bookmarks._applySavedBookmarks(newList);
      return true;
    } catch (e) {
      debugPrint('Failed to clear bookmark folder: $e');
      return false;
    }
  }
}
