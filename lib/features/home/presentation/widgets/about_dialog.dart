import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';

void showAppAboutDialog(BuildContext context, WidgetRef ref) {
  showAboutDialog(
    context: context,
    applicationIcon: Image.asset('assets/icon/icon.png', width: 48, height: 48),
    applicationName: AppConstants.appName,
    applicationVersion: AppConstants.appVersion,
    children: [
      const Text(
        'Freedium is a paywall bypasser for Medium articles.\n\n'
        'Just paste the URL of the article you want to read and '
        'Freedium will take care of the rest!\n\n',
      ),
      Wrap(
        children: [
          const Text('Source code available on '),
          GestureDetector(
            onTap: () =>
                unawaited(_launchUrl(context, ref, AppConstants.appSourceUrl)),
            child: Text(
              'GitHub',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: .center,
        mainAxisSize: .min,
        children: [
          const Text('Made with ❤️ by', style: TextStyle(fontSize: 12)),
          TextButton(
            onPressed: () => unawaited(
              _launchUrl(context, ref, 'https://github.com/amansikarwar'),
            ),
            child: const Text('Aman Sikarwar', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    ],
  );
}

Future<void> _launchUrl(BuildContext context, WidgetRef ref, String url) async {
  final launched = await ref.read(externalUrlLauncherProvider)(url);
  if (!context.mounted || launched) return;

  HapticFeedback.heavyImpact();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Could not open link'),
      backgroundColor: Colors.red,
    ),
  );
}
