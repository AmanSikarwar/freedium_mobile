import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/webview/application/theme_injector_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeInjectorService', () {
    test('generates a script that can reapply theme updates', () async {
      final service = ThemeInjectorService();
      final script = await service.getThemeInjectionScript(
        ColorScheme.fromSeed(seedColor: Colors.teal),
      );

      expect(script, contains('data-freedium-theme-applied'));
      expect(script, contains('reapplying'));
      expect(script, isNot(contains('skipping duplicate injection')));
    });

    test(
      'emits inverse surface CSS variable names used by injected styles',
      () async {
        final service = ThemeInjectorService();
        final script = await service.getThemeInjectionScript(
          ColorScheme.fromSeed(seedColor: Colors.indigo),
        );

        expect(script, contains('--app-on-inverse-surface:'));
        expect(script, contains('var(--app-on-inverse-surface)'));
        expect(script, isNot(contains('var(--app-inverse-on-surface)')));
      },
    );
  });
}
