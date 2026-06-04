import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:freedium_mobile/features/history/presentation/history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HistoryScreen', () {
    testWidgets('clears the active search when clearing all history', (
      tester,
    ) async {
      final history = ReadingHistory(
        url: 'https://medium.com/example/story',
        title: 'Example story',
        timestamp: DateTime.utc(2026, 2, 3),
      );
      SharedPreferences.setMockInitialValues({
        'reading_history': [jsonEncode(history.toJson())],
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async => prefs),
          ],
          child: const MaterialApp(home: HistoryScreen()),
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

      await tester.tap(find.byTooltip('Clear History'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
      await tester.pumpAndSettle();

      expect(find.text('No reading history yet.'), findsOneWidget);
      expect(find.textContaining('No results for'), findsNothing);
      expect(prefs.getStringList('reading_history'), isNull);
    });
  });
}
