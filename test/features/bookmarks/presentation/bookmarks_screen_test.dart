import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/bookmarks/domain/bookmarked_article.dart';
import 'package:freedium_mobile/features/bookmarks/presentation/bookmarks_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  });
}
