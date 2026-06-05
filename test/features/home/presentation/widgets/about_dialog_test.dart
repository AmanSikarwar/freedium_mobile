import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/about_dialog.dart';

void main() {
  group('AboutDialog', () {
    testWidgets('shows link failure when source link cannot be opened', (
      tester,
    ) async {
      final launchedUrls = <String?>[];

      await _pumpAboutDialog(tester, launchedUrls);

      await tester.tap(find.text('Show about'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('GitHub'));
      await tester.pumpAndSettle();

      expect(launchedUrls, [AppConstants.appSourceUrl]);
      expect(find.text('GitHub'), findsOneWidget);
      expect(find.text('Could not open link'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows link failure when author link cannot be opened', (
      tester,
    ) async {
      final launchedUrls = <String?>[];

      await _pumpAboutDialog(tester, launchedUrls);

      await tester.tap(find.text('Show about'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aman Sikarwar'));
      await tester.pumpAndSettle();

      expect(launchedUrls, ['https://github.com/amansikarwar']);
      expect(find.text('Aman Sikarwar'), findsOneWidget);
      expect(find.text('Could not open link'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> _pumpAboutDialog(
  WidgetTester tester,
  List<String?> launchedUrls,
) async {
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
          body: Consumer(
            builder: (context, ref, child) {
              return Center(
                child: FilledButton(
                  onPressed: () => showAppAboutDialog(context, ref),
                  child: const Text('Show about'),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
