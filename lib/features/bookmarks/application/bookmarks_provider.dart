import 'dart:async';

import 'package:freedium_mobile/core/utils/serial_task_queue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/utils/url.dart' show normalizeHttpUrl;
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_service.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmark_folder.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';

export 'package:freedium_mobile/features/bookmarks/domain/bookmark_folder.dart';
export 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';

part 'bookmarks_provider.g.dart';
part 'bookmarks_provider/bookmarks_mutations.dart';
part 'bookmarks_provider/bookmark_folder_mutations.dart';
part 'bookmarks_provider/bookmark_backup_mutations.dart';
part 'bookmarks_provider/bookmark_folders_mutations.dart';

final bookmarkWritesProvider = Provider((ref) => SerialTaskQueue());

Duration? _neverRetrySnapshotRead(int _, Object _) => null;

@Riverpod(keepAlive: true, retry: _neverRetrySnapshotRead)
class Bookmarks() extends _$Bookmarks {
  SerialTaskQueue get _writes => ref.read(bookmarkWritesProvider);
  Ref get _bookmarksRef => ref;
  List<BookmarkedArticle> get _currentBookmarks =>
      state.value ?? const <BookmarkedArticle>[];

  static const int maxBookmarks = 100;
  static const limitMessage =
      'Bookmark limit reached ($maxBookmarks). Remove a bookmark first.';

  bool isAtCapacity() => _currentBookmarks.length >= maxBookmarks;

  Future<BookmarksService?> _service() async {
    try {
      await future;
      if (!ref.mounted) return null;
      final prefs = await ref.read(sharedPreferencesProvider.future);
      return BookmarksService(prefs);
    } catch (e) {
      debugPrint('BookmarksService unavailable: $e');
      return null;
    }
  }

  @override
  FutureOr<List<BookmarkedArticle>> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return BookmarksService(prefs).getBookmarks();
  }

  void _applySavedBookmarks(List<BookmarkedArticle> bookmarks) {
    if (ref.mounted) state = AsyncData(bookmarks);
  }

  bool isBookmarked(String url) {
    final normalizedUrl = normalizeHttpUrl(url);
    if (normalizedUrl == null) return false;
    return _currentBookmarks.any((bookmark) => bookmark.url == normalizedUrl);
  }

  Future<bool> addBookmark(String url, String title, {String? folder}) async {
    final result = await _writes.run(
      () => _BookmarkMutations(this)._addBookmark(url, title, folder: folder),
    );
    final normalizedFolder = normalizeBookmarkFolderName(folder);
    if (result && normalizedFolder != null) {
      await ref
          .read(bookmarkFoldersProvider.notifier)
          .ensureFolder(normalizedFolder);
    }
    return result;
  }

  Future<bool> removeBookmark(BookmarkedArticle item) =>
      _writes.run(() => _BookmarkMutations(this)._removeBookmark(item));

  Future<bool> toggleBookmark(String url, String title) =>
      _writes.run(() => _BookmarkMutations(this)._toggleBookmark(url, title));

  Future<bool> clearBookmarks() =>
      _writes.run(() => _BookmarkMutations(this)._clearBookmarks());

  Future<bool> setArticleFolder(String url, String? folder) async {
    final result = await _writes.run(
      () => _BookmarkFolderMutations(this)._setArticleFolder(url, folder),
    );
    final normalizedFolder = normalizeBookmarkFolderName(folder);
    if (result && normalizedFolder != null) {
      await ref
          .read(bookmarkFoldersProvider.notifier)
          .ensureFolder(normalizedFolder);
    }
    return result;
  }

  Future<bool> renameFolder(String oldName, String newName) => _writes.run(
    () => _BookmarkFolderMutations(this)._renameFolder(oldName, newName),
  );

  Future<int> importBookmarks(List<BookmarkedArticle> entries) async {
    final result = await _writes.run(
      () => _BookmarkBackupMutations(this)._importBookmarks(entries),
    );
    if (result > 0) {
      final folders = ref.read(bookmarkFoldersProvider.notifier);
      for (final entry in state.requireValue) {
        if (entry.folder case final folder?) await folders.ensureFolder(folder);
      }
    }
    return result;
  }

  Future<int> restoreUnreadableLibrary(
    List<BookmarkedArticle> entries,
    List<String> folders,
  ) => _writes.run(
    () =>
        _BookmarkBackupMutations(this)
            ._restoreUnreadableLibrary(entries, folders),
  );

  Future<bool> clearFolder(String name) =>
      _writes.run(() => _BookmarkFolderMutations(this)._clearFolder(name));
}

/// Stored bookmark folder list plus coordination with article folders.
///
/// The UI-facing list is [allBookmarkFoldersProvider]: the union of stored
/// folders and folders referenced by articles.
@Riverpod(keepAlive: true, retry: _neverRetrySnapshotRead)
class BookmarkFolders() extends _$BookmarkFolders {
  SerialTaskQueue get _writes => ref.read(bookmarkWritesProvider);
  Ref get _foldersRef => ref;
  List<String> get _currentFolders => state.value ?? const <String>[];

  Future<List<BookmarkedArticle>?> _readArticles() async {
    try {
      final articles = await ref.read(bookmarksProvider.future);
      return ref.mounted ? articles : null;
    } catch (e) {
      debugPrint('Bookmarks unavailable for folder update: $e');
      return null;
    }
  }

  Future<BookmarksService?> _service() async {
    try {
      await future;
      if (!ref.mounted) return null;
      final prefs = await ref.read(sharedPreferencesProvider.future);
      return BookmarksService(prefs);
    } catch (e) {
      debugPrint('BookmarksService unavailable: $e');
      return null;
    }
  }

  @override
  FutureOr<List<String>> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return BookmarksService(prefs).getFolders();
  }

  void _applySavedFolders(List<String> folders) {
    if (ref.mounted) state = AsyncData(folders);
  }

  Future<bool> ensureFolder(String name) =>
      _writes.run(() => _BookmarkFoldersMutations(this)._ensureFolder(name));

  Future<bool> createFolder(String name) => ensureFolder(name);

  Future<bool> renameFolder(String oldName, String newName) => _writes.run(
    () => _BookmarkFoldersMutations(this)._renameFolder(oldName, newName),
  );

  Future<bool> deleteFolder(String name) =>
      _writes.run(() => _BookmarkFoldersMutations(this)._deleteFolder(name));
}

/// Union of stored folders and folders referenced by bookmarked articles,
/// for filter chips and pickers.
@riverpod
List<String> allBookmarkFolders(Ref ref) {
  final stored = ref.watch(bookmarkFoldersProvider).value ?? const <String>[];
  final articles =
      ref.watch(bookmarksProvider).value ?? const <BookmarkedArticle>[];
  return mergeBookmarkFolders(stored, [
    for (final article in articles) article.folder,
  ]);
}
