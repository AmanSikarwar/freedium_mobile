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

    test('targets updated Freedium theme and interaction selectors', () async {
      final service = ThemeInjectorService();
      final script = await service.getThemeInjectionScript(
        ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      );

      expect(script, contains('mode-watcher-mode'));
      expect(script, contains('.theme-toggle'));
      expect(script, contains('button.code-copy-btn[data-code]'));
      expect(script, contains('article header'));
      expect(script, contains('article .prose h3'));
      expect(script, contains('article h1'));
      expect(script, contains("img[alt='Post cover image']"));
      expect(script, contains('ReadingProgress.postMessage'));
    });

    test('pre-theme script primes mode-watcher and Freedium tokens', () {
      final service = ThemeInjectorService();
      final script = service.getPreThemeScript(
        ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      );

      expect(script, contains('localStorage.setItem("theme", "dark")'));
      expect(
        script,
        contains('localStorage.setItem("mode-watcher-mode", "dark")'),
      );
      expect(script, contains('root.classList.add("dark")'));
      expect(script, contains('root.style.colorScheme = "dark"'));
      expect(script, contains("root.style.setProperty('--bg'"));
      expect(script, contains("root.style.setProperty('--accent'"));
      expect(
        script,
        contains(
          'console.warn(\'Failed to persist pre-theme mode "dark" to localStorage:\', e)',
        ),
      );
      expect(script, contains('console.error("Pre-theme script error:", e)'));
    });
  });
}
