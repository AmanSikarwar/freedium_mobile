import 'package:flutter/material.dart';
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
import 'package:listen_sharing_intent/listen_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeClipboardService extends ClipboardService {
  @override
  Future<String?> paste() async => null;
}

class _FakeIntentService extends IntentService {
  @override
  Future<List<SharedMediaFile>> getInitialIntent() async => <SharedMediaFile>[];
}

class _FailingIntentService extends IntentService {
  @override
  Future<List<SharedMediaFile>> getInitialIntent() async {
    throw Exception('initial intent unavailable');
  }
}

class _RecordingIntentService extends IntentService {
  int initialIntentRequests = 0;

  @override
  Future<List<SharedMediaFile>> getInitialIntent() async {
    initialIntentRequests++;
    return <SharedMediaFile>[];
  }
}

class _FakeUpdateService extends UpdateService {
  @override
  Future<UpdateInfo?> checkForUpdate() async => null;
}

Widget _buildApp({
  required SharedPreferences prefs,
  IntentService? intentService,
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
      dynamicThemeProvider.overrideWith((ref) => ref.watch(themeProvider)),
      clipboardServiceProvider.overrideWith((ref) => _FakeClipboardService()),
      intentServiceProvider.overrideWith(
        (ref) => intentService ?? _FakeIntentService(),
      ),
      intentStreamProvider.overrideWith((ref) => const Stream<String>.empty()),
      updateServiceProvider.overrideWith((ref) => _FakeUpdateService()),
    ],
    child: const App(),
  );
}

void main() {
  setUp(currentRouteNameObserver.reset);

  group('incoming webview navigation', () {
    test('skips only duplicate incoming webview routes', () {
      const targetUrl = 'https://medium.com/example/story';

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
      const targetUrl = 'https://medium.com/example/story';
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
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(_buildApp(prefs: prefs));
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
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        _buildApp(prefs: prefs, intentService: _FailingIntentService()),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('does not read initial intent after app disposal', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'has_seen_onboarding': true});
      final prefs = await SharedPreferences.getInstance();
      final intentService = _RecordingIntentService();

      await tester.pumpWidget(
        _buildApp(prefs: prefs, intentService: intentService),
      );
      await tester.pump();

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(intentService.initialIntentRequests, 0);
    });
  });
}
