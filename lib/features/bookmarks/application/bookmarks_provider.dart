import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_service.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';

export 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';

class BookmarksNotifier extends Notifier<List<BookmarkedArticle>> {
  BookmarksService? _service;

  Future<BookmarksService?> _ensureService() async {
    final existing = _service;
    if (existing != null) return existing;

    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final service = BookmarksService(prefs);
      _service = service;
      state = service.getBookmarks();
      return service;
    } catch (e) {
      debugPrint('BookmarksService unavailable: $e');
      return null;
    }
  }

  @override
  List<BookmarkedArticle> build() {
    final prefsAsync = ref.watch(sharedPreferencesProvider);

    return prefsAsync.when(
      data: (prefs) {
        _service = BookmarksService(prefs);
        return _service!.getBookmarks();
      },
      loading: () => const [],
      error: (e, _) {
        debugPrint('Failed to load SharedPreferences for bookmarks: $e');
        return const [];
      },
    );
  }

  /// Returns true if the given [url] is already bookmarked.
  bool isBookmarked(String url) {
    final normalizedUrl = _normalizeBookmarkUrl(url);
    if (normalizedUrl == null) return false;
    return state.any((b) => b.url == normalizedUrl);
  }

  Future<void> addBookmark(String url, String title) async {
    final service = await _ensureService();
    if (service == null) return;
    final normalizedUrl = _normalizeBookmarkUrl(url);
    if (normalizedUrl == null) return;
    if (isBookmarked(normalizedUrl)) return; // already saved
    final normalizedTitle = title.trim().isNotEmpty
        ? title.trim()
        : normalizedUrl;

    final prevState = state;
    final newList = List<BookmarkedArticle>.from(state);
    newList.insert(
      0,
      BookmarkedArticle(
        url: normalizedUrl,
        title: normalizedTitle,
        savedAt: DateTime.now(),
      ),
    );

    if (newList.length > 100) {
      newList.removeLast();
    }

    try {
      await service.saveBookmarks(newList);
      state = newList;
    } catch (e) {
      debugPrint('Failed to save bookmark: $e');
      state = prevState;
    }
  }

  Future<void> removeBookmark(BookmarkedArticle item) async {
    final service = await _ensureService();
    if (service == null) return;

    final prevState = state;
    final newList = state.where((b) => b.url != item.url).toList();

    try {
      await service.saveBookmarks(newList);
      state = newList;
    } catch (e) {
      debugPrint('Failed to remove bookmark: $e');
      state = prevState;
    }
  }

  /// Toggles the bookmark state for [url]. Adds if absent, removes if present.
  Future<void> toggleBookmark(String url, String title) async {
    if (await _ensureService() == null) return;

    final normalizedUrl = _normalizeBookmarkUrl(url);
    if (normalizedUrl == null) return;

    if (isBookmarked(normalizedUrl)) {
      final item = state.firstWhere((b) => b.url == normalizedUrl);
      await removeBookmark(item);
    } else {
      await addBookmark(normalizedUrl, title);
    }
  }

  Future<void> clearBookmarks() async {
    final service = await _ensureService();
    if (service == null) return;

    final prevState = state;
    try {
      await service.clearBookmarks();
      state = [];
    } catch (e) {
      debugPrint('Failed to clear bookmarks: $e');
      state = prevState;
    }
  }
}

String? _normalizeBookmarkUrl(String value) {
  final url = value.trim();
  final uri = Uri.tryParse(url);
  final scheme = uri?.scheme.toLowerCase();
  if (uri == null ||
      uri.host.isEmpty ||
      (scheme != 'http' && scheme != 'https')) {
    return null;
  }
  return url;
}

final bookmarksProvider =
    NotifierProvider<BookmarksNotifier, List<BookmarkedArticle>>(
      BookmarksNotifier.new,
    );
