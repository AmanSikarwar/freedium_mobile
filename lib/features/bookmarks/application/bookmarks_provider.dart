import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/utils/url.dart' show normalizeHttpUrl;
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_service.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmark_folder.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';

export 'package:freedium_mobile/features/bookmarks/domain/bookmark_folder.dart';
export 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';

part 'bookmarks_provider.g.dart';

@Riverpod(keepAlive: true)
class Bookmarks() extends _$Bookmarks {
  static const int maxBookmarks = 100;

  Future<BookmarksService?> _service() async {
    try {
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

  /// Returns true if the given [url] is already bookmarked.
  bool isBookmarked(String url) {
    final normalizedUrl = normalizeHttpUrl(url);
    if (normalizedUrl == null) return false;
    final current = state.value ?? const <BookmarkedArticle>[];
    return current.any((b) => b.url == normalizedUrl);
  }

  Future<bool> addBookmark(String url, String title, {String? folder}) async {
    final service = await _service();
    if (service == null) return false;
    final normalizedUrl = normalizeHttpUrl(url);
    if (normalizedUrl == null) return false;
    if (isBookmarked(normalizedUrl)) return true; // already saved
    final normalizedTitle = title.trim().isNotEmpty
        ? title.trim()
        : normalizedUrl;
    final normalizedFolder = normalizeBookmarkFolderName(folder);

    final current = state.value ?? const <BookmarkedArticle>[];
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

    if (newList.length > maxBookmarks) {
      newList.removeLast();
    }

    try {
      await service.saveBookmarks(newList);
      state = AsyncData(newList);
      if (normalizedFolder != null) {
        await ref
            .read(bookmarkFoldersProvider.notifier)
            .ensureFolder(normalizedFolder);
      }
      return true;
    } catch (e) {
      debugPrint('Failed to save bookmark: $e');
      return false;
    }
  }

  Future<bool> removeBookmark(BookmarkedArticle item) async {
    final service = await _service();
    if (service == null) return false;

    final current = state.value ?? const <BookmarkedArticle>[];
    final newList = current.where((b) => b.url != item.url).toList();

    try {
      await service.saveBookmarks(newList);
      state = AsyncData(newList);
      return true;
    } catch (e) {
      debugPrint('Failed to remove bookmark: $e');
      return false;
    }
  }

  /// Toggles the bookmark state for [url]. Adds if absent, removes if present.
  Future<bool> toggleBookmark(String url, String title) async {
    final normalizedUrl = normalizeHttpUrl(url);
    if (normalizedUrl == null) return false;

    if (isBookmarked(normalizedUrl)) {
      final current = state.value ?? const <BookmarkedArticle>[];
      final item = current.firstWhere((b) => b.url == normalizedUrl);
      return removeBookmark(item);
    }
    return addBookmark(normalizedUrl, title);
  }

  Future<bool> clearBookmarks() async {
    final service = await _service();
    if (service == null) return false;

    try {
      await service.clearBookmarks();
      state = const AsyncData([]);
      return true;
    } catch (e) {
      debugPrint('Failed to clear bookmarks: $e');
      return false;
    }
  }

  /// Moves the bookmark for [url] into [folder] (null = Unsorted).
  /// The folder is registered in the stored folder list when there is room;
  /// the article keeps the folder regardless (derived union always includes
  /// referenced folders).
  Future<bool> setArticleFolder(String url, String? folder) async {
    final service = await _service();
    if (service == null) return false;
    final normalizedUrl = normalizeHttpUrl(url);
    if (normalizedUrl == null) return false;
    final normalizedFolder = normalizeBookmarkFolderName(folder);

    final current = state.value ?? const <BookmarkedArticle>[];
    if (!current.any((b) => b.url == normalizedUrl)) return false;
    final newList = [
      for (final b in current)
        if (b.url == normalizedUrl) b.copyWith(folder: normalizedFolder) else b,
    ];

    try {
      await service.saveBookmarks(newList);
      state = AsyncData(newList);
      if (normalizedFolder != null) {
        await ref
            .read(bookmarkFoldersProvider.notifier)
            .ensureFolder(normalizedFolder);
      }
      return true;
    } catch (e) {
      debugPrint('Failed to move bookmark to folder: $e');
      return false;
    }
  }

  /// Renames every article folder matching [oldName] (case-insensitive) to
  /// [newName]. Returns true without writing when nothing references it
  /// (stored list is handled by the folders provider).
  Future<bool> renameFolder(String oldName, String newName) async {
    final service = await _service();
    if (service == null) return false;
    final oldNormalized = normalizeBookmarkFolderName(oldName);
    final newNormalized = normalizeBookmarkFolderName(newName);
    if (oldNormalized == null || newNormalized == null) return false;

    final current = state.value ?? const <BookmarkedArticle>[];
    if (!current.any(
      (b) => b.folder?.toLowerCase() == oldNormalized.toLowerCase(),
    )) {
      return true;
    }
    final newList = [
      for (final b in current)
        if (b.folder?.toLowerCase() == oldNormalized.toLowerCase())
          b.copyWith(folder: newNormalized)
        else
          b,
    ];

    try {
      await service.saveBookmarks(newList);
      state = AsyncData(newList);
      return true;
    } catch (e) {
      debugPrint('Failed to rename bookmark folder: $e');
      return false;
    }
  }

  /// Merges backup [entries] into the current list: existing URLs keep
  /// their saved data, new entries are inserted newest-first, and the list
  /// is trimmed to [maxBookmarks]. Returns the number of entries added.
  Future<int> importBookmarks(List<BookmarkedArticle> entries) async {
    final service = await _service();
    if (service == null) return 0;
    if (entries.isEmpty) return 0;

    final current = state.value ?? const <BookmarkedArticle>[];
    final knownUrls = {for (final b in current) b.url};
    final fresh = <BookmarkedArticle>[];
    for (final entry in entries) {
      if (knownUrls.add(entry.url)) {
        fresh.add(entry);
      }
    }
    if (fresh.isEmpty) return 0;

    fresh.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    final merged = [...fresh, ...current];
    final newList = merged.length > maxBookmarks
        ? merged.sublist(0, maxBookmarks)
        : merged;

    try {
      await service.saveBookmarks(newList);
      state = AsyncData(newList);
      final folders = ref.read(bookmarkFoldersProvider.notifier);
      for (final entry in newList) {
        final folder = entry.folder;
        if (folder != null) {
          await folders.ensureFolder(folder);
        }
      }
      return fresh.length;
    } catch (e) {
      debugPrint('Failed to import bookmarks: $e');
      return 0;
    }
  }

  /// Clears the folder (back to Unsorted) on every article matching [name]
  /// (case-insensitive).
  Future<bool> clearFolder(String name) async {
    final service = await _service();
    if (service == null) return false;
    final normalized = normalizeBookmarkFolderName(name);
    if (normalized == null) return false;

    final current = state.value ?? const <BookmarkedArticle>[];
    final newList = [
      for (final b in current)
        if (b.folder?.toLowerCase() == normalized.toLowerCase())
          b.copyWith(folder: null)
        else
          b,
    ];

    try {
      await service.saveBookmarks(newList);
      state = AsyncData(newList);
      return true;
    } catch (e) {
      debugPrint('Failed to clear bookmark folder: $e');
      return false;
    }
  }
}

/// Stored bookmark folder list plus coordination with article folders.
///
/// The UI-facing list is [allBookmarkFoldersProvider]: the union of stored
/// folders and folders referenced by articles.
@Riverpod(keepAlive: true)
class BookmarkFolders() extends _$BookmarkFolders {
  Future<BookmarksService?> _service() async {
    try {
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

  /// Adds [name] to the stored list unless present. Idempotent: duplicates
  /// (case-insensitive) report success. Returns false for blank names, a
  /// full list, or persistence failures.
  Future<bool> ensureFolder(String name) async {
    final service = await _service();
    if (service == null) return false;
    final normalized = normalizeBookmarkFolderName(name);
    if (normalized == null) return false;

    final current = state.value ?? const <String>[];
    if (isBookmarkFolderDuplicate(normalized, current)) return true;
    if (current.length >= maxBookmarkFolders) return false;

    final next = [...current, normalized]
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    try {
      await service.saveFolders(next);
      state = AsyncData(next);
      return true;
    } catch (e) {
      debugPrint('Failed to save bookmark folder: $e');
      return false;
    }
  }

  Future<bool> createFolder(String name) => ensureFolder(name);

  /// Renames the stored folder [oldName] to [newName] and rewrites matching
  /// article folders. Articles keep their content; nothing is deleted.
  Future<bool> renameFolder(String oldName, String newName) async {
    final service = await _service();
    if (service == null) return false;
    final oldNormalized = normalizeBookmarkFolderName(oldName);
    final newNormalized = normalizeBookmarkFolderName(newName);
    if (oldNormalized == null || newNormalized == null) return false;

    final current = state.value ?? const <String>[];
    if (!current.any((f) => f.toLowerCase() == oldNormalized.toLowerCase())) {
      return false;
    }
    if (isBookmarkFolderDuplicate(
      newNormalized,
      current,
      exclude: oldNormalized,
    )) {
      return false;
    }

    final bookmarks = ref.read(bookmarksProvider.notifier);
    final articlesRenamed = await bookmarks.renameFolder(
      oldNormalized,
      newNormalized,
    );
    if (!articlesRenamed) return false;

    final next = [
      for (final f in current)
        if (f.toLowerCase() == oldNormalized.toLowerCase())
          newNormalized
        else
          f,
    ];
    try {
      await service.saveFolders(next);
      state = AsyncData(next);
      return true;
    } catch (e) {
      debugPrint('Failed to rename bookmark folder: $e');
      return false;
    }
  }

  /// Deletes the stored folder [name] and moves its articles to Unsorted.
  Future<bool> deleteFolder(String name) async {
    final service = await _service();
    if (service == null) return false;
    final normalized = normalizeBookmarkFolderName(name);
    if (normalized == null) return false;

    final current = state.value ?? const <String>[];
    if (!current.any((f) => f.toLowerCase() == normalized.toLowerCase())) {
      return false;
    }

    final bookmarks = ref.read(bookmarksProvider.notifier);
    final articlesCleared = await bookmarks.clearFolder(normalized);
    if (!articlesCleared) return false;

    final next = [
      for (final f in current)
        if (f.toLowerCase() != normalized.toLowerCase()) f,
    ];
    try {
      await service.saveFolders(next);
      state = AsyncData(next);
      return true;
    } catch (e) {
      debugPrint('Failed to delete bookmark folder: $e');
      return false;
    }
  }
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
