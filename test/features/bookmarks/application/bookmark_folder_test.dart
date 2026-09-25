import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_service.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmark_folder.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';

import '../../../test_helpers.dart';

void main() {
  group('normalizeBookmarkFolderName', () {
    test('trims surrounding whitespace', () {
      expect(normalizeBookmarkFolderName('  Tech  '), 'Tech');
    });

    test('maps blank and null to null (Unsorted)', () {
      expect(normalizeBookmarkFolderName(null), isNull);
      expect(normalizeBookmarkFolderName(''), isNull);
      expect(normalizeBookmarkFolderName('   '), isNull);
    });

    test('truncates names longer than the maximum', () {
      final long = 'a' * (maxBookmarkFolderNameLength + 10);
      expect(
        normalizeBookmarkFolderName(long),
        hasLength(maxBookmarkFolderNameLength),
      );
    });
  });

  group('mergeBookmarkFolders', () {
    test('unions stored and referenced folders sorted', () {
      expect(mergeBookmarkFolders(['Work'], ['Tech', null, '  ']), [
        'Tech',
        'Work',
      ]);
    });

    test('dedups case-insensitively keeping first casing', () {
      expect(mergeBookmarkFolders(['tech'], ['Tech', 'TECH']), ['tech']);
    });
  });

  group('isBookmarkFolderDuplicate', () {
    test('detects duplicates ignoring case and whitespace', () {
      expect(isBookmarkFolderDuplicate('tech', ['Tech']), isTrue);
      expect(isBookmarkFolderDuplicate(' Other ', ['Tech']), isFalse);
      expect(isBookmarkFolderDuplicate('  ', ['Tech']), isFalse);
    });

    test('exclude supports renames', () {
      expect(
        isBookmarkFolderDuplicate('TECH', ['Tech'], exclude: 'tech'),
        isFalse,
      );
      expect(
        isBookmarkFolderDuplicate('Work', ['Tech', 'Work'], exclude: 'tech'),
        isTrue,
      );
    });
  });

  group('BookmarksService folders', () {
    test('loads legacy entries without a folder as Unsorted', () async {
      final prefs = await mockPrefs({
        'bookmarked_articles': [
          jsonEncode({
            'url': TestFixtures.storyUrl,
            'title': 'Legacy',
            'savedAt': TestFixtures.seedDate.toIso8601String(),
          }),
        ],
      });

      final bookmarks = BookmarksService(prefs).getBookmarks();

      expect(bookmarks, hasLength(1));
      expect(bookmarks.single.folder, isNull);
    });

    test('normalizes folder fields on load', () async {
      BookmarkedArticle entry(String? folder) => BookmarkedArticle(
        url: TestFixtures.storyUrl,
        title: 'T',
        savedAt: TestFixtures.seedDate,
        folder: folder,
      );
      final prefs = await mockPrefs({
        'bookmarked_articles': [
          jsonEncode(entry('  Tech  ').toJson()),
          jsonEncode(
            entry('').toJson().map(
              (key, value) => MapEntry(key, key == 'url' ? '$value-2' : value),
            ),
          ),
        ],
      });

      final bookmarks = BookmarksService(prefs).getBookmarks();

      expect(bookmarks.map((b) => b.folder), ['Tech', null]);
    });

    test('round-trips the stored folder list normalized', () async {
      final prefs = await mockPrefs();
      final service = BookmarksService(prefs);

      await service.saveFolders(['  Work ', 'work', '', 'Tech']);
      expect(service.getFolders(), ['Tech', 'Work']);

      final stored = prefs.getStringList('bookmark_folders');
      expect(stored, ['Tech', 'Work']);
    });

    test('returns empty folders when nothing is stored', () async {
      final prefs = await mockPrefs();
      expect(BookmarksService(prefs).getFolders(), isEmpty);
    });

    test('persists folder on bookmark entries', () async {
      final prefs = await mockPrefs();
      final service = BookmarksService(prefs);

      await service.saveBookmarks([
        BookmarkedArticle(
          url: TestFixtures.storyUrl,
          title: 'T',
          savedAt: TestFixtures.seedDate,
          folder: 'Tech',
        ),
      ]);

      final reloaded = BookmarksService(prefs).getBookmarks();
      expect(reloaded.single.folder, 'Tech');
    });
  });
}
