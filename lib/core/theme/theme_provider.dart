import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/theme_mode_service.dart';
import 'package:freedium_mobile/core/theme/app_theme.dart';
import 'package:freedium_mobile/core/theme/util.dart';

class AppThemeProvider {
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  AppThemeProvider({required this.lightTheme, required this.darkTheme});
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  final ThemeModeService _themeModeService = ThemeModeService();

  @override
  ThemeMode build() {
    _loadThemeMode();
    return .system;
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await _themeModeService.loadThemeMode();
    state = themeMode;
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    await _themeModeService.saveThemeMode(themeMode);
  }
}

final themeProvider = Provider<AppThemeProvider>((ref) {
  final textTheme = createTextTheme("Roboto", "Roboto");

  final appTheme = AppTheme(textTheme);

  return AppThemeProvider(
    lightTheme: appTheme.light(),
    darkTheme: appTheme.dark(),
  );
});

final dynamicThemeProvider = FutureProvider<AppThemeProvider>((ref) async {
  final textTheme = createTextTheme("Roboto", "Roboto");
  final appTheme = AppTheme(textTheme);

  ColorScheme? lightColorScheme;
  ColorScheme? darkColorScheme;

  final lightDynamic = await DynamicColorPlugin.getCorePalette();
  if (lightDynamic != null) {
    lightColorScheme = lightDynamic.toColorScheme().harmonized();
    darkColorScheme = lightDynamic
        .toColorScheme(brightness: Brightness.dark)
        .harmonized();
  } else {
    lightColorScheme = appTheme.light().colorScheme;
    darkColorScheme = appTheme.dark().colorScheme;
  }

  return AppThemeProvider(
    lightTheme: appTheme.theme(lightColorScheme),
    darkTheme: appTheme.theme(darkColorScheme),
  );
});

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
