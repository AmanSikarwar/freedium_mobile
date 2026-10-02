import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';

import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/cache_service.dart';

import 'settings_update_action.dart';

class const StorageSettings({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.delete_outline),
          title: const Text('Clear Cache'),
          subtitle: const Text('Clear WebView cache and local storage'),
          onTap: () => _clearCache(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.update),
          title: const Text('Check for Updates'),
          subtitle: const Text('Check if a new version is available'),
          onTap: () => checkForUpdates(context, ref),
        ),
        const Divider(),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Version'),
          subtitle: Text(AppConstants.appVersion),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('Source Code'),
          subtitle: const Text('View on GitHub'),
          onTap: () => unawaited(
            launchSettingsUrl(context, ref, AppConstants.appSourceUrl),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Reset to Defaults'),
          subtitle: const Text('Reset all settings to default values'),
          onTap: () => _confirmResetDefaults(context, ref),
        ),
      ],
    );
  }

  void _confirmResetDefaults(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'This will reset all settings to their default values. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              final didReset = await ref
                  .read(settingsProvider.notifier)
                  .resetToDefaults();
              if (!context.mounted) return;
              navigator.pop();
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    didReset
                        ? 'Settings reset to defaults'
                        : 'Failed to reset settings',
                  ),
                  backgroundColor: didReset ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final cacheService = ref.read(cacheServiceProvider);
    ref.read(freediumUrlServiceProvider).invalidateCache();
    final success = await cacheService.clearWebViewCache();
    if (context.mounted) {
      if (success) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Cache cleared successfully' : 'Failed to clear cache',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
