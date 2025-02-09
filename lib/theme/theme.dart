import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff006e1c),
      surfaceTint: Color(0xff006e1c),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff58bc5b),
      onPrimaryContainer: Color(0xff002204),
      secondary: Color(0xff42673f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffc7f2bf),
      onSecondaryContainer: Color(0xff2f532d),
      tertiary: Color(0xff006492),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff2ab1fa),
      onTertiaryContainer: Color(0xff001f31),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      surface: Color(0xfff5fbef),
      onSurface: Color(0xff171d16),
      onSurfaceVariant: Color(0xff3f4a3c),
      outline: Color(0xff6f7a6b),
      outlineVariant: Color(0xffbecab9),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322a),
      inversePrimary: Color(0xff78dc77),
      primaryFixed: Color(0xff94f990),
      onPrimaryFixed: Color(0xff002204),
      primaryFixedDim: Color(0xff78dc77),
      onPrimaryFixedVariant: Color(0xff005313),
      secondaryFixed: Color(0xffc3eebb),
      onSecondaryFixed: Color(0xff002204),
      secondaryFixedDim: Color(0xffa8d1a1),
      onSecondaryFixedVariant: Color(0xff2b4f2a),
      tertiaryFixed: Color(0xffcae6ff),
      onTertiaryFixed: Color(0xff001e2f),
      tertiaryFixedDim: Color(0xff8cceff),
      onTertiaryFixedVariant: Color(0xff004b6f),
      surfaceDim: Color(0xffd6dcd0),
      surfaceBright: Color(0xfff5fbef),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f6ea),
      surfaceContainer: Color(0xffeaf0e4),
      surfaceContainerHigh: Color(0xffe4eade),
      surfaceContainerHighest: Color(0xffdee4d9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff004f11),
      surfaceTint: Color(0xff006e1c),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff1e862d),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff274b26),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff587e54),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff00476a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff007cb3),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff8c0009),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffda342e),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbef),
      onSurface: Color(0xff171d16),
      onSurfaceVariant: Color(0xff3b4639),
      outline: Color(0xff576254),
      outlineVariant: Color(0xff737e6f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322a),
      inversePrimary: Color(0xff78dc77),
      primaryFixed: Color(0xff1e862d),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff006b1b),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff587e54),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff40653d),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff007cb3),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff00628f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd6dcd0),
      surfaceBright: Color(0xfff5fbef),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f6ea),
      surfaceContainer: Color(0xffeaf0e4),
      surfaceContainerHigh: Color(0xffe4eade),
      surfaceContainerHighest: Color(0xffdee4d9),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff002905),
      surfaceTint: Color(0xff006e1c),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff004f11),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff042908),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff274b26),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff002539),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff00476a),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff4e0002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8c0009),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbef),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff1d261b),
      outline: Color(0xff3b4639),
      outlineVariant: Color(0xff3b4639),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322a),
      inversePrimary: Color(0xffb1ffaa),
      primaryFixed: Color(0xff004f11),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003509),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff274b26),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff103412),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff00476a),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff003049),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd6dcd0),
      surfaceBright: Color(0xfff5fbef),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f6ea),
      surfaceContainer: Color(0xffeaf0e4),
      surfaceContainerHigh: Color(0xffe4eade),
      surfaceContainerHighest: Color(0xffdee4d9),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff78dc77),
      surfaceTint: Color(0xff78dc77),
      onPrimary: Color(0xff00390a),
      primaryContainer: Color(0xff43a648),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffa8d1a1),
      onSecondary: Color(0xff143815),
      secondaryContainer: Color(0xff224521),
      onSecondaryContainer: Color(0xffb2dcab),
      tertiary: Color(0xff8cceff),
      onTertiary: Color(0xff00344e),
      tertiaryContainer: Color(0xff009ce1),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0f150e),
      onSurface: Color(0xffdee4d9),
      onSurfaceVariant: Color(0xffbecab9),
      outline: Color(0xff899484),
      outlineVariant: Color(0xff3f4a3c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4d9),
      inversePrimary: Color(0xff006e1c),
      primaryFixed: Color(0xff94f990),
      onPrimaryFixed: Color(0xff002204),
      primaryFixedDim: Color(0xff78dc77),
      onPrimaryFixedVariant: Color(0xff005313),
      secondaryFixed: Color(0xffc3eebb),
      onSecondaryFixed: Color(0xff002204),
      secondaryFixedDim: Color(0xffa8d1a1),
      onSecondaryFixedVariant: Color(0xff2b4f2a),
      tertiaryFixed: Color(0xffcae6ff),
      onTertiaryFixed: Color(0xff001e2f),
      tertiaryFixedDim: Color(0xff8cceff),
      onTertiaryFixedVariant: Color(0xff004b6f),
      surfaceDim: Color(0xff0f150e),
      surfaceBright: Color(0xff353b33),
      surfaceContainerLowest: Color(0xff0a1009),
      surfaceContainerLow: Color(0xff171d16),
      surfaceContainer: Color(0xff1b211a),
      surfaceContainerHigh: Color(0xff262c24),
      surfaceContainerHighest: Color(0xff30362e),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff7ce17b),
      surfaceTint: Color(0xff78dc77),
      onPrimary: Color(0xff001b03),
      primaryContainer: Color(0xff43a648),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffacd6a5),
      onSecondary: Color(0xff001b03),
      secondaryContainer: Color(0xff739b6e),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xff96d1ff),
      onTertiary: Color(0xff001828),
      tertiaryContainer: Color(0xff009ce1),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab1),
      onError: Color(0xff370001),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f150e),
      onSurface: Color(0xfff7fdf1),
      onSurfaceVariant: Color(0xffc2cebd),
      outline: Color(0xff9ba696),
      outlineVariant: Color(0xff7b8677),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4d9),
      inversePrimary: Color(0xff005413),
      primaryFixed: Color(0xff94f990),
      onPrimaryFixed: Color(0xff001602),
      primaryFixedDim: Color(0xff78dc77),
      onPrimaryFixedVariant: Color(0xff00400c),
      secondaryFixed: Color(0xffc3eebb),
      onSecondaryFixed: Color(0xff001602),
      secondaryFixedDim: Color(0xffa8d1a1),
      onSecondaryFixedVariant: Color(0xff1a3e1a),
      tertiaryFixed: Color(0xffcae6ff),
      onTertiaryFixed: Color(0xff001320),
      tertiaryFixedDim: Color(0xff8cceff),
      onTertiaryFixedVariant: Color(0xff003a57),
      surfaceDim: Color(0xff0f150e),
      surfaceBright: Color(0xff353b33),
      surfaceContainerLowest: Color(0xff0a1009),
      surfaceContainerLow: Color(0xff171d16),
      surfaceContainer: Color(0xff1b211a),
      surfaceContainerHigh: Color(0xff262c24),
      surfaceContainerHighest: Color(0xff30362e),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff1ffea),
      surfaceTint: Color(0xff78dc77),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff7ce17b),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfff1ffea),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffacd6a5),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff9fbff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff96d1ff),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f150e),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfff3feec),
      outline: Color(0xffc2cebd),
      outlineVariant: Color(0xffc2cebd),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4d9),
      inversePrimary: Color(0xff003208),
      primaryFixed: Color(0xff98fe94),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff7ce17b),
      onPrimaryFixedVariant: Color(0xff001b03),
      secondaryFixed: Color(0xffc8f2c0),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffacd6a5),
      onSecondaryFixedVariant: Color(0xff001b03),
      tertiaryFixed: Color(0xffd2eaff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff96d1ff),
      onTertiaryFixedVariant: Color(0xff001828),
      surfaceDim: Color(0xff0f150e),
      surfaceBright: Color(0xff353b33),
      surfaceContainerLowest: Color(0xff0a1009),
      surfaceContainerLow: Color(0xff171d16),
      surfaceContainer: Color(0xff1b211a),
      surfaceContainerHigh: Color(0xff262c24),
      surfaceContainerHighest: Color(0xff30362e),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
