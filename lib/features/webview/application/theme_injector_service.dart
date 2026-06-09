import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String _colorToHex(Color color) {
  return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

Map<String, String> _freediumThemeTokenValues(ColorScheme colorScheme) {
  return {
    '--bg': _colorToHex(colorScheme.surface),
    '--bg-2': _colorToHex(colorScheme.surfaceContainerLow),
    '--bg-3': _colorToHex(colorScheme.surfaceContainer),
    '--line': _colorToHex(colorScheme.outlineVariant),
    '--line-2': _colorToHex(colorScheme.outline),
    '--ink': _colorToHex(colorScheme.onSurface),
    '--ink-2': _colorToHex(colorScheme.onSurfaceVariant),
    '--ink-3': _colorToHex(colorScheme.onSurfaceVariant),
    '--ink-4': _colorToHex(colorScheme.outline),
    '--accent': _colorToHex(colorScheme.primary),
    '--accent-deep': _colorToHex(colorScheme.primaryContainer),
  };
}

String _freediumThemeTokenAssignments(ColorScheme colorScheme) {
  final buffer = StringBuffer();
  for (final entry in _freediumThemeTokenValues(colorScheme).entries) {
    buffer.writeln(
      "    root.style.setProperty('${entry.key}', '${entry.value}', 'important');",
    );
  }
  return buffer.toString();
}

class ThemeInjectorService {
  Future<String> getThemeInjectionScript(
    ColorScheme colorScheme, {
    double fontSize = 18.0,
  }) async {
    final isDark = colorScheme.brightness == .dark;

    final cssVars =
        '''
      :root {
        --app-primary: ${_colorToHex(colorScheme.primary)};
        --app-on-primary: ${_colorToHex(colorScheme.onPrimary)};
        --app-primary-container: ${_colorToHex(colorScheme.primaryContainer)};
        --app-on-primary-container: ${_colorToHex(colorScheme.onPrimaryContainer)};
        --app-secondary: ${_colorToHex(colorScheme.secondary)};
        --app-on-secondary: ${_colorToHex(colorScheme.onSecondary)};
        --app-secondary-container: ${_colorToHex(colorScheme.secondaryContainer)};
        --app-on-secondary-container: ${_colorToHex(colorScheme.onSecondaryContainer)};
        --app-tertiary: ${_colorToHex(colorScheme.tertiary)};
        --app-on-tertiary: ${_colorToHex(colorScheme.onTertiary)};
        --app-tertiary-container: ${_colorToHex(colorScheme.tertiaryContainer)};
        --app-on-tertiary-container: ${_colorToHex(colorScheme.onTertiaryContainer)};
        --app-error: ${_colorToHex(colorScheme.error)};
        --app-on-error: ${_colorToHex(colorScheme.onError)};
        --app-error-container: ${_colorToHex(colorScheme.errorContainer)};
        --app-on-error-container: ${_colorToHex(colorScheme.onErrorContainer)};
        --app-surface: ${_colorToHex(colorScheme.surface)};
        --app-on-surface: ${_colorToHex(colorScheme.onSurface)};
        --app-surface-variant: ${_colorToHex(colorScheme.surfaceContainerHighest)};
        --app-on-surface-variant: ${_colorToHex(colorScheme.onSurfaceVariant)};
        --app-surface-dim: ${_colorToHex(colorScheme.surfaceDim)};
        --app-surface-bright: ${_colorToHex(colorScheme.surfaceBright)};
        --app-surface-container-lowest: ${_colorToHex(colorScheme.surfaceContainerLowest)};
        --app-surface-container-low: ${_colorToHex(colorScheme.surfaceContainerLow)};
        --app-surface-container: ${_colorToHex(colorScheme.surfaceContainer)};
        --app-surface-container-high: ${_colorToHex(colorScheme.surfaceContainerHigh)};
        --app-surface-container-highest: ${_colorToHex(colorScheme.surfaceContainerHighest)};
        --app-outline: ${_colorToHex(colorScheme.outline)};
        --app-outline-variant: ${_colorToHex(colorScheme.outlineVariant)};
        --app-shadow: ${_colorToHex(colorScheme.shadow)};
        --app-scrim: ${_colorToHex(colorScheme.scrim)};
        --app-inverse-surface: ${_colorToHex(colorScheme.inverseSurface)};
        --app-on-inverse-surface: ${_colorToHex(colorScheme.onInverseSurface)};
        --app-inverse-primary: ${_colorToHex(colorScheme.inversePrimary)};
        --app-surface-tint: ${_colorToHex(colorScheme.surfaceTint)};
        --app-font-size: ${fontSize}px;
      }
    ''';

    String customCSSContent = '';
    String scriptTemplate = '';

    try {
      customCSSContent = await rootBundle.loadString(
        'assets/css/webview_styles.css',
      );
      scriptTemplate = await rootBundle.loadString('assets/js/theme.js');
    } catch (e) {
      debugPrint('Failed to load theme assets: $e');
      return '''(function() {
        console.error('Theme assets not found');
        try {
          if (window.themeApplied && window.themeApplied.postMessage) {
            window.themeApplied.postMessage('done');
          }
        } catch (e) {
          console.error('Failed to call Flutter handler after asset error:', e);
        }
      })();''';
    }

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

  /// Returns a minimal synchronous script to be injected on [onPageStarted].
  ///
  /// Sets [localStorage.theme] and applies/removes the Tailwind `dark` class
  /// on `<html>` immediately — before the page's own inline scripts run —
  /// so Freedium's class-based dark mode activates on the first render pass
  /// rather than after [onPageFinished].
  ///
  /// No asset loading needed; the script is fully self-contained.
  String getPreThemeScript(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final themeValue = isDark ? 'dark' : 'light';
    final freediumTokenAssignments = _freediumThemeTokenAssignments(
      colorScheme,
    );

    return '''
(function () {
  try {
    try {
      localStorage.setItem("theme", "$themeValue");
      localStorage.setItem("mode-watcher-mode", "$themeValue");
    } catch (e) {
      console.warn('Failed to persist pre-theme mode "$themeValue" to localStorage:', e);
    }
    var root = document.documentElement;
    if ($isDark) {
      root.classList.add("dark");
    } else {
      root.classList.remove("dark");
    }
    root.style.colorScheme = "$themeValue";
$freediumTokenAssignments
  } catch (e) {
    console.error("Pre-theme script error:", e);
    // The full theme script will retry after the page finishes loading.
  }
})();
''';
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
