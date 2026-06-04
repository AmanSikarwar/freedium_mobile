import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/theme/theme_provider.dart';

void main() {
  group('dynamicThemeProvider', () {
    test('falls back to static theme when dynamic colors fail', () async {
      final container = ProviderContainer(
        overrides: [
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
  });
}
