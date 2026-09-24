import 'package:dynamic_color/dynamic_color.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/core/theme/app_theme.dart';
import 'package:freedium_mobile/core/theme/util.dart';

part 'theme_provider.g.dart';

class AppThemeProvider({required this.lightTheme, required this.darkTheme}) {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
}

@Riverpod(keepAlive: true)
ThemeMode themeMode(Ref ref) {
  final settings = ref.watch(settingsProvider).value;
  return settings?.themeMode ?? ThemeMode.system;
}

@Riverpod(keepAlive: true)
AppThemeProvider theme(Ref ref) {
  final textTheme = createTextTheme("Roboto", "Roboto");

  final appTheme = AppTheme(textTheme);

  return AppThemeProvider(
    lightTheme: appTheme.light(),
    darkTheme: appTheme.dark(),
  );
}

/// Test seam for [DynamicColorPlugin.getCorePalette].
/// Kept as a manual provider: function-typed providers are not supported
/// by `riverpod_generator`.
final dynamicCorePaletteLoaderProvider = Provider(
  (ref) => DynamicColorPlugin.getCorePalette,
);

@Riverpod(keepAlive: true)
Future<AppThemeProvider> dynamicTheme(Ref ref) async {
  final textTheme = createTextTheme("Roboto", "Roboto");
  final appTheme = AppTheme(textTheme);

  ColorScheme? lightColorScheme;
  ColorScheme? darkColorScheme;

  final loadDynamicCorePalette = ref.watch(dynamicCorePaletteLoaderProvider);
  final lightDynamic = await () async {
    try {
      return await loadDynamicCorePalette();
    } catch (e) {
      debugPrint('Failed to load dynamic colors: $e');
      return null;
    }
  }();
  if (lightDynamic != null) {
    lightColorScheme = lightDynamic.toColorScheme().harmonized();
    darkColorScheme = lightDynamic
        .toColorScheme(brightness: .dark)
        .harmonized();
  } else {
    lightColorScheme = appTheme.light().colorScheme;
    darkColorScheme = appTheme.dark().colorScheme;
  }

  return AppThemeProvider(
    lightTheme: appTheme.theme(lightColorScheme),
    darkTheme: appTheme.theme(darkColorScheme),
  );
}
