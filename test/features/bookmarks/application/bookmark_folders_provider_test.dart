import 'dart:convert';

import 'package:freedium_mobile/features/bookmarks/application/bookmarks_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmarks_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../../../test_helpers.dart';

void main() {
  group('BookmarkFolders', () {
    late ProviderContainer container;

    setUp(() async {
      container = prefsContainer(await mockPrefs());
    });

    tearDown(() {
      container.dispose();
    });

    test('creates folders trimmed and sorted, dedups idempotently', () async {
      final notifier = container.read(bookmarkFoldersProvider.notifier);

      expect(await notifier.createFolder('  Work  '), isTrue);
      expect(await notifier.createFolder('tech'), isTrue);
      expect(await notifier.createFolder('TECH'), isTrue);
      expect(await notifier.createFolder('   '), isFalse);

      expect(container.read(bookmarkFoldersProvider).requireValue, [
        'tech',
        'Work',
      ]);
    });

    test('refuses new folders past the cap', () async {
      final seeded = {
        'bookmark_folders': [
          for (var i = 0; i < maxBookmarkFolders; i++) 'Folder $i',
        ],
      };
      container.dispose();
      container = prefsContainer(await mockPrefs(seeded));
      await container.read(bookmarkFoldersProvider.future);

      final didCreate = await container
          .read(bookmarkFoldersProvider.notifier)
          .createFolder('One more');

      expect(didCreate, isFalse);
      expect(
        container.read(bookmarkFoldersProvider).requireValue,
        hasLength(maxBookmarkFolders),
      );
    });

    test(
      'manages imported article folders beyond the stored-folder cap',
      () async {
        final storedFolders = [
          for (var i = 0; i < maxBookmarkFolders; i++) 'Saved $i',
        ]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        final articles = [
          BookmarkedArticle(
            url: TestFixtures.storyUrl,
            title: 'Imported story',
            savedAt: TestFixtures.seedDate,
            folder: 'Alpha imported',
          ),
          BookmarkedArticle(
            url: 'https://medium.com/used-folder',
            title: 'Another story',
            savedAt: TestFixtures.seedDate,
            folder: 'Already used',
          ),
        ];
        container.dispose();
        final prefs = await mockPrefs({
          'bookmark_folders': storedFolders,
          'bookmarked_articles': [
            for (final article in articles) jsonEncode(article.toJson()),
          ],
        });
        container = prefsContainer(prefs);
        await container.read(bookmarksProvider.future);
        await container.read(bookmarkFoldersProvider.future);

        final folders = container.read(bookmarkFoldersProvider.notifier);
        expect(container.read(allBookmarkFoldersProvider), [
          'Alpha imported',
          'Already used',
          ...storedFolders,
        ]);
        expect(await folders.ensureFolder(' alpha imported '), isTrue);
        expect(
          await folders.renameFolder('Alpha imported', 'Already used'),
          isFalse,
        );
        expect(
          await folders.renameFolder('Alpha imported', 'Renamed imported'),
          isTrue,
        );
        expect(
          container.read(bookmarkFoldersProvider).requireValue,
          storedFolders,
        );
        expect(
          container.read(allBookmarkFoldersProvider),
          contains('Renamed imported'),
        );
        expect(
          container
              .read(bookmarksProvider)
              .requireValue
              .firstWhere((article) => article.url == TestFixtures.storyUrl)
              .folder,
          'Renamed imported',
        );
        expect(
          BookmarksService(prefs).getFolders(),
          hasLength(maxBookmarkFolders),
        );

        expect(await folders.deleteFolder('Renamed imported'), isTrue);
        expect(
          container.read(bookmarkFoldersProvider).requireValue,
          storedFolders,
        );
        expect(
          container.read(allBookmarkFoldersProvider),
          isNot(contains('Renamed imported')),
        );
        expect(
          BookmarksService(prefs)
              .getBookmarks()
              .firstWhere((article) => article.url == TestFixtures.storyUrl)
              .folder,
          isNull,
        );
        expect(
          BookmarksService(prefs).getFolders(),
          hasLength(maxBookmarkFolders),
        );
      },
    );

    test('renames stored folders and rewrites article folders', () async {
      final bookmarks = container.read(bookmarksProvider.notifier);
      await bookmarks.addBookmark(
        TestFixtures.storyUrl,
        'Story',
        folder: 'tech',
      );
      await container.read(bookmarksProvider.future);
      await container.read(bookmarkFoldersProvider.future);

      final didRename = await container
          .read(bookmarkFoldersProvider.notifier)
          .renameFolder('TECH', 'Engineering');

      expect(didRename, isTrue);
      expect(container.read(bookmarkFoldersProvider).requireValue, [
        'Engineering',
      ]);
      expect(
        container.read(bookmarksProvider).requireValue.single.folder,
        'Engineering',
      );
    });

    test('rejects renames to duplicates or missing folders', () async {
      final notifier = container.read(bookmarkFoldersProvider.notifier);
      await notifier.createFolder('Tech');
      await notifier.createFolder('Work');

      expect(await notifier.renameFolder('Tech', 'work'), isFalse);
      expect(await notifier.renameFolder('Missing', 'Other'), isFalse);
      expect(await notifier.renameFolder('Tech', '   '), isFalse);
      expect(container.read(bookmarkFoldersProvider).requireValue, [
        'Tech',
        'Work',
      ]);
    });

    test('deletes folders and moves articles to Unsorted', () async {
      final bookmarks = container.read(bookmarksProvider.notifier);
      await bookmarks.addBookmark(
        TestFixtures.storyUrl,
        'Story',
        folder: 'Tech',
      );
      await container.read(bookmarksProvider.future);

      final didDelete = await container
          .read(bookmarkFoldersProvider.notifier)
          .deleteFolder('tech');

      expect(didDelete, isTrue);
      expect(container.read(bookmarkFoldersProvider).requireValue, isEmpty);
      expect(
        container.read(bookmarksProvider).requireValue.single.folder,
        isNull,
      );
      expect(
        await container
            .read(bookmarkFoldersProvider.notifier)
            .deleteFolder('Tech'),
        isFalse,
      );
    });

    test('reports failure when folder persistence fails', () async {
      container.dispose();
      SharedPreferencesStorePlatform.instance = FailingPrefsStore();
      SharedPreferences.resetStatic();
      addTearDown(() => SharedPreferences.setMockInitialValues({}));
      final prefs = await SharedPreferences.getInstance();
      container = prefsContainer(prefs);
      await container.read(bookmarkFoldersProvider.future);

      final didCreate = await container
          .read(bookmarkFoldersProvider.notifier)
          .createFolder('Tech');

      expect(didCreate, isFalse);
    });
  });

  group('Bookmarks folders', () {
    late ProviderContainer container;

    setUp(() async {
      container = prefsContainer(await mockPrefs());
    });

    tearDown(() {
      container.dispose();
    });

    test('assigns folders and registers them for filters', () async {
      final bookmarks = container.read(bookmarksProvider.notifier);
      await bookmarks.addBookmark(TestFixtures.storyUrl, 'Story');
      await container.read(bookmarksProvider.future);
      await container.read(bookmarkFoldersProvider.future);

      expect(
        await bookmarks.setArticleFolder(TestFixtures.storyUrl, '  Tech '),
        isTrue,
      );

      expect(
        container.read(bookmarksProvider).requireValue.single.folder,
        'Tech',
      );
      expect(container.read(allBookmarkFoldersProvider), ['Tech']);
    });

    test('unassigns folders back to Unsorted', () async {
      final bookmarks = container.read(bookmarksProvider.notifier);
      await bookmarks.addBookmark(
        TestFixtures.storyUrl,
        'Story',
        folder: 'Tech',
      );
      await container.read(bookmarksProvider.future);

      expect(
        await bookmarks.setArticleFolder(TestFixtures.storyUrl, null),
        isTrue,
      );
      expect(
        container.read(bookmarksProvider).requireValue.single.folder,
        isNull,
      );
    });

    test('rejects folder moves for unknown bookmarks', () async {
      await container.read(bookmarksProvider.future);

      expect(
        await container
            .read(bookmarksProvider.notifier)
            .setArticleFolder(TestFixtures.storyUrl, 'Tech'),
        isFalse,
      );
    });

    test('unions stored and referenced folders for filters', () async {
      final bookmarks = container.read(bookmarksProvider.notifier);
      await bookmarks.addBookmark(
        TestFixtures.storyUrl,
        'Story',
        folder: 'Referenced',
      );
      await container.read(bookmarksProvider.future);
      await container
          .read(bookmarkFoldersProvider.notifier)
          .createFolder('Stored');

      expect(container.read(allBookmarkFoldersProvider), [
        'Referenced',
        'Stored',
      ]);
    });
  });

  group('Bookmarks import', () {
    late ProviderContainer container;

    setUp(() async {
      container = prefsContainer(await mockPrefs());
    });

    tearDown(() {
      container.dispose();
    });

    BookmarkedArticle entry(String url, {String? folder}) => BookmarkedArticle(
      url: url,
      title: 'Title',
      savedAt: TestFixtures.seedDate,
      folder: folder,
    );

    test(
      'capacity preserves existing entries and reports only persisted imports',
      () async {
        final bookmarks = container.read(bookmarksProvider.notifier);
        expect(
          await bookmarks.importBookmarks([
            for (var i = 0; i < 150; i++) entry('https://medium.com/story-$i'),
          ]),
          Bookmarks.maxBookmarks,
        );
        final before = container.read(bookmarksProvider).requireValue;
        expect(before, hasLength(Bookmarks.maxBookmarks));
        expect(
          await bookmarks.addBookmark(TestFixtures.storyUrl, 'New'),
          isFalse,
        );
        expect(
          await bookmarks.importBookmarks([entry(TestFixtures.storyUrl)]),
          0,
        );
        expect(container.read(bookmarksProvider).requireValue, before);
        expect(await bookmarks.removeBookmark(before.first), isTrue);
        expect(
          await bookmarks.importBookmarks([
            entry(TestFixtures.storyUrl),
            entry('https://medium.com/another-new'),
          ]),
          1,
        );
        final current = container.read(bookmarksProvider).requireValue;
        expect(current, hasLength(Bookmarks.maxBookmarks));
        expect(current, containsAll(before.skip(1)));
        final prefs = await SharedPreferences.getInstance();
        expect(
          BookmarksService(prefs).getBookmarks(),
          hasLength(Bookmarks.maxBookmarks),
        );
      },
    );

    test('merges entries preserving existing bookmarks', () async {
      final bookmarks = container.read(bookmarksProvider.notifier);
      await bookmarks.addBookmark(TestFixtures.storyUrl, 'Original');
      await container.read(bookmarksProvider.future);

      final added = await bookmarks.importBookmarks([
        entry(TestFixtures.storyUrl, folder: 'Tech'),
        entry('https://medium.com/imported', folder: 'Tech'),
      ]);

      expect(added, 1);
      final current = container.read(bookmarksProvider).requireValue;
      expect(current, hasLength(2));
      expect(
        current.firstWhere((b) => b.url == TestFixtures.storyUrl).title,
        'Original',
      );
      expect(
        current
            .firstWhere((b) => b.url == 'https://medium.com/imported')
            .folder,
        'Tech',
      );
      expect(container.read(allBookmarkFoldersProvider), ['Tech']);
    });

    test('reports zero when everything is already saved', () async {
      final bookmarks = container.read(bookmarksProvider.notifier);
      await bookmarks.addBookmark(TestFixtures.storyUrl, 'Story');
      await container.read(bookmarksProvider.future);

      final added = await bookmarks.importBookmarks([
        entry(TestFixtures.storyUrl),
      ]);

      expect(added, 0);
    });
  });
}
