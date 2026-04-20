import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';

class BookmarksService {
  static const String _bookmarksKey = 'bookmarked_articles';
  final SharedPreferences _prefs;

  BookmarksService(this._prefs);

  List<BookmarkedArticle> getBookmarks() {
    final json = _prefs.getStringList(_bookmarksKey);
    if (json == null) return [];

    final List<BookmarkedArticle> bookmarks = [];
    for (final entry in json) {
      try {
        final decoded = jsonDecode(entry) as Map<String, dynamic>;
        bookmarks.add(BookmarkedArticle.fromJson(decoded));
      } catch (e) {
        debugPrint('Failed to parse bookmark entry: $e');
      }
    }

    bookmarks.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return bookmarks;
  }

  Future<void> saveBookmarks(List<BookmarkedArticle> bookmarks) async {
    try {
      final json = bookmarks.map((e) => jsonEncode(e.toJson())).toList();
      final success = await _prefs.setStringList(_bookmarksKey, json);
      if (!success) {
        throw Exception(
          'setStringList returned false for key "$_bookmarksKey"',
        );
      }
    } catch (e) {
      debugPrint('Failed to save bookmarks to "$_bookmarksKey": $e');
      rethrow;
    }
  }

  Future<void> clearBookmarks() async {
    try {
      final success = await _prefs.remove(_bookmarksKey);
      if (!success) {
        throw Exception('remove returned false for key "$_bookmarksKey"');
      }
    } catch (e) {
      debugPrint('Failed to clear bookmarks key "$_bookmarksKey": $e');
      rethrow;
    }
  }
}
