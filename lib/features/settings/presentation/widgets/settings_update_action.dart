import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/changelog_bottom_sheet.dart';

Future<void> checkForUpdates(BuildContext context, WidgetRef ref) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 16),
          Text('Checking for updates...'),
        ],
      ),
      duration: Duration(seconds: 10),
    ),
  );

  final updateService = ref.read(updateServiceProvider);
  final UpdateInfo? updateInfo;
  try {
    updateInfo = await updateService.checkForUpdate();
  } on UpdateCheckException {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Failed to check for updates'),
          backgroundColor: Colors.red,
        ),
      );
    return;
  }

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  final availableUpdate = updateInfo;
  if (availableUpdate != null) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Available'),
        content: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Text(
              'A new version is available: ${availableUpdate.latestVersion}',
            ),
            const SizedBox(height: 8),
            Text(
              'Current version: ${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              showChangelogBottomSheet(context, availableUpdate);
            },
            child: const Text('Changelog'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              unawaited(
                launchSettingsUrl(context, ref, availableUpdate.releaseUrl),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You are using the latest version!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

Future<void> launchSettingsUrl(
  BuildContext context,
  WidgetRef ref,
  String url,
) async {
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
