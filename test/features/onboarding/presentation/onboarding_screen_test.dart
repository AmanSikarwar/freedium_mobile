import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingNavigatorObserver extends NavigatorObserver {
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
      SharedPreferences.setMockInitialValues({});
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

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(prefs.getBool('has_seen_onboarding'), isTrue);
      expect(observer.pushedRoutes, 0);
      expect(observer.replacedRoutes, 0);
    });
  });
}
