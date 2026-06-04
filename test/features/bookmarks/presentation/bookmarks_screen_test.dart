import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';
import 'package:freedium_mobile/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _FailingSharedPreferencesStore extends SharedPreferencesStorePlatform {
  _FailingSharedPreferencesStore([Map<String, Object>? initialValues])
    : _values = Map.of(initialValues ?? {});

  final Map<String, Object> _values;

  @override
  Future<bool> clear() async => false;

  @override
  Future<Map<String, Object>> getAll() async => Map.of(_values);

  @override
  Future<bool> remove(String key) async => false;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

void main() {
  group('BookmarksScreen', () {
    testWidgets('reserves enough app bar height for padded search', (
      tester,
    ) async {
      final bookmark = BookmarkedArticle(
        url: 'https://medium.com/example/story',
        title: 'Example story',
        savedAt: DateTime.utc(2026, 2, 3),
      );
      SharedPreferences.setMockInitialValues({
        'bookmarked_articles': [jsonEncode(bookmark.toJson())],
      });
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

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.bottom?.preferredSize.height, 64);
    });

    testWidgets('removes a bookmark after swipe dismissal', (tester) async {
      final bookmark = BookmarkedArticle(
        url: 'https://medium.com/example/story',
        title: 'Example story',
        savedAt: DateTime.utc(2026, 2, 3),
      );
      SharedPreferences.setMockInitialValues({
        'bookmarked_articles': [jsonEncode(bookmark.toJson())],
      });
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

      expect(find.text('Example story'), findsNothing);
      expect(find.text('No saved articles yet.'), findsOneWidget);
      expect(prefs.getStringList('bookmarked_articles'), isEmpty);
    });

    testWidgets('keeps bookmark visible when swipe removal fails', (
      tester,
    ) async {
      final bookmark = BookmarkedArticle(
        url: 'https://medium.com/example/story',
        title: 'Example story',
        savedAt: DateTime.utc(2026, 2, 3),
      );
      SharedPreferencesStorePlatform.instance = _FailingSharedPreferencesStore({
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
        url: 'https://medium.com/example/story',
        title: 'Example story',
        savedAt: DateTime.utc(2026, 2, 3),
      );
      SharedPreferences.setMockInitialValues({
        'bookmarked_articles': [jsonEncode(bookmark.toJson())],
      });
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
        'Example',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Clear Bookmarks'));
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
        url: 'https://medium.com/example/story',
        title: 'Example story',
        savedAt: DateTime.utc(2026, 2, 3),
      );
      SharedPreferencesStorePlatform.instance = _FailingSharedPreferencesStore({
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

      await tester.tap(find.byTooltip('Clear Bookmarks'));
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
