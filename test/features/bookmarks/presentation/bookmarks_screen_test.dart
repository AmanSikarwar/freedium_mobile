import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';
import 'package:freedium_mobile/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../../../test_helpers.dart';

void main() {
  group('BookmarksScreen', () {
    testWidgets('shows progress from matching history entries', (tester) async {
      final timestamp = TestFixtures.groupDate;
      final bookmarks = [
        BookmarkedArticle(
          url: 'https://medium.com/in-progress',
          title: 'In progress',
          savedAt: timestamp,
        ),
        BookmarkedArticle(
          url: 'https://medium.com/finished',
          title: 'Finished story',
          savedAt: timestamp.subtract(const Duration(minutes: 1)),
        ),
      ];
      final history = [
        ReadingHistory(
          url: bookmarks.first.url,
          title: bookmarks.first.title,
          timestamp: timestamp,
          progress: 0.42,
        ),
        ReadingHistory(
          url: bookmarks.last.url,
          title: bookmarks.last.title,
          timestamp: timestamp,
          progress: 1,
        ),
      ];
      await pumpApp(
        tester,
        child: const BookmarksScreen(),
        initialPrefs: {
          'bookmarked_articles': [
            for (final item in bookmarks) jsonEncode(item.toJson()),
          ],
          'reading_history': [
            for (final item in history) jsonEncode(item.toJson()),
          ],
        },
      );

      expect(find.textContaining('42% read'), findsOneWidget);
      expect(find.textContaining('Finished •'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
      expect(find.text('2 articles'), findsOneWidget);
      expect(find.text('medium.com'), findsNWidgets(2));
    });

    testWidgets('reserves enough app bar height for padded search', (
      tester,
    ) async {
      final bookmark = BookmarkedArticle(
        url: TestFixtures.storyUrl,
        title: 'Example story',
        savedAt: TestFixtures.seedDate,
      );
      await pumpApp(
        tester,
        child: const BookmarksScreen(),
        initialPrefs: {
          'bookmarked_articles': [jsonEncode(bookmark.toJson())],
        },
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.bottom?.preferredSize.height, 64);
    });

    testWidgets('removes a bookmark after swipe dismissal', (tester) async {
      final bookmark = BookmarkedArticle(
        url: TestFixtures.storyUrl,
        title: 'Example story',
        savedAt: TestFixtures.seedDate,
      );
      final prefs = await pumpApp(
        tester,
        child: const BookmarksScreen(),
        initialPrefs: {
          'bookmarked_articles': [jsonEncode(bookmark.toJson())],
        },
      );

      expect(find.text('Example story'), findsOneWidget);

      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Example story'), findsNothing);
      expect(find.text('No saved articles yet.'), findsOneWidget);
      expect(prefs.getStringList('bookmarked_articles'), isEmpty);
    });

    testWidgets('keeps bookmark visible when swipe removal fails', (
      tester,
    ) async {
      final bookmark = BookmarkedArticle(
        url: TestFixtures.storyUrl,
        title: 'Example story',
        savedAt: TestFixtures.seedDate,
      );
      SharedPreferencesStorePlatform.instance = FailingPrefsStore({
        'flutter.bookmarked_articles': [jsonEncode(bookmark.toJson())],
      });
      SharedPreferences.resetStatic();
      addTearDown(() => SharedPreferences.setMockInitialValues({}));
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async => prefs),
          ],
          child: const MaterialApp(home: BookmarksScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Example story'), findsOneWidget);

      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Example story'), findsOneWidget);
      expect(find.text('Failed to remove bookmark'), findsOneWidget);
      expect(find.text('No saved articles yet.'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('clears the active search when clearing all bookmarks', (
      tester,
    ) async {
      final bookmark = BookmarkedArticle(
        url: TestFixtures.storyUrl,
        title: 'Example story',
        savedAt: TestFixtures.seedDate,
      );
      final prefs = await pumpApp(
        tester,
        child: const BookmarksScreen(),
        initialPrefs: {
          'bookmarked_articles': [jsonEncode(bookmark.toJson())],
        },
      );

      await tester.enterText(
        find.descendant(
          of: find.byType(SearchBar),
          matching: find.byType(EditableText),
        ),
        'Example',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('More actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear bookmarks').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
      await tester.pumpAndSettle();

      expect(find.text('No saved articles yet.'), findsOneWidget);
      expect(find.textContaining('No results for'), findsNothing);
      expect(prefs.getStringList('bookmarked_articles'), isNull);
    });

    testWidgets('keeps clear dialog open when clearing bookmarks fails', (
      tester,
    ) async {
      final bookmark = BookmarkedArticle(
        url: TestFixtures.storyUrl,
        title: 'Example story',
        savedAt: TestFixtures.seedDate,
      );
      SharedPreferencesStorePlatform.instance = FailingPrefsStore({
        'flutter.bookmarked_articles': [jsonEncode(bookmark.toJson())],
      });
      SharedPreferences.resetStatic();
      addTearDown(() => SharedPreferences.setMockInitialValues({}));
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async => prefs),
          ],
          child: const MaterialApp(home: BookmarksScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.descendant(
          of: find.byType(SearchBar),
          matching: find.byType(EditableText),
        ),
        'Missing',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('More actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear bookmarks').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(AlertDialog, 'Clear Bookmarks'),
        findsOneWidget,
      );
      expect(find.text('Failed to clear bookmarks'), findsOneWidget);
      expect(find.text('No results for "Missing"'), findsOneWidget);
      expect(find.text('No saved articles yet.'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
