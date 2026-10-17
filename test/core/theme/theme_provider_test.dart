import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freedium_mobile/core/theme/theme_provider.dart';

void main() {
  group('dynamicThemeProvider', () {
    // Match dynamic_color's platform result, including independently toned neutrals.
    // ignore: deprecated_member_use
    final palette = CorePalette.fromList([
      for (final tones in [
        TonalPalette.of(275, 64),
        TonalPalette.of(300, 24),
        TonalPalette.of(90, 40),
        TonalPalette.of(180, 4),
        TonalPalette.of(180, 8),
      ])
        for (final tone in TonalPalette.commonTones) tones.get(tone),
    ]);

    for (final brightness in Brightness.values) {
      test(
        'preserves platform palettes for ${brightness.name} roles',
        () async {
          final container = ProviderContainer(
            overrides: [
              androidColorSchemeLoaderProvider.overrideWith(
                (ref) =>
                    () async => null,
              ),
              dynamicCorePaletteLoaderProvider.overrideWith(
                (ref) =>
                    () async => palette,
              ),
            ],
          );
          addTearDown(container.dispose);

          final themes = await container.read(dynamicThemeProvider.future);
          final isDark = brightness == Brightness.dark;
          final scheme =
              (isDark ? themes.darkTheme : themes.lightTheme).colorScheme;

          expect(scheme.surface, Color(palette.neutral.get(isDark ? 6 : 98)));
          expect(
            scheme.surfaceContainerLow,
            Color(palette.neutral.get(isDark ? 10 : 96)),
          );
          expect(
            scheme.surfaceContainerHigh,
            Color(palette.neutral.get(isDark ? 17 : 92)),
          );
          expect(
            scheme.surfaceContainerHighest,
            Color(palette.neutral.get(isDark ? 22 : 90)),
          );
          expect(scheme.primary, Color(palette.primary.get(isDark ? 80 : 40)));
          expect(
            scheme.primaryContainer,
            Color(palette.primary.get(isDark ? 30 : 90)),
          );
          expect(
            scheme.onPrimaryContainer,
            Color(palette.primary.get(isDark ? 90 : 30)),
          );
          expect(scheme.primaryFixed, Color(palette.primary.get(90)));
          expect(scheme.secondaryFixed, Color(palette.secondary.get(90)));
          expect(scheme.tertiaryFixed, Color(palette.tertiary.get(90)));
          expect(scheme.error, Color(palette.error.get(isDark ? 80 : 40)));
        },
      );
    }

    test('falls back to static theme when dynamic colors fail', () async {
      final container = ProviderContainer(
        overrides: [
          androidColorSchemeLoaderProvider.overrideWith(
            (ref) =>
                () async => null,
          ),
          dynamicCorePaletteLoaderProvider.overrideWith(
            (ref) => () async {
              throw Exception('dynamic colors unavailable');
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      final dynamicTheme = await container.read(dynamicThemeProvider.future);
      final staticTheme = container.read(themeProvider);

      expect(
        dynamicTheme.lightTheme.colorScheme.primary,
        staticTheme.lightTheme.colorScheme.primary,
      );
      expect(
        dynamicTheme.darkTheme.colorScheme.primary,
        staticTheme.darkTheme.colorScheme.primary,
      );
    });

    test(
      'uses resolved Android roles before generating a palette scheme',
      () async {
        final light = ColorScheme.fromSeed(seedColor: const Color(0xff006c4c));
        final dark = light.copyWith(
          brightness: .dark,
          surface: const Color(0xff0f072e),
          primaryContainer: const Color(0xff9496ff),
        );
        var requestedPalette = false;
        final container = ProviderContainer(
          overrides: [
            androidColorSchemeLoaderProvider.overrideWith(
              (ref) =>
                  () async => (light: light, dark: dark),
            ),
            dynamicCorePaletteLoaderProvider.overrideWith(
              (ref) => () async {
                requestedPalette = true;
                return palette;
              },
            ),
          ],
        );
        addTearDown(container.dispose);

        final themes = await container.read(dynamicThemeProvider.future);
        expect(themes.lightTheme.colorScheme, light);
        expect(themes.darkTheme.colorScheme, dark);
        expect(requestedPalette, isFalse);
      },
    );
  });
}
