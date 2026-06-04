import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/cache_service.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/core/utils/external_url_launcher.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/changelog_bottom_sheet.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/theme_chooser_bottom_sheet.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';
import 'package:freedium_mobile/features/settings/presentation/widgets/mirror_list_tile.dart';
import 'package:freedium_mobile/features/settings/presentation/widgets/add_mirror_dialog.dart';
import 'package:freedium_mobile/features/webview/presentation/widgets/font_settings_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeTile(context, settings, settingsNotifier),
          _buildFontSizeTile(context, settings, settingsNotifier),
          const Divider(),

          _buildSectionHeader(context, 'Freedium Mirrors'),
          _buildAutoSwitchTile(context, settings, settingsNotifier),
          _buildMirrorTimeoutTile(context, settings, settingsNotifier),
          const Divider(height: 1),
          Padding(
            padding: const .symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Available Mirrors',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          RadioGroup<String>(
            groupValue: settings.selectedMirrorUrl,
            onChanged: (url) async {
              if (url != null) {
                HapticFeedback.selectionClick();
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final didSave = await settingsNotifier.setSelectedMirror(url);
                if (!context.mounted) return;
                if (!didSave) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Failed to save selected mirror'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Column(
              children: settings.mirrors
                  .map(
                    (mirror) => MirrorListTile(
                      mirror: mirror,
                      isSelected: mirror.url == settings.selectedMirrorUrl,
                      onEdit: mirror.isCustom
                          ? () => _showEditMirrorDialog(context, ref, mirror)
                          : null,
                      onDelete: mirror.isCustom
                          ? () => _confirmDeleteMirror(context, ref, mirror)
                          : null,
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: const .symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showAddMirrorDialog(context, ref);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Custom Mirror'),
            ),
          ),
          const Divider(),

          _buildSectionHeader(context, 'Storage & Updates'),
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
            onTap: () => _checkForUpdates(context, ref),
          ),
          const Divider(),

          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: Text(AppConstants.appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Source Code'),
            subtitle: const Text('View on GitHub'),
            onTap: () => _launchUrl(AppConstants.appSourceUrl),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Reset to Defaults'),
            subtitle: const Text('Reset all settings to default values'),
            onTap: () => _confirmResetDefaults(context, ref),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const .fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: .bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('Theme'),
      subtitle: Text(_getThemeModeName(settings.themeMode)),
      onTap: () => showThemeChooserBottomSheet(context),
    );
  }

  String _getThemeModeName(ThemeMode themeMode) {
    switch (themeMode) {
      case .light:
        return 'Light';
      case .dark:
        return 'Dark';
      case .system:
        return 'System';
    }
  }

  Widget _buildFontSizeTile(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) {
    return ListTile(
      leading: const Icon(Icons.text_fields),
      title: const Text('Default Font Size'),
      subtitle: Text('${settings.defaultFontSize.toInt()}px'),
      onTap: () => showFontSettingsSheet(
        context,
        initialFontSize: settings.defaultFontSize,
        onFontSizeChanged: (newSize) async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final didSave = await notifier.setDefaultFontSize(newSize);
          if (!context.mounted) return;
          if (!didSave) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Failed to save default font size'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAutoSwitchTile(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) {
    return SwitchListTile(
      secondary: const Icon(Icons.swap_horiz),
      title: const Text('Auto-Switch Mirror'),
      subtitle: const Text('Automatically use working mirror'),
      value: settings.autoSwitchMirror,
      onChanged: (value) async {
        HapticFeedback.lightImpact();
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final didSave = await notifier.setAutoSwitchMirror(value);
        if (!context.mounted) return;
        if (!didSave) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Failed to save auto-switch mirror'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildMirrorTimeoutTile(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) {
    return ListTile(
      leading: const Icon(Icons.timer),
      title: const Text('Mirror Timeout'),
      subtitle: Text('${settings.mirrorTimeout} seconds'),
      onTap: () => _showTimeoutDialog(context, settings, notifier),
    );
  }

  void _showTimeoutDialog(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
  ) {
    int timeout = SettingsState.normalizeMirrorTimeout(settings.mirrorTimeout);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Mirror Timeout'),
          content: Column(
            mainAxisSize: .min,
            children: [
              Text(
                '$timeout seconds',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Slider(
                value: timeout.toDouble(),
                min: SettingsState.minMirrorTimeout.toDouble(),
                max: SettingsState.maxMirrorTimeout.toDouble(),
                divisions:
                    SettingsState.maxMirrorTimeout -
                    SettingsState.minMirrorTimeout,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() => timeout = value.toInt());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                HapticFeedback.lightImpact();
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final didSave = await notifier.setMirrorTimeout(timeout);
                if (!context.mounted) return;
                if (didSave) {
                  navigator.pop();
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Failed to save mirror timeout'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMirrorDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddMirrorDialog(
        onAdd: (mirror) {
          return ref.read(settingsProvider.notifier).addMirror(mirror);
        },
      ),
    );
  }

  void _showEditMirrorDialog(
    BuildContext context,
    WidgetRef ref,
    FreediumMirror mirror,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddMirrorDialog(
        existingMirror: mirror,
        onAdd: (updatedMirror) {
          return ref
              .read(settingsProvider.notifier)
              .updateMirror(mirror, updatedMirror);
        },
      ),
    );
  }

  void _confirmDeleteMirror(
    BuildContext context,
    WidgetRef ref,
    FreediumMirror mirror,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Mirror'),
        content: Text('Are you sure you want to delete "${mirror.name}"?'),
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
              final didRemove = await ref
                  .read(settingsProvider.notifier)
                  .removeMirror(mirror);
              if (!context.mounted) return;
              if (didRemove) {
                navigator.pop();
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to remove mirror'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmResetDefaults(BuildContext context, WidgetRef ref) {
    showDialog(
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

  Future<void> _checkForUpdates(BuildContext context, WidgetRef ref) async {
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
    final updateInfo = await updateService.checkForUpdate();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (updateInfo != null) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Update Available'),
          content: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              Text('A new version is available: ${updateInfo.latestVersion}'),
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
                showChangelogBottomSheet(context, updateInfo);
              },
              child: const Text('Changelog'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                unawaited(_launchUrl(updateInfo.releaseUrl));
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

  Future<void> _launchUrl(String url) async {
    await launchExternalHttpUrl(url);
  }
}
