import 'package:material_3_expressive/material_3_expressive.dart';

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/changelog_bottom_sheet.dart';

Future<void> checkForUpdates(BuildContext context, WidgetRef ref) async {
  M3ESnackbar.show(
    context,
    message: 'Checking for updates...',
    duration: const Duration(seconds: 10),
  );

  final updateService = ref.read(updateServiceProvider);
  final UpdateInfo? updateInfo;
  try {
    updateInfo = await updateService.checkForUpdate();
  } on UpdateCheckException {
    if (!context.mounted) return;

    M3ESnackbar.show(
      context,
      message: 'Failed to check for updates',
      duration: const Duration(seconds: 4),
    );
    return;
  }

  if (!context.mounted) return;

  M3ESnackbar.defaultController.dismiss();

  final availableUpdate = updateInfo;
  if (availableUpdate != null) {
    M3EDialog.show<void>(
      context,
      autofocusFirst: false,
      dialog: M3EDialog(
        title: 'Update Available',
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
          M3EButton.text(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          M3EButton.text(
            onPressed: () {
              Navigator.pop(context);
              showChangelogBottomSheet(context, availableUpdate);
            },
            child: const Text('Changelog'),
          ),
          M3EButton.filled(
            onPressed: () {
              Navigator.pop(context);
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
    M3ESnackbar.show(
      context,
      message: 'You are using the latest version!',
      duration: const Duration(seconds: 4),
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
  M3ESnackbar.show(
    context,
    message: 'Could not open link',
    duration: const Duration(seconds: 4),
  );
}
