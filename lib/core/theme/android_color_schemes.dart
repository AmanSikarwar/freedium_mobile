import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freedium_mobile/core/theme/dynamic_color_scheme.dart';

Future<({ColorScheme light, ColorScheme dark})?>
loadAndroidColorSchemes() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;

  try {
    final palettes = await const MethodChannel('freedium/theme')
        .invokeMapMethod<String, dynamic>('getColorSchemes');
    if (palettes == null) return null;

    ColorScheme read(String mode, Brightness brightness) {
      final raw = palettes[mode];
      if (raw is! Map<Object?, Object?>) {
        throw FormatException('Missing Android $mode color scheme');
      }
      return colorSchemeFromAndroidRoles(
        Map<String, int>.from(raw),
        brightness: brightness,
      );
    }

    return (light: read('light', .light), dark: read('dark', .dark));
  } catch (error) {
    debugPrint('Could not load Android color roles: $error');
    return null;
  }
}
