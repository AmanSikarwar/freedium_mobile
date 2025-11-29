import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeInjectorService {
  Future<String> getThemeInjectionScript(
    BuildContext context, {
    double fontSize = 18.0,
  }) async {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == .dark;

    String colorToHex(Color color) {
      return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    }

    final cssVars =
        '''
      :root {
        --app-primary: ${colorToHex(colorScheme.primary)};
        --app-on-primary: ${colorToHex(colorScheme.onPrimary)};
        --app-primary-container: ${colorToHex(colorScheme.primaryContainer)};
        --app-on-primary-container: ${colorToHex(colorScheme.onPrimaryContainer)};
        --app-secondary: ${colorToHex(colorScheme.secondary)};
        --app-on-secondary: ${colorToHex(colorScheme.onSecondary)};
        --app-secondary-container: ${colorToHex(colorScheme.secondaryContainer)};
        --app-on-secondary-container: ${colorToHex(colorScheme.onSecondaryContainer)};
        --app-tertiary: ${colorToHex(colorScheme.tertiary)};
        --app-on-tertiary: ${colorToHex(colorScheme.onTertiary)};
        --app-tertiary-container: ${colorToHex(colorScheme.tertiaryContainer)};
        --app-on-tertiary-container: ${colorToHex(colorScheme.onTertiaryContainer)};
        --app-error: ${colorToHex(colorScheme.error)};
        --app-on-error: ${colorToHex(colorScheme.onError)};
        --app-error-container: ${colorToHex(colorScheme.errorContainer)};
        --app-on-error-container: ${colorToHex(colorScheme.onErrorContainer)};
        --app-surface: ${colorToHex(colorScheme.surface)};
        --app-on-surface: ${colorToHex(colorScheme.onSurface)};
        --app-surface-variant: ${colorToHex(colorScheme.surfaceContainerHighest)};
        --app-on-surface-variant: ${colorToHex(colorScheme.onSurfaceVariant)};
        --app-surface-dim: ${colorToHex(colorScheme.surfaceDim)};
        --app-surface-bright: ${colorToHex(colorScheme.surfaceBright)};
        --app-surface-container-lowest: ${colorToHex(colorScheme.surfaceContainerLowest)};
        --app-surface-container-low: ${colorToHex(colorScheme.surfaceContainerLow)};
        --app-surface-container: ${colorToHex(colorScheme.surfaceContainer)};
        --app-surface-container-high: ${colorToHex(colorScheme.surfaceContainerHigh)};
        --app-surface-container-highest: ${colorToHex(colorScheme.surfaceContainerHighest)};
        --app-outline: ${colorToHex(colorScheme.outline)};
        --app-outline-variant: ${colorToHex(colorScheme.outlineVariant)};
        --app-shadow: ${colorToHex(colorScheme.shadow)};
        --app-scrim: ${colorToHex(colorScheme.scrim)};
        --app-inverse-surface: ${colorToHex(colorScheme.inverseSurface)};
        --app-on-inverse-surface: ${colorToHex(colorScheme.onInverseSurface)};
        --app-inverse-primary: ${colorToHex(colorScheme.inversePrimary)};
        --app-surface-tint: ${colorToHex(colorScheme.surfaceTint)};
        --app-font-size: ${fontSize}px;
      }
    ''';

    final customCSSContent = await rootBundle.loadString(
      'assets/css/webview_styles.css',
    );
    final scriptTemplate = await rootBundle.loadString('assets/js/theme.js');

    return scriptTemplate
        .replaceFirst('%IS_DARK_MODE%', isDark.toString())
        .replaceFirst(
          '%CSS_VARS%',
          cssVars.replaceAll("'", r"\'").replaceAll("\n", r'\n'),
        )
        .replaceFirst(
          '%CUSTOM_CSS_CONTENT%',
          customCSSContent.replaceAll("'", r"\'").replaceAll("\n", r'\n'),
        );
  }

  String getFontSizeUpdateScript(double fontSize) {
    return '''
      (function() {
        const root = document.documentElement;
        root.style.setProperty('--app-font-size', '${fontSize}px');
        console.log('Font size updated to ${fontSize}px');
      })();
    ''';
  }
}
