import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/app.dart';
import 'package:freedium_mobile/core/services/clipboard_service.dart';
import 'package:freedium_mobile/core/services/font_size_service.dart';
import 'package:freedium_mobile/core/services/intent_service.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/core/theme/theme_provider.dart';
import 'package:freedium_mobile/features/home/presentation/home_screen.dart';
import 'package:freedium_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:receive_intent/receive_intent.dart' as platform;
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

class _FailingIntentService() extends IntentService {
  @override
  Future<platform.Intent?> getInitialIntent() async {
    throw Exception('initial intent unavailable');
  }
}

class _RecordingIntentService() extends IntentService {
  int initialIntentRequests = 0;

  @override
  Future<platform.Intent?> getInitialIntent() async {
    initialIntentRequests++;
    return null;
  }
}

class _FakeUpdateService() extends UpdateService {
  @override
  Future<UpdateInfo?> checkForUpdate() async => null;
}

/// Pumps [App] with mock services.
///
/// The [ProviderScope] is created directly inside [tester.pumpWidget] (rather
/// than returned from this helper) so the scope is not treated as a nested
/// scope by `scoped_providers_should_specify_dependencies`.
Future<void> _pumpApp({
  required WidgetTester tester,
  required SharedPreferences prefs,
  IntentService? intentService,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        dynamicThemeProvider.overrideWith((ref) => ref.watch(themeProvider)),
        clipboardServiceProvider.overrideWith((ref) => FakeClipboardService()),
        intentServiceProvider.overrideWith(
          (ref) => intentService ?? FakeIntentService(),
        ),
        intentStreamProvider.overrideWith(
          (ref) => const Stream<String>.empty(),
        ),
        updateServiceProvider.overrideWith((ref) => _FakeUpdateService()),
      ],
      child: const App(),
    ),
  );
}

void main() {
  setUp(currentRouteNameObserver.reset);

  group('incoming webview navigation', () {
    test('skips only duplicate incoming webview routes', () {
      const targetUrl = TestFixtures.storyUrl;

      expect(
        shouldSkipIncomingWebviewNavigation(
          currentRouteName: incomingWebviewRouteName(targetUrl),
          targetUrl: targetUrl,
        ),
        isTrue,
      );
      expect(
        shouldSkipIncomingWebviewNavigation(
          currentRouteName: incomingWebviewRouteName(
            'https://medium.com/example/other',
          ),
          targetUrl: targetUrl,
        ),
        isFalse,
      );
      expect(
        shouldSkipIncomingWebviewNavigation(
          currentRouteName: null,
          targetUrl: targetUrl,
        ),
        isFalse,
      );
    });

    testWidgets('tracks the active route for duplicate share detection', (
      tester,
    ) async {
      const targetUrl = TestFixtures.storyUrl;
      final navigatorKey = GlobalKey<NavigatorState>();
      final observer = CurrentRouteNameObserver();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [observer],
          home: const SizedBox.shrink(),
        ),
      );

      navigatorKey.currentState!.push<void>(
        MaterialPageRoute(
          settings: RouteSettings(name: incomingWebviewRouteName(targetUrl)),
          builder: (_) => const SizedBox.shrink(),
        ),
      );
      await tester.pumpAndSettle();

      expect(observer.currentRouteName, incomingWebviewRouteName(targetUrl));
      expect(
        shouldSkipIncomingWebviewNavigation(
          currentRouteName: observer.currentRouteName,
          targetUrl: targetUrl,
        ),
        isTrue,
      );
    });
  });

  group('app onboarding routing', () {
    testWidgets('shows home after completing onboarding without a shared URL', (
      tester,
    ) async {
      await mockPrefs({});
      final prefs = await SharedPreferences.getInstance();

      await _pumpApp(tester: tester, prefs: prefs);
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(prefs.getBool('has_seen_onboarding'), isTrue);
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Read Article'), findsOneWidget);
    });

    testWidgets('keeps home visible when initial intent lookup fails', (
      tester,
    ) async {
      await mockPrefs({'has_seen_onboarding': true});
      final prefs = await SharedPreferences.getInstance();

      await _pumpApp(
        tester: tester,
        prefs: prefs,
        intentService: _FailingIntentService(),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('does not read initial intent after app disposal', (
      tester,
    ) async {
      await mockPrefs({'has_seen_onboarding': true});
      final prefs = await SharedPreferences.getInstance();
      final intentService = _RecordingIntentService();

      await _pumpApp(
        tester: tester,
        prefs: prefs,
        intentService: intentService,
      );
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(intentService.initialIntentRequests, 0);
    });
  });
}
