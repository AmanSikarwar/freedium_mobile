import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/theme_chooser_bottom_sheet.dart';
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
  group('ThemeChooserBottomSheet', () {
    testWidgets('keeps the sheet open when saving fails', (tester) async {
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
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return FilledButton(
                    onPressed: () => showThemeChooserBottomSheet(context),
                    child: const Text('Theme'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(find.byType(ThemeChooserBottomSheet), findsOneWidget);
      expect(find.text('Failed to save theme'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
