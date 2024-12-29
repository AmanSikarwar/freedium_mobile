import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:freedium_mobile/screens/home_screen.dart';
import 'package:freedium_mobile/screens/webview_screen.dart';
import 'package:freedium_mobile/theme/theme.dart';
import 'package:freedium_mobile/theme/util.dart';
import 'package:receive_sharing_intent_plus/receive_sharing_intent_plus.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    ReceiveSharingIntentPlus.getInitialText().then((String? value) {
      log('Received initial text: $value');

      if (value != null) {
        final uri = Uri.tryParse(value);

        if (uri != null) {
          _navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => WebviewScreen(
                url: uri.toString(),
              ),
            ),
          );
        }
      }
    });
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      log('Received uri: $uri');

      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => WebviewScreen(
            url: uri.toString(),
          ),
        ),
      );
    });

    super.initState();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "Roboto");
    MaterialTheme theme = MaterialTheme(textTheme);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = theme.light().colorScheme;
          darkColorScheme = theme.dark().colorScheme;
        }
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Freedium Mobile',
          theme: theme.theme(lightColorScheme),
          darkTheme: theme.theme(darkColorScheme),
          themeMode: ThemeMode.system,
          home: const HomeScreen(),
        );
      },
    );
  }
}
