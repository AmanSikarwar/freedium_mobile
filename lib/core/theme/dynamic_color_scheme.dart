import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_ui/material_ui.dart';

ColorScheme colorSchemeFromPlatformPalette(
  // dynamic_color still returns this deprecated palette container.
  // ignore: deprecated_member_use
  CorePalette palette, {
  required Brightness brightness,
}) {
  // Re-seeding would replace Android's neutral and accent palettes.
  final scheme = DynamicScheme(
    sourceColorHct: Hct.fromInt(palette.primary.get(40)),
    variant: Variant.tonalSpot,
    isDark: brightness == Brightness.dark,
    primaryPalette: palette.primary,
    secondaryPalette: palette.secondary,
    tertiaryPalette: palette.tertiary,
    neutralPalette: palette.neutral,
    neutralVariantPalette: palette.neutralVariant,
    errorPalette: palette.error,
  );

  return _colorSchemeFromRoles(brightness, scheme.getArgb);
}

ColorScheme colorSchemeFromAndroidRoles(
  Map<String, int> colors, {
  required Brightness brightness,
}) => _colorSchemeFromRoles(brightness, (role) {
  final value = colors[role.name];
  if (value == null) {
    throw FormatException('Missing Android color role: ${role.name}');
  }
  return value;
});

ColorScheme _colorSchemeFromRoles(
  Brightness brightness,
  int Function(DynamicColor) resolve,
) {
  Color color(DynamicColor role) => Color(resolve(role));
  return ColorScheme(
    brightness: brightness,
    primary: color(MaterialDynamicColors.primary),
    onPrimary: color(MaterialDynamicColors.onPrimary),
    primaryContainer: color(MaterialDynamicColors.primaryContainer),
    onPrimaryContainer: color(MaterialDynamicColors.onPrimaryContainer),
    primaryFixed: color(MaterialDynamicColors.primaryFixed),
    primaryFixedDim: color(MaterialDynamicColors.primaryFixedDim),
    onPrimaryFixed: color(MaterialDynamicColors.onPrimaryFixed),
    onPrimaryFixedVariant: color(MaterialDynamicColors.onPrimaryFixedVariant),
    secondary: color(MaterialDynamicColors.secondary),
    onSecondary: color(MaterialDynamicColors.onSecondary),
    secondaryContainer: color(MaterialDynamicColors.secondaryContainer),
    onSecondaryContainer: color(MaterialDynamicColors.onSecondaryContainer),
    secondaryFixed: color(MaterialDynamicColors.secondaryFixed),
    secondaryFixedDim: color(MaterialDynamicColors.secondaryFixedDim),
    onSecondaryFixed: color(MaterialDynamicColors.onSecondaryFixed),
    onSecondaryFixedVariant: color(
      MaterialDynamicColors.onSecondaryFixedVariant,
    ),
    tertiary: color(MaterialDynamicColors.tertiary),
    onTertiary: color(MaterialDynamicColors.onTertiary),
    tertiaryContainer: color(MaterialDynamicColors.tertiaryContainer),
    onTertiaryContainer: color(MaterialDynamicColors.onTertiaryContainer),
    tertiaryFixed: color(MaterialDynamicColors.tertiaryFixed),
    tertiaryFixedDim: color(MaterialDynamicColors.tertiaryFixedDim),
    onTertiaryFixed: color(MaterialDynamicColors.onTertiaryFixed),
    onTertiaryFixedVariant: color(MaterialDynamicColors.onTertiaryFixedVariant),
    error: color(MaterialDynamicColors.error),
    onError: color(MaterialDynamicColors.onError),
    errorContainer: color(MaterialDynamicColors.errorContainer),
    onErrorContainer: color(MaterialDynamicColors.onErrorContainer),
    surface: color(MaterialDynamicColors.surface),
    onSurface: color(MaterialDynamicColors.onSurface),
    surfaceDim: color(MaterialDynamicColors.surfaceDim),
    surfaceBright: color(MaterialDynamicColors.surfaceBright),
    surfaceContainerLowest: color(MaterialDynamicColors.surfaceContainerLowest),
    surfaceContainerLow: color(MaterialDynamicColors.surfaceContainerLow),
    surfaceContainer: color(MaterialDynamicColors.surfaceContainer),
    surfaceContainerHigh: color(MaterialDynamicColors.surfaceContainerHigh),
    surfaceContainerHighest: color(
      MaterialDynamicColors.surfaceContainerHighest,
    ),
    onSurfaceVariant: color(MaterialDynamicColors.onSurfaceVariant),
    outline: color(MaterialDynamicColors.outline),
    outlineVariant: color(MaterialDynamicColors.outlineVariant),
    inverseSurface: color(MaterialDynamicColors.inverseSurface),
    onInverseSurface: color(MaterialDynamicColors.inverseOnSurface),
    inversePrimary: color(MaterialDynamicColors.inversePrimary),
    shadow: color(MaterialDynamicColors.shadow),
    scrim: color(MaterialDynamicColors.scrim),
    surfaceTint: color(MaterialDynamicColors.surfaceTint),
  );
}
