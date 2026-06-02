import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_service.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('BookmarksService', () {
    test('getBookmarks skips invalid and duplicate bookmark entries', () async {
      final savedAt = DateTime.utc(2026, 2, 3);
      final bookmark = BookmarkedArticle(
        url: 'https://medium.com/example/story',
        title: 'Example story',
        savedAt: savedAt,
      );

      SharedPreferences.setMockInitialValues({
        'bookmarked_articles': [
          '{bad json',
          jsonEncode({
            'url': '',
            'title': 'Blank URL',
            'savedAt': savedAt.toIso8601String(),
          }),
          jsonEncode({
            'url': 'ftp://example.com/story',
            'title': 'Unsupported scheme',
            'savedAt': savedAt.toIso8601String(),
          }),
          jsonEncode(bookmark.toJson()),
          jsonEncode(bookmark.copyWith(title: 'Duplicate').toJson()),
        ],
      });

      final prefs = await SharedPreferences.getInstance();
      final service = BookmarksService(prefs);

      expect(service.getBookmarks(), [bookmark]);
    });

    test('getBookmarks falls back to URL when title is blank', () async {
      final savedAt = DateTime.utc(2026, 2, 3);
      SharedPreferences.setMockInitialValues({
        'bookmarked_articles': [
          jsonEncode({
            'url': 'https://medium.com/example/story',
            'title': ' ',
            'savedAt': savedAt.toIso8601String(),
          }),
        ],
      });

      final prefs = await SharedPreferences.getInstance();
      final service = BookmarksService(prefs);

      final bookmarks = service.getBookmarks();
      expect(bookmarks, hasLength(1));
      expect(bookmarks.single.title, 'https://medium.com/example/story');
    });
  });
}
