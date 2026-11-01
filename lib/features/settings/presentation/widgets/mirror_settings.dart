import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:freedium_mobile/shared/widgets/expressive_switch_tile.dart';
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

    Future<void> selectMirror(String url) async {
      HapticFeedback.selectionClick();
      final didSave = await settingsNotifier.setSelectedMirror(url);
      if (!context.mounted) return;
      if (!didSave) {
        M3ESnackbar.show(
          context,
          message: 'Failed to save selected mirror',
          duration: const Duration(seconds: 4),
        );
      }
    }

    return Column(
      children: [
        _buildAutoSwitchTile(context, settings, settingsNotifier),
        _buildMirrorTimeoutTile(context, settings, settingsNotifier),
        const M3EDivider(),
        Padding(
          padding: const .symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Available Mirrors',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        M3ERadioGroup<String>(
          groupValue: settings.selectedMirrorUrl,
          groupLabel: 'Available Mirrors',
          onChanged: selectMirror,
          child: Column(
            children: settings.mirrors
                .map(
                  (mirror) => MirrorListTile(
                    mirror: mirror,
                    selectedMirrorUrl: settings.selectedMirrorUrl,
                    onSelect: selectMirror,
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
          child: M3EButton.outlined(
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
    return ExpressiveSwitchTile(
      leading: const Icon(Icons.swap_horiz),
      title: 'Auto-Switch Mirror',
      subtitle: 'Automatically use working mirror',
      value: settings.autoSwitchMirror,
      onChanged: (value) async {
        HapticFeedback.lightImpact();
        final didSave = await notifier.setAutoSwitchMirror(value);
        if (!context.mounted) return;
        if (!didSave) {
          M3ESnackbar.show(
            context,
            message: 'Failed to save auto-switch mirror',
            duration: const Duration(seconds: 4),
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
    return M3EListItem(
      headline: 'Mirror Timeout',
      supportingText: '${settings.mirrorTimeout} seconds',
      leading: const Icon(Icons.timer),
      onTap: () => _showTimeoutDialog(context, settings, notifier),
    );
  }

  void _showTimeoutDialog(
    BuildContext context,
    SettingsState settings,
    Settings notifier,
  ) {
    int timeout = SettingsState.normalizeMirrorTimeout(settings.mirrorTimeout);

    M3EDialog.show<void>(
      context,
      dialog: StatefulBuilder(
        builder: (context, setState) => M3EDialog(
          title: 'Mirror Timeout',
          content: Column(
            mainAxisSize: .min,
            children: [
              Text(
                '$timeout seconds',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(
                width: 280,
                height: 64,
                child: M3ESlider(
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
              ),
            ],
          ),
          actions: [
            M3EButton.text(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            M3EButton.filled(
              onPressed: () async {
                HapticFeedback.lightImpact();
                final navigator = Navigator.of(context);
                final didSave = await notifier.setMirrorTimeout(timeout);
                if (!context.mounted) return;
                if (didSave) {
                  navigator.pop();
                } else {
                  M3ESnackbar.show(
                    context,
                    message: 'Failed to save mirror timeout',
                    duration: const Duration(seconds: 4),
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
