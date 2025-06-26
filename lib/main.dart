import 'dart:async';
import 'dart:developer';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:freedium_mobile/screens/home_screen.dart';
import 'package:freedium_mobile/screens/webview_screen.dart';
import 'package:freedium_mobile/theme/theme.dart';
import 'package:freedium_mobile/theme/util.dart';
import 'package:listen_sharing_intent/listen_sharing_intent.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];

  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (values) {
        setState(() {
          _sharedFiles.clear();
          _sharedFiles.addAll(values);

          log("Shared files: ${_sharedFiles.map((e) => e.path).toList()}");
        });
        if (_sharedFiles.isNotEmpty) {
          final uri = Uri.tryParse(_sharedFiles.first.path);

          if (uri != null) {
            // Delay navigation to ensure theme is applied
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 200), () {
                _navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => WebviewScreen(url: uri.toString()),
                  ),
                );
              });
            });
          }
        }
      },
      onError: (err) {
        log("getIntentDataStream error: $err");
      },
    );

    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);

        log("Shared files: ${_sharedFiles.map((e) => e.path).toList()}");
      });
      if (_sharedFiles.isNotEmpty) {
        final uri = Uri.tryParse(_sharedFiles.first.path);

        if (uri != null) {
          // Delay navigation to ensure theme is applied

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 200), () {
              _navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => WebviewScreen(url: uri.toString()),
                ),
              );
            });
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Roboto", "Roboto");
    MaterialTheme materialTheme = MaterialTheme(textTheme);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = materialTheme.light().colorScheme;
          darkColorScheme = materialTheme.dark().colorScheme;
        }
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Freedium Mobile',
          theme: materialTheme.theme(lightColorScheme),
          darkTheme: materialTheme.theme(darkColorScheme),
          themeMode: ThemeMode.system,
          home: const HomeScreen(),
        );
      },
    );
  }
}
