import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/intent_service.dart';
import 'package:freedium_mobile/core/theme/theme_provider.dart';
import 'package:freedium_mobile/features/home/presentation/home_screen.dart';
import 'package:freedium_mobile/features/webview/presentation/webview_screen.dart';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final initialIntentHandledProvider = StateProvider<bool>((ref) => false);

class App extends ConsumerWidget {
  const App({super.key});

  void _navigateToWebview(String url) {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      if (navigator.context.mounted) {
        final currentRoute = ModalRoute.of(navigator.context);
        if (currentRoute?.settings.name != null) {
          return;
        }

        navigator.push(
          MaterialPageRoute(
            builder: (context) => WebviewScreen(url: url),
            settings: RouteSettings(name: '/webview/$url'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(dynamicThemeProvider);
    final hasHandledInitialIntent = ref.watch(initialIntentHandledProvider);

    ref.listen<AsyncValue<String>>(intentStreamProvider, (previous, next) {
      next.whenData((url) {
        if (url.isNotEmpty) {
          final navigator = navigatorKey.currentState;
          if (navigator != null && navigator.context.mounted) {
            final currentRoute = ModalRoute.of(navigator.context);
            final isCurrentlyOnWebview =
                currentRoute?.settings.name?.startsWith('/webview/') ?? false;

            if (!isCurrentlyOnWebview) {
              _navigateToWebview(url);
            }
          }
        }
      });
    });

    if (!hasHandledInitialIntent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(initialIntentHandledProvider.notifier).state = true;
        ref.read(intentServiceProvider).getInitialIntent().then((value) {
          if (value.isNotEmpty) {
            final url = value.first.path;
            if (url.isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 400)).then((_) {
                _navigateToWebview(url);
                ReceiveSharingIntent.instance.reset();
              });
            }
          }
        });
      });
    }

    return themeAsync.when(
      data:
          (theme) => MaterialApp(
            navigatorKey: navigatorKey,
            title: AppConstants.appName,
            theme: theme.lightTheme,
            darkTheme: theme.darkTheme,
            themeMode: ThemeMode.system,
            home: const HomeScreen(),
          ),
      loading:
          () => const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
      error:
          (err, stack) => MaterialApp(
            home: Scaffold(body: Center(child: Text('Error: $err'))),
          ),
    );
  }
}
