import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/features/settings/presentation/settings_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _FailingSharedPreferencesStore extends SharedPreferencesStorePlatform {
  @override
  Future<bool> clear() async => false;

  @override
  Future<Map<String, Object>> getAll() async => {};

  @override
  Future<bool> remove(String key) async => false;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async =>
      false;
}

void main() {
  group('SettingsScreen', () {
    testWidgets('closes the update dialog before opening changelog', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final updateService = UpdateService(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'tag_name': 'v0.11.0',
              'html_url':
                  'https://github.com/AmanSikarwar/freedium_mobile/releases/tag/v0.11.0',
              'body': 'Release notes',
            }),
            200,
          ),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async => prefs),
            updateServiceProvider.overrideWith((ref) => updateService),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Check for Updates'), 300);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check for Updates'));
      await tester.pumpAndSettle();
      expect(find.text('Update Available'), findsOneWidget);

      await tester.tap(find.text('Changelog'));
      await tester.pumpAndSettle();

      expect(find.text('What\'s New'), findsOneWidget);
      expect(find.text('Update Available'), findsNothing);
    });

    testWidgets('shows reset failure when defaults cannot be saved', (
      tester,
    ) async {
      SharedPreferencesStorePlatform.instance =
          _FailingSharedPreferencesStore();
      SharedPreferences.resetStatic();
      addTearDown(() => SharedPreferences.setMockInitialValues({}));
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async => prefs),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Reset to Defaults'), 300);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset to Defaults'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to reset settings'), findsOneWidget);
      expect(find.text('Settings reset to defaults'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
