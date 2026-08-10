import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:freedium_mobile/features/history/presentation/history_screen.dart';
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
  group('HistoryScreen', () {
    testWidgets('shows in-progress and finished reading states', (
      tester,
    ) async {
      final timestamp = DateTime.utc(2026, 8, 10);
      final history = [
        ReadingHistory(
          url: 'https://medium.com/in-progress',
          title: 'In progress',
          timestamp: timestamp,
          progress: 0.42,
        ),
        ReadingHistory(
          url: 'https://medium.com/finished',
          title: 'Finished story',
          timestamp: timestamp.subtract(const Duration(minutes: 1)),
          progress: 1,
        ),
      ];
      SharedPreferences.setMockInitialValues({
        'reading_history': [
          for (final item in history) jsonEncode(item.toJson()),
        ],
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

      expect(find.textContaining('42% read'), findsOneWidget);
      expect(find.textContaining('Finished •'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('keeps history entry visible when swipe removal fails', (
      tester,
    ) async {
      final history = ReadingHistory(
        url: 'https://medium.com/example/story',
        title: 'Example story',
        timestamp: DateTime.utc(2026, 2, 3),
      );
      SharedPreferencesStorePlatform.instance = _FailingSharedPreferencesStore({
        'flutter.reading_history': [jsonEncode(history.toJson())],
      });
      SharedPreferences.resetStatic();
      addTearDown(() => SharedPreferences.setMockInitialValues({}));
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

      expect(find.text('Example story'), findsOneWidget);

      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Example story'), findsOneWidget);
      expect(find.text('Failed to remove history entry'), findsOneWidget);
      expect(find.text('No reading history yet.'), findsNothing);
      expect(tester.takeException(), isNull);
    });

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

    testWidgets('keeps clear dialog open when clearing history fails', (
      tester,
    ) async {
      final history = ReadingHistory(
        url: 'https://medium.com/example/story',
        title: 'Example story',
        timestamp: DateTime.utc(2026, 2, 3),
      );
      SharedPreferencesStorePlatform.instance = _FailingSharedPreferencesStore({
        'flutter.reading_history': [jsonEncode(history.toJson())],
      });
      SharedPreferences.resetStatic();
      addTearDown(() => SharedPreferences.setMockInitialValues({}));
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
        'Missing',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Clear History'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AlertDialog, 'Clear History'), findsOneWidget);
      expect(find.text('Failed to clear history'), findsOneWidget);
      expect(find.text('No results for "Missing"'), findsOneWidget);
      expect(find.text('No reading history yet.'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
