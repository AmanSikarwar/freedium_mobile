import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_service.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../test_helpers.dart';

void main() {
  group('BookmarksService', () {
    test('getBookmarks skips invalid and duplicate bookmark entries', () async {
      final savedAt = TestFixtures.seedDate;
      final bookmark = BookmarkedArticle(
        url: TestFixtures.storyUrl,
        title: 'Example story',
        savedAt: savedAt,
      );

      await mockPrefs({
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
          jsonEncode(
            bookmark
                .copyWith(
                  url: ' HTTPS://Medium.COM/example/story/ ',
                  title: 'Duplicate',
                )
                .toJson(),
          ),
        ],
      });

      final service = BookmarksService(await SharedPreferences.getInstance());

      expect(service.getBookmarks(), [bookmark]);
    });

    test('getBookmarks falls back to URL when title is blank', () async {
      final savedAt = TestFixtures.seedDate;
      await mockPrefs({
        'bookmarked_articles': [
          jsonEncode({
            'url': ' HTTPS://Medium.COM/example/story/ ',
            'title': ' ',
            'savedAt': savedAt.toIso8601String(),
          }),
        ],
      });

      final service = BookmarksService(await SharedPreferences.getInstance());

      final bookmarks = service.getBookmarks();
      expect(bookmarks, hasLength(1));
      expect(bookmarks.single.title, TestFixtures.storyUrl);
    });
  });
}
