import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/update_card.dart';

void main() {
  group('UpdateCard', () {
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

      await tester.tap(find.widgetWithText(FilledButton, 'Update'));
      await tester.pumpAndSettle();

      expect(launchedUrls, [releaseUrl]);
      expect(find.text('Could not open link'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
