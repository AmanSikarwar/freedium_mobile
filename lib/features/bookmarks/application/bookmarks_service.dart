import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freedium_mobile/core/utils/url.dart' show normalizeHttpUrl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmark_folder.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';

class BookmarksService(this._prefs) {
  static const String _snapshotKey = 'bookmark_library';
  static const String _bookmarksKey = 'bookmarked_articles';
  static const String _foldersKey = 'bookmark_folders';
  final SharedPreferences _prefs;

  List<BookmarkedArticle> getBookmarks() {
    final json = _readList(_bookmarksKey);
    if (json == null) return [];

    final List<BookmarkedArticle> bookmarks = [];
    final seenUrls = <String>{};
    for (final entry in json) {
      try {
        final decoded = jsonDecode(entry) as Map<String, dynamic>;
        final bookmark = BookmarkedArticle.fromJson(decoded);
        final url = normalizeHttpUrl(bookmark.url);
        if (url == null || !seenUrls.add(url)) {
          continue;
        }
        final title = bookmark.title.trim();
        bookmarks.add(
          bookmark.copyWith(
            url: url,
            title: title.isNotEmpty ? title : url,
            folder: normalizeBookmarkFolderName(bookmark.folder),
          ),
        );
      } catch (e) {
        debugPrint('Failed to parse bookmark entry: $e');
      }
    }

    bookmarks.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return bookmarks;
  }

  Future<void> saveBookmarks(List<BookmarkedArticle> bookmarks) =>
      saveLibrary(bookmarks, getFolders());

  Future<void> clearBookmarks() => saveLibrary(const [], getFolders());

  /// Reads the stored folder list (normalized, deduped, sorted).
  /// Folders referenced only by articles are unioned in by the provider.
  List<String> getFolders() {
    final raw = _readList(_foldersKey);
    if (raw == null) return [];
    return mergeBookmarkFolders(raw, const []);
  }

  Future<void> saveFolders(List<String> folders) =>
      saveLibrary(getBookmarks(), folders);

  List<String>? _readList(String key) {
    final raw = _prefs.getString(_snapshotKey);
    if (raw == null) return _prefs.getStringList(key);
    final snapshot = jsonDecode(raw) as Map<String, dynamic>;
    if (snapshot['version'] != 1) {
      throw const FormatException('Unsupported bookmark library snapshot');
    }
    return (snapshot[key] as List<dynamic>).cast<String>();
  }

  /// Article and folder changes become visible together in one write.
  Future<void> saveLibrary(
    List<BookmarkedArticle> bookmarks,
    List<String> folders,
  ) async {
    final snapshot = jsonEncode({
      'version': 1,
      _bookmarksKey: bookmarks.map((b) => jsonEncode(b.toJson())).toList(),
      _foldersKey: mergeBookmarkFolders(folders, const []),
    });
    try {
      if (!await _prefs.setString(_snapshotKey, snapshot)) {
        throw StateError('Failed to save bookmark library');
      }
    } catch (_) {
      await _prefs.reload();
      rethrow;
    }
  }
}
