import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:freedium_mobile/core/services/cache_service.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/changelog_bottom_sheet.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/theme_chooser_bottom_sheet.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';
import 'package:freedium_mobile/features/settings/presentation/widgets/mirror_list_tile.dart';
import 'package:freedium_mobile/features/settings/presentation/widgets/add_mirror_dialog.dart';
import 'package:freedium_mobile/features/webview/presentation/widgets/font_settings_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

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
            onChanged: (url) {
              if (url != null) {
                HapticFeedback.selectionClick();
                settingsNotifier.setSelectedMirror(url);
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
                      onTest: () => _testMirror(context, ref, mirror.url),
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
        onFontSizeChanged: (newSize) => notifier.setDefaultFontSize(newSize),
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
      onChanged: (value) {
        HapticFeedback.lightImpact();
        notifier.setAutoSwitchMirror(value);
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
    int timeout = settings.mirrorTimeout;

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
                min: 2,
                max: 15,
                divisions: 13,
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
              onPressed: () {
                HapticFeedback.lightImpact();
                notifier.setMirrorTimeout(timeout);
                Navigator.pop(context);
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
          ref.read(settingsProvider.notifier).addMirror(mirror);
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
          ref
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
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(settingsProvider.notifier).removeMirror(mirror);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _testMirror(
    BuildContext context,
    WidgetRef ref,
    String url,
  ) async {
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
            Text('Testing mirror...'),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );

    final result = await ref.read(settingsProvider.notifier).testMirror(url);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result.isReachable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Mirror reachable (${result.responseTimeMs}ms)'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✗ Mirror unreachable: ${result.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
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
        builder: (context) => AlertDialog(
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
            TextButton(
              onPressed: () => showChangelogBottomSheet(context, updateInfo),
              child: const Text('Changelog'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                launchUrl(Uri.parse(updateInfo.releaseUrl));
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
    try {
      await launchUrl(Uri.parse(url));
    } catch (_) {}
  }
}
