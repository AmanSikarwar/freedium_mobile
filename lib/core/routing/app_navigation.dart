import 'package:material_ui/material_ui.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@visibleForTesting
class CurrentRouteNameObserver() extends NavigatorObserver {
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

@visibleForTesting
String incomingWebviewRouteName(String url) => '/webview/$url';

@visibleForTesting
bool shouldSkipIncomingWebviewNavigation({
  required String? currentRouteName,
  required String targetUrl,
}) {
  return currentRouteName == incomingWebviewRouteName(targetUrl);
}

/// Pushes a [WebviewScreen] for [url] unless it is already the top route.
/// Returns `true` when a navigation was pushed.
bool navigateToWebview(String url) {
  final navigator = navigatorKey.currentState;
  if (navigator == null || !navigator.context.mounted) return false;

  if (shouldSkipIncomingWebviewNavigation(
    currentRouteName: currentRouteNameObserver.currentRouteName,
    targetUrl: url,
  )) {
    return false;
  }

  navigator.push(
    MaterialPageRoute<void>(
      builder: (context) => WebviewScreen(url: url),
      settings: RouteSettings(name: incomingWebviewRouteName(url)),
    ),
  );
  return true;
}
