import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:freedium_mobile/core/layout/floating_toolbar.dart';
import 'package:freedium_mobile/core/theme/app_theme.dart';
import 'package:freedium_mobile/core/theme/expressive_theme.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('preserves native roles in expressive ${brightness.name}', (
      tester,
    ) async {
      late ColorScheme material;
      late M3EColorScheme expressive;
      final scheme = ColorScheme.fromSeed(
        seedColor: const Color(0xff006c4c),
        brightness: brightness,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme(Typography.englishLike2021).theme(scheme),
          builder: (context, child) => ExpressiveTheme(child: child!),
          home: Builder(
            builder: (context) {
              material = Theme.of(context).colorScheme;
              expressive = M3ETheme.of(context).colorScheme;
              return const Scaffold();
            },
          ),
        ),
      );

      expect(material, scheme);
      for (final converted in [material, expressive.toColorScheme()]) {
        expect(converted.brightness, brightness);
        expect(converted.primary, scheme.primary);
        expect(converted.onPrimary, scheme.onPrimary);
        expect(converted.primaryContainer, scheme.primaryContainer);
        expect(converted.onPrimaryContainer, scheme.onPrimaryContainer);
        expect(converted.surface, scheme.surface);
        expect(converted.onSurface, scheme.onSurface);
        expect(converted.surfaceContainerLow, scheme.surfaceContainerLow);
        expect(converted.surfaceContainerHigh, scheme.surfaceContainerHigh);
        expect(converted.inverseSurface, scheme.inverseSurface);
        expect(converted.onInverseSurface, scheme.onInverseSurface);
        expect(converted.error, scheme.error);
      }
    });
  }

  testWidgets('status bar overlay style follows the resolved theme', (
    tester,
  ) async {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff006c4c),
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff006c4c),
      brightness: Brightness.dark,
    );
    final mode = ValueNotifier(ThemeMode.light);
    addTearDown(mode.dispose);

    SystemUiOverlayStyle overlayStyle() => tester
        .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
        )
        .value;

    await tester.pumpWidget(
      ValueListenableBuilder<ThemeMode>(
        valueListenable: mode,
        builder: (context, value, _) => MaterialApp(
          theme: AppTheme(Typography.englishLike2021).theme(lightScheme),
          darkTheme: AppTheme(Typography.englishLike2021).theme(darkScheme),
          themeMode: value,
          builder: (context, child) => ExpressiveTheme(child: child!),
          home: const SizedBox.shrink(),
        ),
      ),
    );

    expect(overlayStyle().statusBarColor, Colors.transparent);
    expect(overlayStyle().statusBarIconBrightness, Brightness.dark);
    expect(overlayStyle().statusBarBrightness, Brightness.light);

    mode.value = ThemeMode.dark;
    await tester.pumpAndSettle();

    expect(overlayStyle().statusBarIconBrightness, Brightness.light);
    expect(overlayStyle().statusBarBrightness, Brightness.dark);
    expect(overlayStyle().systemStatusBarContrastEnforced, isFalse);
  });

  testWidgets('snackbars clear the floating toolbars', (tester) async {
    late M3ESnackbarTheme snackbars;
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xff006c4c));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme(Typography.englishLike2021).theme(scheme),
        builder: (context, child) => ExpressiveTheme(child: child!),
        home: Builder(
          builder: (context) {
            snackbars = M3ETheme.of(context).snackBarTheme;
            return const Scaffold();
          },
        ),
      ),
    );

    expect(snackbars.overlayBottomInset, floatingToolbarContentInset());
  });

  testWidgets('filled text fields use the expressive rounded shape', (
    tester,
  ) async {
    late M3ETextFieldTheme textFields;
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xff006c4c));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme(Typography.englishLike2021).theme(scheme),
        builder: (context, child) => ExpressiveTheme(child: child!),
        home: Builder(
          builder: (context) {
            textFields = M3ETheme.of(context).textFieldTheme;
            return const Scaffold();
          },
        ),
      ),
    );

    expect(textFields.filledShape, M3EShapes.radiusExtraLarge);
    expect(textFields.activeIndicatorWidth, 0);
    expect(textFields.focusActiveIndicatorWidth, 0);
  });
}
