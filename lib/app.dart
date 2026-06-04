import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/intent_service.dart';
import 'package:freedium_mobile/core/theme/theme_provider.dart';
import 'package:freedium_mobile/core/utils/article_url_parser.dart';
import 'package:freedium_mobile/features/home/presentation/home_screen.dart';
import 'package:freedium_mobile/features/onboarding/application/onboarding_provider.dart';
import 'package:freedium_mobile/features/onboarding/presentation/onboarding_screen.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@visibleForTesting
class CurrentRouteNameObserver extends NavigatorObserver {
  final List<Route<dynamic>> _routeStack = [];

  String? get currentRouteName =>
      _routeStack.isEmpty ? null : _routeStack.last.settings.name;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _routeStack.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _routeStack.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _routeStack.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute == null) {
      if (newRoute != null) {
        _routeStack.add(newRoute);
      }
      return;
    }

    final index = _routeStack.indexOf(oldRoute);
    if (index == -1) return;

    if (newRoute == null) {
      _routeStack.removeAt(index);
    } else {
      _routeStack[index] = newRoute;
    }
  }

  @visibleForTesting
  void reset() {
    _routeStack.clear();
  }
}

final currentRouteNameObserver = CurrentRouteNameObserver();

class InitialIntentHandledNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setHandled() {
    state = true;
  }
}

final initialIntentHandledProvider =
    NotifierProvider<InitialIntentHandledNotifier, bool>(
      InitialIntentHandledNotifier.new,
    );

class PendingIntentUrlNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void stash(String url) {
    state = url;
  }

  void clear() {
    state = null;
  }
}

final pendingIntentUrlProvider =
    NotifierProvider<PendingIntentUrlNotifier, String?>(
      PendingIntentUrlNotifier.new,
    );

@visibleForTesting
String incomingWebviewRouteName(String url) => '/webview/$url';

@visibleForTesting
bool shouldSkipIncomingWebviewNavigation({
  required String? currentRouteName,
  required String targetUrl,
}) {
  return currentRouteName == incomingWebviewRouteName(targetUrl);
}

class App extends ConsumerWidget {
  const App({super.key});

  void _navigateToWebview(String url) {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      if (navigator.context.mounted) {
        if (shouldSkipIncomingWebviewNavigation(
          currentRouteName: currentRouteNameObserver.currentRouteName,
          targetUrl: url,
        )) {
          return;
        }

        navigator.push(
          MaterialPageRoute(
            builder: (context) => WebviewScreen(url: url),
            settings: RouteSettings(name: incomingWebviewRouteName(url)),
          ),
        );
      }
    }
  }

  void _handleIncomingIntent(WidgetRef ref, String value) {
    final url = extractArticleUrl(value);
    if (url == null) return;

    final onboarding = ref.read(onboardingProvider);
    if (onboarding.isLoading || !onboarding.hasSeenOnboarding) {
      ref.read(pendingIntentUrlProvider.notifier).stash(url);
      return;
    }

    _navigateToWebview(url);
    ReceiveSharingIntent.instance.reset();
  }

  Future<void> _processInitialIntent(WidgetRef ref) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final value = await ref.read(intentServiceProvider).getInitialIntent();
    final url = extractFirstArticleUrl(value.map((item) => item.path));
    if (url == null) return;

    _handleIncomingIntent(ref, url);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(dynamicThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final hasHandledInitialIntent = ref.watch(initialIntentHandledProvider);
    final onboarding = ref.watch(onboardingProvider);
    final hasSeenOnboarding = onboarding.hasSeenOnboarding;

    ref.listen<OnboardingState>(onboardingProvider, (previous, next) {
      if (next.isLoading || !next.hasSeenOnboarding) return;

      final pendingUrl = ref.read(pendingIntentUrlProvider);
      if (pendingUrl == null || pendingUrl.isEmpty) return;

      ref.read(pendingIntentUrlProvider.notifier).clear();
      _navigateToWebview(pendingUrl);
      ReceiveSharingIntent.instance.reset();
    });

    ref.listen<AsyncValue<String>>(intentStreamProvider, (previous, next) {
      next.whenData((url) {
        _handleIncomingIntent(ref, url);
      });
    });

    if (!hasHandledInitialIntent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(initialIntentHandledProvider.notifier).setHandled();
        unawaited(_processInitialIntent(ref));
      });
    }

    return themeAsync.when(
      data: (theme) => MaterialApp(
        navigatorKey: navigatorKey,
        title: AppConstants.appName,
        theme: theme.lightTheme,
        darkTheme: theme.darkTheme,
        themeMode: themeMode,
        navigatorObservers: [currentRouteNameObserver],
        home: onboarding.isLoading
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : hasSeenOnboarding
            ? const HomeScreen()
            : const OnboardingScreen(),
      ),
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }
}
