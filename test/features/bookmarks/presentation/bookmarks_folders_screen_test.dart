import 'package:material_3_expressive/material_3_expressive.dart';

import 'dart:convert';

import 'package:freedium_mobile/features/bookmarks/application/bookmarks_service.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmark_io.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmark_file_picker.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmark_folder.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';
import 'package:freedium_mobile/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:freedium_mobile/features/bookmarks/presentation/widgets/manage_folders_sheet.dart';
import 'package:freedium_mobile/features/webview/application/webview_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../test_helpers.dart';

Map<String, Object> _seed(List<BookmarkedArticle> bookmarks) => {
  'bookmarked_articles': [
    for (final item in bookmarks) jsonEncode(item.toJson()),
  ],
};

void main() {
  group('BookmarksScreen folders', () {
    testWidgets(
      'restores a backup when the saved library snapshot is unreadable',
      (tester) async {
        const rawSnapshot = '{"version":999}';
        final prefs = await mockPrefs({'bookmark_library': rawSnapshot});
        final backup = exportBookmarksJson(
          [
            BookmarkedArticle(
              url: TestFixtures.storyUrl,
              title: 'Recovered story',
              savedAt: TestFixtures.seedDate,
            ),
          ],
          const ['Empty folder'],
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWith((ref) async => prefs),
              bookmarkFilePickerProvider.overrideWithValue(() async => backup),
            ],
            child: const MaterialApp(home: BookmarksScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(findTooltip('More actions'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Import bookmarks'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Choose backup file'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(M3EButton, 'Import'));
        await tester.pumpAndSettle();

        expect(find.text('Restore unreadable bookmarks?'), findsOneWidget);
        await tester.tap(find.widgetWithText(M3EButton, 'Restore backup'));
        await tester.pumpAndSettle();

        expect(find.text('Recovered story'), findsOneWidget);
        expect(
          prefs.getString(BookmarksService.recoverySnapshotKey),
          rawSnapshot,
        );
        expect(BookmarksService(prefs).getFolders(), ['Empty folder']);
      },
    );

    testWidgets(
      'file restore previews duplicates before changing the library',
      (tester) async {
        final existing = BookmarkedArticle(
          url: TestFixtures.storyUrl,
          title: 'Existing',
          savedAt: TestFixtures.seedDate,
        );
        final prefs = await mockPrefs(_seed([existing]));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWith((ref) async => prefs),
              bookmarkFilePickerProvider.overrideWithValue(
                () async => exportBookmarksJson([
                  existing,
                  existing.copyWith(
                    url: 'https://medium.com/new',
                    title: 'New',
                  ),
                ], const []),
              ),
            ],
            child: const MaterialApp(home: BookmarksScreen()),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(findTooltip('More actions'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Import bookmarks'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Choose backup file'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(M3EButton, 'Import'));
        await tester.pumpAndSettle();
        expect(find.text('1 new articles'), findsOneWidget);
        expect(find.text('1 duplicates'), findsOneWidget);
        expect(BookmarksService(prefs).getBookmarks(), hasLength(1));
        await tester.tap(find.widgetWithText(M3EButton, 'Restore'));
        await tester.pumpAndSettle();
        expect(BookmarksService(prefs).getBookmarks(), hasLength(2));
      },
    );

    testWidgets('folder counts and filters ignore label casing', (
      tester,
    ) async {
      final seed = _seed([
        BookmarkedArticle(
          url: TestFixtures.storyUrl,
          title: 'Tech story',
          savedAt: TestFixtures.seedDate,
          folder: 'tech',
        ),
      ]);
      seed['bookmark_folders'] = ['Tech'];
      await pumpApp(tester, child: const BookmarksScreen(), initialPrefs: seed);
      expect(find.widgetWithText(M3EChip, 'Tech · 1'), findsOneWidget);
      await tester.tap(find.widgetWithText(M3EChip, 'Tech · 1'));
      await tester.pumpAndSettle();
      expect(find.text('Tech story'), findsOneWidget);
    });

    testWidgets('reports the retained import count when the library fills', (
      tester,
    ) async {
      final existing = [
        for (var i = 0; i < 99; i++)
          BookmarkedArticle(
            url: 'https://medium.com/saved-$i',
            title: 'Saved $i',
            savedAt: TestFixtures.seedDate,
          ),
      ];
      final prefs = await pumpApp(
        tester,
        child: const BookmarksScreen(),
        initialPrefs: _seed(existing),
      );
      await tester.tap(findTooltip('More actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import bookmarks'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        exportBookmarksJson([
          for (var i = 0; i < 2; i++)
            BookmarkedArticle(
              url: 'https://medium.com/import-$i',
              title: 'Imported $i',
              savedAt: TestFixtures.seedDate,
            ),
        ], const []),
      );
      await tester.tap(find.widgetWithText(M3EButton, 'Import'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(M3EButton, 'Restore'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Imported 1 bookmark'), findsOneWidget);
      expect(find.textContaining('existing bookmarks kept'), findsOneWidget);
      final saved = BookmarksService(prefs)
          .getBookmarks()
          .map((b) => jsonEncode(b.toJson()))
          .toList();
      expect(saved, hasLength(100));
      expect(saved.join(), contains('saved-0'));
      expect(saved.join(), contains('saved-98'));
    });

    testWidgets('restores folders from backups with no articles', (
      tester,
    ) async {
      final prefs = await pumpApp(
        tester,
        child: const BookmarksScreen(),
        initialPrefs: {
          'bookmark_folders': ['Existing'],
        },
      );
      await tester.tap(findTooltip('More actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import bookmarks'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        exportBookmarksJson([], ['Empty']),
      );
      await tester.tap(find.widgetWithText(M3EButton, 'Import'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(M3EButton, 'Restore'));
      await tester.pumpAndSettle();
      expect(BookmarksService(prefs).getFolders(), ['Empty', 'Existing']);
      expect(find.textContaining('folders restored'), findsOneWidget);
    });

    testWidgets('empty libraries can manage folders and restore a backup', (
      tester,
    ) async {
      final prefs = await pumpApp(tester, child: const BookmarksScreen());
      await tester.tap(findTooltip('Manage folders'));
      await tester.pumpAndSettle();
      expect(find.text('Manage folders'), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await tester.tap(findTooltip('More actions'));
      await tester.pumpAndSettle();
      expect(find.text('Clear bookmarks'), findsNothing);
      await tester.tap(find.text('Import bookmarks'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        exportBookmarksJson([
          BookmarkedArticle(
            url: TestFixtures.storyUrl,
            title: 'Restored',
            savedAt: TestFixtures.seedDate,
          ),
        ], const []),
      );
      await tester.tap(find.widgetWithText(M3EButton, 'Import'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(M3EButton, 'Restore'));
      await tester.pumpAndSettle();
      expect(find.text('Restored'), findsOneWidget);
      expect(BookmarksService(prefs).getBookmarks(), hasLength(1));
    });

    testWidgets('manages article-only folders past the saved-folder limit', (
      tester,
    ) async {
      final article = BookmarkedArticle(
        url: TestFixtures.storyUrl,
        title: 'Imported story',
        savedAt: TestFixtures.seedDate,
        folder: 'Alpha imported',
      );
      final initialPrefs = _seed([article]);
      initialPrefs['bookmark_folders'] = [
        for (var i = 0; i < maxBookmarkFolders; i++) 'Saved $i',
      ];
      final prefs = await pumpApp(
        tester,
        child: const BookmarksScreen(),
        initialPrefs: initialPrefs,
      );

      await tester.tap(findTooltip('Manage folders'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          '$maxBookmarkFolders/$maxBookmarkFolders saved · '
          '${maxBookmarkFolders + 1} total',
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ManageFoldersSheet),
          matching: find.text('Alpha imported'),
        ),
        findsOneWidget,
      );

      await tester.tap(findTooltip('Rename').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Renamed imported',
      );
      await tester.tap(find.widgetWithText(M3EButton, 'Rename'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(ManageFoldersSheet),
          matching: find.text('Renamed imported'),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          '$maxBookmarkFolders/$maxBookmarkFolders saved · '
          '${maxBookmarkFolders + 1} total',
        ),
        findsOneWidget,
      );

      await tester.tap(findTooltip('Delete').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(M3EButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(ManageFoldersSheet),
          matching: find.text('Renamed imported'),
        ),
        findsNothing,
      );
      expect(
        BookmarksService(prefs).getFolders(),
        hasLength(maxBookmarkFolders),
      );
      expect(BookmarksService(prefs).getBookmarks().single.folder, isNull);
    });

    testWidgets('filters bookmarks by folder chips', (tester) async {
      await pumpApp(
        tester,
        child: const BookmarksScreen(),
        initialPrefs: _seed([
          BookmarkedArticle(
            url: 'https://medium.com/tech-story',
            title: 'Tech story',
            savedAt: TestFixtures.seedDate,
            folder: 'Tech',
          ),
          BookmarkedArticle(
            url: TestFixtures.storyUrl,
            title: 'Example story',
            savedAt: TestFixtures.seedDate,
          ),
        ]),
      );

      expect(find.text('Tech story'), findsOneWidget);
      expect(find.text('Example story'), findsOneWidget);
      expect(find.widgetWithText(M3EChip, 'All · 2'), findsOneWidget);
      expect(find.widgetWithText(M3EChip, 'Unsorted · 1'), findsOneWidget);

      await tester.tap(find.widgetWithText(M3EChip, 'Tech · 1'));
      await tester.pumpAndSettle();

      expect(find.text('Tech story'), findsOneWidget);
      expect(find.text('Example story'), findsNothing);

      await tester.tap(find.widgetWithText(M3EChip, 'Unsorted · 1'));
      await tester.pumpAndSettle();

      expect(find.text('Tech story'), findsNothing);
      expect(find.text('Example story'), findsOneWidget);
    });

    testWidgets('moves a bookmark to a folder from the row action', (
      tester,
    ) async {
      final prefs = await pumpApp(
        tester,
        child: const BookmarksScreen(),
        initialPrefs: _seed([
          BookmarkedArticle(
            url: TestFixtures.storyUrl,
            title: 'Example story',
            savedAt: TestFixtures.seedDate,
          ),
        ]),
      );

      await tester.tap(findTooltip('Move to folder'));
      await tester.pumpAndSettle();
      expect(find.text('Move to folder'), findsWidgets);

      await tester.enterText(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(TextField),
        ),
        'Tech',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Tech'), findsOneWidget);
      final stored = BookmarksService(prefs).getFolders();
      expect(stored, ['Tech']);
    });

    testWidgets('creates folders from the manage sheet', (tester) async {
      await pumpApp(
        tester,
        child: const BookmarksScreen(),
        initialPrefs: _seed([
          BookmarkedArticle(
            url: TestFixtures.storyUrl,
            title: 'Example story',
            savedAt: TestFixtures.seedDate,
          ),
        ]),
      );

      await tester.tap(findTooltip('Manage folders'));
      await tester.pumpAndSettle();
      expect(find.text('Manage folders'), findsOneWidget);

      await tester.enterText(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(TextField),
        ),
        'Reading',
      );
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Reading'), findsOneWidget);
    });

    testWidgets('exports bookmarks as shareable JSON', (tester) async {
      String? shared;
      final prefs = await mockPrefs(
        _seed([
          BookmarkedArticle(
            url: TestFixtures.storyUrl,
            title: 'Example story',
            savedAt: TestFixtures.seedDate,
            folder: 'Tech',
          ),
        ]),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async => prefs),
            shareLauncherProvider.overrideWith(
              (ref) => (ShareParams params) async {
                expect(params.fileNameOverrides, ['freedium-bookmarks.json']);
                expect(params.files!.single.mimeType, 'application/json');
                shared = await params.files!.single.readAsString();
                return const ShareResult('', ShareResultStatus.success);
              },
            ),
          ],
          child: const MaterialApp(home: BookmarksScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(findTooltip('More actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export bookmarks').last);
      await tester.pumpAndSettle();

      expect(shared, contains('"version": 1'));
      expect(shared, contains(TestFixtures.storyUrl));
      expect(shared, contains('Tech'));
    });

    testWidgets('imports bookmarks from pasted JSON', (tester) async {
      final prefs = await pumpApp(
        tester,
        child: const BookmarksScreen(),
        initialPrefs: _seed([
          BookmarkedArticle(
            url: 'https://medium.com/existing',
            title: 'Existing',
            savedAt: TestFixtures.seedDate,
          ),
        ]),
      );

      await tester.tap(findTooltip('More actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import bookmarks').last);
      await tester.pumpAndSettle();

      final backup = exportBookmarksJson(
        [
          BookmarkedArticle(
            url: TestFixtures.storyUrl,
            title: 'Imported story',
            savedAt: TestFixtures.seedDate,
            folder: 'Tech',
          ),
        ],
        const ['Tech'],
      );
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        backup,
      );
      await tester.tap(find.widgetWithText(M3EButton, 'Import'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(M3EButton, 'Restore'));
      await tester.pumpAndSettle();

      expect(find.text('Imported story'), findsOneWidget);
      expect(find.widgetWithText(M3EChip, 'All · 2'), findsOneWidget);
      expect(BookmarksService(prefs).getBookmarks(), hasLength(2));
    });

    testWidgets('rejects invalid import payloads', (tester) async {
      await pumpApp(
        tester,
        child: const BookmarksScreen(),
        initialPrefs: _seed([
          BookmarkedArticle(
            url: 'https://medium.com/existing',
            title: 'Existing',
            savedAt: TestFixtures.seedDate,
          ),
        ]),
      );

      await tester.tap(findTooltip('More actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import bookmarks').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'not json',
      );
      await tester.tap(find.widgetWithText(M3EButton, 'Import'));
      await tester.pumpAndSettle();

      expect(find.text('Not a valid bookmarks backup'), findsOneWidget);
      expect(find.text('Existing'), findsOneWidget);
    });
  });
}
