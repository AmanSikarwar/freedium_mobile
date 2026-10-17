import 'package:material_3_expressive/material_3_expressive.dart';

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';
import 'package:freedium_mobile/core/theme/app_theme.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/update_card.dart';

void main() {
  group('UpdateCard', () {
    final schemes = {
      'light': AppTheme.lightScheme(),
      'light medium contrast': AppTheme.lightMediumContrastScheme(),
      'light high contrast': AppTheme.lightHighContrastScheme(),
      'dark': AppTheme.darkScheme(),
      'dark medium contrast': AppTheme.darkMediumContrastScheme(),
      'dark high contrast': AppTheme.darkHighContrastScheme(),
    };
    for (final entry in schemes.entries) {
      testWidgets('keeps version text readable in ${entry.key}', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme(Typography.englishLike2021).theme(entry.value),
              home: Scaffold(
                body: UpdateCard(
                  updateInfo: const UpdateInfo(
                    latestVersion: 'v1.2.3',
                    releaseUrl: 'https://github.com/example/app/releases',
                    releaseNotes: 'Release notes',
                  ),
                  onDismissed: () {},
                ),
              ),
            ),
          ),
        );

        final version = tester.widget<RichText>(
          find.descendant(
            of: find.text('New version v1.2.3'),
            matching: find.byType(RichText),
          ),
        );
        final background = tester.widget<M3ECard>(find.byType(M3ECard)).color!;
        final foreground = Color.alphaBlend(
          version.text.style!.color!,
          background,
        );
        final foregroundLuminance = foreground.computeLuminance();
        final backgroundLuminance = background.computeLuminance();
        final contrast =
            (math.max(foregroundLuminance, backgroundLuminance) + 0.05) /
            (math.min(foregroundLuminance, backgroundLuminance) + 0.05);
        expect(contrast, greaterThanOrEqualTo(4.5));
      });
    }

    testWidgets('shows link failure when update URL cannot be opened', (
      tester,
    ) async {
      final launchedUrls = <String?>[];
      const releaseUrl = 'https://github.com/example/app/releases/tag/v1.2.3';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            externalUrlLauncherProvider.overrideWith(
              (ref) => (url) async {
                launchedUrls.add(url);
                return false;
              },
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: UpdateCard(
                updateInfo: const UpdateInfo(
                  latestVersion: 'v1.2.3',
                  releaseUrl: releaseUrl,
                  releaseNotes: 'Release notes',
                ),
                onDismissed: () {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(M3EButton, 'Update'));
      await tester.pumpAndSettle();

      expect(launchedUrls, [releaseUrl]);
      expect(find.text('Could not open link'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
