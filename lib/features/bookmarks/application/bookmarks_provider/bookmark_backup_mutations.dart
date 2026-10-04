part of '../bookmarks_provider.dart';

class _BookmarkBackupMutations(this._bookmarks) {
  final Bookmarks _bookmarks;

  /// Merges backup entries, keeping existing URLs and filling available slots.
  /// Returns the number saved, or -1 when persistence fails.
  Future<int> _importBookmarks(List<BookmarkedArticle> entries) async {
    final service = await _bookmarks._service();
    if (service == null) return -1;
    if (entries.isEmpty) return 0;

    final current = _bookmarks._currentBookmarks;
    final available = Bookmarks.maxBookmarks - current.length;
    if (available <= 0) return 0;
    final knownUrls = {for (final bookmark in current) bookmark.url};
    final fresh = <BookmarkedArticle>[];
    for (final entry in entries) {
      if (knownUrls.add(entry.url)) {
        fresh.add(entry);
      }
    }
    if (fresh.isEmpty) return 0;

    fresh.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    final accepted = fresh.take(available).toList();
    final newList = [...accepted, ...current];

    try {
      await service.saveBookmarks(newList);
      _bookmarks._applySavedBookmarks(newList);
      return accepted.length;
    } catch (e) {
      debugPrint('Failed to import bookmarks: $e');
      return -1;
    }
  }

  /// Replaces an unreadable library from a confirmed backup restore. The raw
  /// snapshot is retained before the replacement is written.
  Future<int> _restoreUnreadableLibrary(
    List<BookmarkedArticle> entries,
    List<String> folders,
  ) async {
    try {
      final prefs = await _bookmarks._bookmarksRef.read(
        sharedPreferencesProvider.future,
      );
      final service = BookmarksService(prefs);
      await service.preserveSnapshotForRecovery();

      final byUrl = <String, BookmarkedArticle>{};
      for (final entry in entries) {
        final url = normalizeHttpUrl(entry.url);
        if (url == null) continue;
        final title = entry.title.trim();
        byUrl.putIfAbsent(
          url,
          () => entry.copyWith(
            url: url,
            title: title.isNotEmpty ? title : url,
            folder: normalizeBookmarkFolderName(entry.folder),
          ),
        );
      }

      final restored = byUrl.values.toList()
        ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
      final accepted = restored.take(Bookmarks.maxBookmarks).toList();
      final storedFolders = mergeBookmarkFolders(folders, [
        for (final article in accepted) article.folder,
      ]).take(maxBookmarkFolders).toList();
      await service.saveLibrary(accepted, storedFolders);
      if (!_bookmarks._bookmarksRef.mounted) return -1;
      _bookmarks._applySavedBookmarks(service.getBookmarks());
      _bookmarks._bookmarksRef.invalidate(bookmarkFoldersProvider);
      return accepted.length;
    } catch (e) {
      debugPrint('Failed to recover bookmark library: $e');
      return -1;
    }
  }
}
