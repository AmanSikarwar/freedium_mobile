import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/utils/url.dart' show normalizeHttpUrl;
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_service.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';

export 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';

part 'bookmarks_provider.g.dart';

@Riverpod(keepAlive: true)
class Bookmarks extends _$Bookmarks {
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

  Future<bool> addBookmark(String url, String title) async {
    final service = await _service();
    if (service == null) return false;
    final normalizedUrl = normalizeHttpUrl(url);
    if (normalizedUrl == null) return false;
    if (isBookmarked(normalizedUrl)) return true; // already saved
    final normalizedTitle = title.trim().isNotEmpty
        ? title.trim()
        : normalizedUrl;

    final current = state.value ?? const <BookmarkedArticle>[];
    final newList = List<BookmarkedArticle>.from(current);
    newList.insert(
      0,
      BookmarkedArticle(
        url: normalizedUrl,
        title: normalizedTitle,
        savedAt: DateTime.now(),
      ),
    );

    if (newList.length > maxBookmarks) {
      newList.removeLast();
    }

    try {
      await service.saveBookmarks(newList);
      state = AsyncData(newList);
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
}
