import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/changelog_bottom_sheet.dart';

void main() {
  group('ChangelogBottomSheet', () {
    testWidgets('shows link failure after update URL cannot be opened', (
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
              body: Builder(
                builder: (context) {
                  return Center(
                    child: FilledButton(
                      onPressed: () {
                        showChangelogBottomSheet(
                          context,
                          const UpdateInfo(
                            latestVersion: 'v1.2.3',
                            releaseUrl: releaseUrl,
                            releaseNotes: 'Release notes',
                          ),
                        );
                      },
                      child: const Text('Show changelog'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show changelog'));
      await tester.pumpAndSettle();

      expect(find.text('What\'s New'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Update Now'));
      await tester.pumpAndSettle();

      expect(launchedUrls, [releaseUrl]);
      expect(find.text('What\'s New'), findsNothing);
      expect(find.text('Could not open link'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows link failure when release note link cannot be opened', (
      tester,
    ) async {
      final launchedUrls = <String?>[];
      const releaseNoteUrl = 'https://example.com/release-notes';

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
              body: Builder(
                builder: (context) {
                  return Center(
                    child: FilledButton(
                      onPressed: () {
                        showChangelogBottomSheet(
                          context,
                          const UpdateInfo(
                            latestVersion: 'v1.2.3',
                            releaseUrl:
                                'https://github.com/example/app/releases/tag/v1.2.3',
                            releaseNotes: '[Release notes]($releaseNoteUrl)',
                          ),
                        );
                      },
                      child: const Text('Show changelog'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show changelog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Release notes'));
      await tester.pumpAndSettle();

      expect(launchedUrls, [releaseNoteUrl]);
      expect(find.text('What\'s New'), findsOneWidget);
      expect(find.text('Could not open link'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
