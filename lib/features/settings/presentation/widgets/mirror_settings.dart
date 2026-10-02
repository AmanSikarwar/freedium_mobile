import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/features/settings/application/settings_provider.dart';
import 'package:freedium_mobile/features/settings/domain/settings_state.dart';

import 'mirror_list_tile.dart';
import 'mirror_settings_dialogs.dart';

class const MirrorSettings({super.key}) extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).requireValue;
    final settingsNotifier = ref.read(settingsProvider.notifier);
    return Column(
      children: [
        _buildAutoSwitchTile(context, settings, settingsNotifier),
        _buildMirrorTimeoutTile(context, settings, settingsNotifier),
        const Divider(height: 1),
        Padding(
          padding: const .symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Available Mirrors',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
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
                        ? () => showEditMirrorDialog(context, ref, mirror)
                        : null,
                    onDelete: mirror.isCustom
                        ? () => confirmDeleteMirror(context, ref, mirror)
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
              showAddMirrorDialog(context, ref);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Custom Mirror'),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoSwitchTile(
    BuildContext context,
    SettingsState settings,
    Settings notifier,
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
    Settings notifier,
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
    Settings notifier,
  ) {
    int timeout = SettingsState.normalizeMirrorTimeout(settings.mirrorTimeout);

    showDialog<void>(
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
}
