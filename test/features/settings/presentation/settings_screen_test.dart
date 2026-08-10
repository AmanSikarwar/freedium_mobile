import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';
import 'package:freedium_mobile/features/settings/presentation/settings_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
  group('SettingsScreen', () {
    testWidgets('toggles Freedium site popups', (tester) async {
      SharedPreferences.setMockInitialValues({});
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

      final tile = find.widgetWithText(SwitchListTile, 'Freedium Popups');
      expect(tester.widget<SwitchListTile>(tile).value, isTrue);

      await tester.tap(tile);
      await tester.pumpAndSettle();

      expect(prefs.getBool('show_site_popups'), isFalse);
      expect(tester.widget<SwitchListTile>(tile).value, isFalse);
    });

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

    testWidgets('shows link failure when update URL cannot be opened', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final launchedUrls = <String?>[];
      const releaseUrl =
          'https://github.com/AmanSikarwar/freedium_mobile/releases/tag/v0.11.0';
      final updateService = UpdateService(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'tag_name': 'v0.11.0',
              'html_url': releaseUrl,
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
            externalUrlLauncherProvider.overrideWith(
              (ref) => (url) async {
                launchedUrls.add(url);
                return false;
              },
            ),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Check for Updates'), 300);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check for Updates'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Update'));
      await tester.pumpAndSettle();

      expect(launchedUrls, [releaseUrl]);
      expect(find.text('Could not open link'), findsOneWidget);
      expect(find.text('Update Available'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows update check failure when the request fails', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final updateService = UpdateService(
        client: MockClient((_) async => http.Response('rate limited', 403)),
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

      expect(find.text('Failed to check for updates'), findsOneWidget);
      expect(find.text('You are using the latest version!'), findsNothing);
      expect(find.text('Update Available'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps timeout dialog open when saving fails', (tester) async {
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

      await tester.scrollUntilVisible(find.text('Mirror Timeout'), 300);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mirror Timeout'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(AlertDialog, 'Mirror Timeout'),
        findsOneWidget,
      );
      expect(find.text('Failed to save mirror timeout'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows default font size failure when saving fails', (
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

      await tester.tap(find.text('Default Font Size'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to save default font size'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows selected mirror failure when saving fails', (
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

      final mirrorRadio = find.byWidgetPredicate(
        (widget) =>
            widget is Radio<String> && widget.value == AppConstants.freediumUrl,
      );
      await tester.scrollUntilVisible(mirrorRadio, 300);
      await tester.pumpAndSettle();
      await tester.tap(mirrorRadio);
      await tester.pumpAndSettle();

      expect(find.text('Failed to save selected mirror'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows auto-switch failure when saving fails', (tester) async {
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

      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Auto-Switch Mirror'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to save auto-switch mirror'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps delete mirror dialog open when saving fails', (
      tester,
    ) async {
      const customMirror = {
        'name': 'Custom',
        'url': 'https://custom.example',
        'isDefault': false,
        'isCustom': true,
      };
      SharedPreferencesStorePlatform.instance = _FailingSharedPreferencesStore({
        'flutter.freedium_mirrors': [jsonEncode(customMirror)],
      });
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

      final customMirrorCard = find.ancestor(
        of: find.text('https://custom.example'),
        matching: find.byType(Card),
      );
      await tester.scrollUntilVisible(customMirrorCard, 300);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: customMirrorCard,
          matching: find.byType(PopupMenuButton<String>),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AlertDialog, 'Delete Mirror'), findsOneWidget);
      expect(find.text('Failed to remove mirror'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
