part of '../bookmarks_provider.dart';

class _BookmarkFoldersMutations(this._folders) {
  final BookmarkFolders _folders;

  Future<bool> _ensureFolder(String name) async {
    final service = await _folders._service();
    if (service == null) return false;
    final normalized = normalizeBookmarkFolderName(name);
    if (normalized == null) return false;

    final current = _folders._currentFolders;
    final articles = await _folders._readArticles();
    if (articles == null) return false;
    final available = mergeBookmarkFolders(current, [
      for (final article in articles) article.folder,
    ]);
    if (isBookmarkFolderDuplicate(normalized, current)) return true;
    if (current.length >= maxBookmarkFolders) {
      return isBookmarkFolderDuplicate(normalized, available);
    }

    final next = [...current, normalized]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    try {
      await service.saveFolders(next);
      _folders._applySavedFolders(next);
      return true;
    } catch (e) {
      debugPrint('Failed to save bookmark folder: $e');
      return false;
    }
  }

  Future<bool> _renameFolder(String oldName, String newName) async {
    final service = await _folders._service();
    if (service == null) return false;
    final oldNormalized = normalizeBookmarkFolderName(oldName);
    final newNormalized = normalizeBookmarkFolderName(newName);
    if (oldNormalized == null || newNormalized == null) return false;

    final current = _folders._currentFolders;
    final articles = await _folders._readArticles();
    if (articles == null) return false;
    final available = mergeBookmarkFolders(current, [
      for (final article in articles) article.folder,
    ]);
    if (!available.any(
      (folder) => folder.toLowerCase() == oldNormalized.toLowerCase(),
    )) {
      return false;
    }
    if (isBookmarkFolderDuplicate(
      newNormalized,
      available,
      exclude: oldNormalized,
    )) {
      return false;
    }

    final updatedArticles = [
      for (final article in articles)
        if (article.folder?.toLowerCase() == oldNormalized.toLowerCase())
          article.copyWith(folder: newNormalized)
        else
          article,
    ];
    final next = [
      for (final folder in current)
        if (folder.toLowerCase() == oldNormalized.toLowerCase())
          newNormalized
        else
          folder,
    ]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    try {
      await service.saveLibrary(updatedArticles, next);
      if (!_folders._foldersRef.mounted) return false;
      _folders._foldersRef
          .read(bookmarksProvider.notifier)
          ._applySavedBookmarks(updatedArticles);
      _folders._applySavedFolders(next);
      return true;
    } catch (e) {
      debugPrint('Failed to rename bookmark folder: $e');
      return false;
    }
  }

  Future<bool> _deleteFolder(String name) async {
    final service = await _folders._service();
    if (service == null) return false;
    final normalized = normalizeBookmarkFolderName(name);
    if (normalized == null) return false;

    final current = _folders._currentFolders;
    final articles = await _folders._readArticles();
    if (articles == null) return false;
    final available = mergeBookmarkFolders(current, [
      for (final article in articles) article.folder,
    ]);
    if (!available.any(
      (folder) => folder.toLowerCase() == normalized.toLowerCase(),
    )) {
      return false;
    }

    final updatedArticles = [
      for (final article in articles)
        if (article.folder?.toLowerCase() == normalized.toLowerCase())
          article.copyWith(folder: null)
        else
          article,
    ];
    final next = [
      for (final folder in current)
        if (folder.toLowerCase() != normalized.toLowerCase()) folder,
    ];

    try {
      await service.saveLibrary(updatedArticles, next);
      if (!_folders._foldersRef.mounted) return false;
      _folders._foldersRef
          .read(bookmarksProvider.notifier)
          ._applySavedBookmarks(updatedArticles);
      _folders._applySavedFolders(next);
      return true;
    } catch (e) {
      debugPrint('Failed to delete bookmark folder: $e');
      return false;
    }
  }
}
