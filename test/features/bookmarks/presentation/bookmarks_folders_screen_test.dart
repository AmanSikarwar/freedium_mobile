import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/bookmarks/application/bookmark_io.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';
import 'package:freedium_mobile/features/bookmarks/presentation/bookmarks_screen.dart';
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
      expect(find.widgetWithText(FilterChip, 'All · 2'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Unsorted · 1'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'Tech · 1'));
      await tester.pumpAndSettle();

      expect(find.text('Tech story'), findsOneWidget);
      expect(find.text('Example story'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, 'Unsorted · 1'));
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

      await tester.tap(find.byTooltip('Move to folder'));
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
      final stored = prefs.getStringList('bookmark_folders');
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

      await tester.tap(find.byTooltip('Manage folders'));
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
                shared = params.text;
                return const ShareResult('', ShareResultStatus.success);
              },
            ),
          ],
          child: const MaterialApp(home: BookmarksScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('More actions'));
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

      await tester.tap(find.byTooltip('More actions'));
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
      await tester.tap(find.widgetWithText(FilledButton, 'Import'));
      await tester.pumpAndSettle();

      expect(find.text('Imported story'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'All · 2'), findsOneWidget);
      expect(prefs.getStringList('bookmarked_articles'), hasLength(2));
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

      await tester.tap(find.byTooltip('More actions'));
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
      await tester.tap(find.widgetWithText(FilledButton, 'Import'));
      await tester.pumpAndSettle();

      expect(find.text('Not a valid bookmarks backup'), findsOneWidget);
      expect(find.text('Existing'), findsOneWidget);
    });
  });
}
