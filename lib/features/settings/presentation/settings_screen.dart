import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          children: [
            _buildSectionHeader(context, 'Appearance'),
            const AppearanceSettings(),
            const Divider(),
            _buildSectionHeader(context, 'Freedium Mirrors'),
            const MirrorSettings(),
            const Divider(),
            _buildSectionHeader(context, 'Storage & Updates'),
            const StorageSettings(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Center(
          child: Column(
            mainAxisSize: .min,
            children: [
              const Text('Could not load settings.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(settingsProvider),
                child: const Text('Retry'),
              ),
            ],
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
