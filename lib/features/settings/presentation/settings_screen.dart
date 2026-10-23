import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/layout/floating_toolbar.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';

import 'widgets/appearance_settings.dart';
import 'widgets/mirror_settings.dart';
import 'widgets/storage_settings.dart';

class const SettingsScreen({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) => Scaffold(
        appBar: M3EAppBar.top(
          automaticallyImplyLeading: true,
          titleText: 'Settings',
        ),
        body: ListView(
          padding: EdgeInsets.only(bottom: floatingToolbarClearance(context)),
          children: [
            _buildSectionHeader(context, 'Appearance'),
            const AppearanceSettings(),
            const M3EDivider(),
            _buildSectionHeader(context, 'Freedium Mirrors'),
            const MirrorSettings(),
            const M3EDivider(),
            _buildSectionHeader(context, 'Storage & Updates'),
            const StorageSettings(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      loading: () => Scaffold(
        appBar: M3EAppBar.top(
          automaticallyImplyLeading: true,
          titleText: 'Settings',
        ),
        body: const Center(child: M3EProgressIndicator.circularWavy()),
      ),
      error: (error, _) => Scaffold(
        appBar: M3EAppBar.top(
          automaticallyImplyLeading: true,
          titleText: 'Settings',
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Could not load settings.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You can retry or restore defaults. A recovery copy of '
                      'the unreadable settings will be kept on this device.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    M3EButton.filled(
                      onPressed: () => ref.invalidate(settingsProvider),
                      child: const Text('Retry'),
                    ),
                    M3EButton.text(
                      onPressed: () async {
                        final confirmed = await M3EDialog.show<bool>(
                          context,
                          autofocusFirst: false,
                          dialog: M3EDialog(
                            title: 'Restore default settings?',
                            content: const Text(
                              'The unreadable settings will be kept in a local '
                              'recovery copy before defaults are saved.',
                            ),
                            actions: [
                              M3EButton.text(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              M3EButton.filled(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Restore defaults'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed != true || !context.mounted) return;
                        final restored = await ref
                            .read(settingsProvider.notifier)
                            .restoreDefaultsPreservingUnreadableSnapshot();
                        if (!context.mounted) return;
                        M3ESnackbar.show(
                          context,
                          message: restored
                              ? 'Settings restored to defaults'
                              : 'Could not restore default settings',
                          duration: const Duration(seconds: 4),
                        );
                      },
                      child: const Text('Restore defaults'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
}
