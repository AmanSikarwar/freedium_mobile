import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../test_helpers.dart';

Future<void> _pumpWithLargeTextAtSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const OnboardingScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _RecordingNavigatorObserver() extends NavigatorObserver {
  int pushedRoutes = 0;
  int replacedRoutes = 0;

  void reset() {
    pushedRoutes = 0;
    replacedRoutes = 0;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    pushedRoutes++;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    replacedRoutes++;
  }
}

void main() {
  group('OnboardingScreen', () {
    testWidgets('completes onboarding without pushing its own home route', (
      tester,
    ) async {
      await mockPrefs({});
      final prefs = await SharedPreferences.getInstance();
      final observer = _RecordingNavigatorObserver();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) async => prefs),
          ],
          child: MaterialApp(
            navigatorObservers: [observer],
            home: const OnboardingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      observer.reset();

      expect(find.textContaining('Medium, NYT, WaPo'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(prefs.getBool('has_seen_onboarding'), isTrue);
      expect(observer.pushedRoutes, 0);
      expect(observer.replacedRoutes, 0);
    });

    for (final size in [const Size(320, 640), const Size(640, 360)]) {
      testWidgets(
        'keeps large text scrollable at ${size.width}x${size.height}',
        (tester) async {
          await _pumpWithLargeTextAtSize(tester, size);

          expect(tester.takeException(), isNull);
          expect(
            find.textContaining('Read articles from Medium, NYT'),
            findsOneWidget,
          );

          await tester.ensureVisible(
            find.textContaining('Read articles from Medium, NYT'),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
