import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

void showAppAboutDialog(BuildContext context, WidgetRef ref) {
  Future<void> launchUri(Uri uri) async {
    try {
      await launchUrl(uri);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch URL: $e')));
      }
    }
  }

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
                launchUri(Uri.https('github.com', 'amansikarwar/freedium')),
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
            onPressed: () => launchUri(Uri.https('github.com', 'amansikarwar')),
            child: const Text('Aman Sikarwar', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    ],
  );
}
