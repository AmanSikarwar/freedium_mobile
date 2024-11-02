import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:freedium/screens/home_screen.dart';
import 'package:freedium/screens/webview_screen.dart';
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
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Freedium',
      theme: ThemeData(
        colorScheme: const ColorScheme.light().copyWith(
          primary: Colors.green,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.green,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
